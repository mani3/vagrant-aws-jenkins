# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Dotenv.load

USER_DATA = <<"EOS"
#cloud-config
timezone: "Asia/Tokyo"
runcmd:
 - [ sh, -c, "sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers" ]
EOS

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "dummy"

  # 同期するフォルダを選択（vagrant-awsでは常に同期される訳ではなく、provisionやupなどのコマンド実行時に同期される）
  config.vm.synced_folder "./", "/home/ec2-user/vagrant", disabled: true

  config.vm.provider :aws do |aws, override|
    # アクセスキー
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID'] 
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    
    # SSH時の鍵
    aws.keypair_name = "mani3_quan_key"
    
    # インスタンス
    aws.instance_type = "t2.micro"
    aws.region = "ap-northeast-1"
    aws.availability_zone = "ap-northeast-1a"
    
    # Amazon Linux AMI 2015.04.07
    aws.ami = "ami-cbf90ecb"

    # Security Group
    aws.security_groups = ["#{ENV['AWS_SECURITY_GROUP']}"]

    # VPC内でPublic IPを有効
    aws.associate_public_ip = 'true'
    aws.subnet_id = ENV['AWS_SUBNET_ID']

    # インスタンスにタグを設定
    aws.tags = {'Name' => 'vagrant-test'}

    # Amazon Linuxの場合は最初からsudoできないので指定しておく
    aws.user_data = USER_DATA

    # SSH
    override.ssh.username = 'ec2-user'
    override.ssh.private_key_path = '~/.ssh/mani3_quan_key.pem'

    config.vm.provision :ansible do |ansible|
      ansible.playbook = 'jenkins.yml'
      ansible.groups = {
        'servers' => ['default']
      }
    end
  end
end
