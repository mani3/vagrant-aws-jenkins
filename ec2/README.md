# AWS EC2

EC2にインスタンスを立てるためのスクリプト

# 設定ファイル

あらかじめ必要なパラメータ

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* KEY_NAME: あらかじめに作成したKeyPair名
* SUBNET: インスタンスを立てるサブネット
* SECURITY_GROUP: あらかじめセキュリティグループは用意してIDをセットする

.env.sampleの設定ファイルを更新後、.env.sample -> .envにリネームする
```
AWS_ACCESS_KEY_ID='AKIxxxxxxxxxxxxxxxxxxxxxxx'
AWS_SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
AWS_DEFAULT_REGION='ap-northeast-1'
KEY_NAME='xxxx_key'
SUBNET='subnet-xxxxxxx'
SECURITY_GROUP='sg-xxxxxxx'
```

# インスタンス作成

```
$ ruby create_instance.rb <インスタンス名> <インスタンスタイプ> <プライベートIP> <EBSのサイズ>
```

# 実行例
```
$ rbenv exec bundle install --path=vender/bundle 
$ bundle exec ruby create_instance.rb 'test_instance' 't2.micro' '10.0.2.10' 8
```

