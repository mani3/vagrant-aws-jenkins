# Vagrant

## Vagrantのインストール
```
// homebrewを使う場合
$ brew install vagrant
```

## 使用するプラグインをインストール
```
$ vagrant plugin install vagrant-aws
$ vagrant plugin install dotenv
```

## 使用例

``` 
$ vagrant up --provider=aws
$ vagrant ssh
$ vagrant provision 
$ vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Terminating the instance...
```

# ansible

```
// homebrewを使う場合
$ brew install ansible
```

## 実行例

*vagrant up --provider=aws* でJenkinsのインストールまで行われますが*ansible-playbook*単体で実行する場合

```
$ ansible-playbook -i hosts jenkins.yml -vvv
```

## jenkins.yml

*jenkins.yml* でapacheとjenkinsがインストールされます。
apacheはリバースプロキシとして利用して *http://hostname/jenkins* でアクセスできるように設定してます。

