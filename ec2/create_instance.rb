# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#   Jenkins用にEC2インスタンスを立てる
#   あらかじめ必要な設定を.envに記述してから実行してください
#
#   Usage: 
#     $ rbenv exec bundle install --path=vender/bundle 
#     $ bundle exec ruby create_instance.rb 'test_instance' 't2.micro' '10.0.2.10' 8
#
 
require 'aws-sdk'
require 'dotenv'
require 'pp'

Dotenv.load

# インスタンス起動時に実行される
USER_DATA = <<"EOS"
#cloud-config
timezone: "Asia/Tokyo"
runcmd:
 - [ sh, -c, "sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers" ]
EOS

class JenkinsEC2
  AMI = 'ami-cbf90ecb' # Amazon Linux AMI 2015.03
  SUBNET = ENV['SUBNET']
  KEY_NAME = ENV['KEY_NAME']
  SECURITY_GROUP_IDS = [ENV['SECURITY_GROUP']]

  def initialize()
    @ec2 = Aws::EC2::Client.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_DEFAULT_REGION'] # 'ap-northeast-1'
    )
  end

  def create(instance_name, instance_type = 't2.micro', private_ip_address = '10.0.0.10', ebs_size = 8)
    puts "creating instance..."
    ec2_options = {
      # dry_run: true,
      image_id: AMI,
      max_count: 1,
      min_count: 1,
      key_name: KEY_NAME,
      instance_type: instance_type,
      user_data: Base64.encode64(USER_DATA),
      block_device_mappings: [
        {
          device_name: '/dev/xvda',
          ebs: { volume_size: ebs_size }
        }
      ],
      disable_api_termination: false,
      network_interfaces: [
        {
          device_index: 0,
          subnet_id: SUBNET,
          groups: SECURITY_GROUP_IDS,
          delete_on_termination: true,
          associate_public_ip_address: true,
          private_ip_address: private_ip_address,
        },
      ]
    }

    instance = @ec2.run_instances(ec2_options)
    instance_id = instance.data.instances[0].instance_id
    
    # runningまでは1分以内に終わりますが、すぐにsshで入れないみたいようなのでstatus okまで待ちます
    begin
      @ec2.wait_until(:instance_running, instance_ids:[instance_id])
      puts "instance running..."
    rescue Aws::Waiters::Errors::WaiterFailed => error
      puts "failed waiting for instance running: #{error.message}"
    end

    # status okまでは時間がかかる(5分くらい)
    begin
      @ec2.wait_until(:instance_status_ok, instance_ids:[instance_id])
      puts "instance status ok."
    rescue Aws::Waiters::Errors::WaiterFailed => error
      puts "failed waiting for instance status ok: #{error.message}" 
    end

    # 作成したインスタンス情報を取得する
    describe_response = @ec2.describe_instances(instance_ids:[instance_id])
    ip_address = describe_response.data.reservations[0].instances[0].public_ip_address
    puts "Launched instance: #{instance_id}"
    puts "IP Address: #{ip_address}"
    @ec2.create_tags(
      resources: [instance_id],
      tags: [
        {
          key: "Name",
          value: instance_name
        }
      ]
    )
  end 
end

if ARGV.size != 4
  puts "usage: #{$0} <instance_name> <instance_type> <private_ip_address> <ebs_size>"
  exit 1
end
instance_name, instance_type, private_ip_address, ebs_size = ARGV
ebs_size = ebs_size.to_i
 
ec2 = JenkinsEC2.new
ec2.create(instance_name, instance_type, private_ip_address, ebs_size)

