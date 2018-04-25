
# Terraform Ansible deployer: デプロイ用ユーザー設定サンプルコード

クラウド上の仮想マシンにデプロイ用ユーザー `deployer` を設定するサンプルです。

* Terraform により、.pem によるキーペアログインが可能な `my-webapp-dev` を作成し、
* Ansible により、パスワード無しで sudo できる deployer ユーザーを作成します。

Sample code to set up deployer user on virtual machine.

* create VM with .pem private key file using Terraform
* create deployer user (sudo-able without password) using Ansible


## 事前準備 (Prerequisite)

* `~/.ssh/id_rsa.pub` が存在しない場合、適宜作成します。 (confirm your id_rsa.pub)
* その場合、`ssh-keygen` により作成できます。 (use ssh-keygen in such case)


## VM 作成 (Create VM)

キーペアを使ってアクセスできる仮想マシン `my-webapp-dev` を作成します。

```
cd terraform
```

* `variables.tf` を適宜更新します。 (update variables if needed)
* terrafrom を実行します。 (run terraform)

```
export ALICLOUD_ACCESS_KEY=xxxxxxxxxxxxxxxx
export ALICLOUD_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export ALICLOUD_REGION=ap-northeast-1
terraform init
terraform plan
terraform apply
```

* IP アドレスが出力されるので確認します。 (check IP address in the output)
* terraform 実行直後以外の場合 `terraform show` `terraform output` で再度出力できます。
* `ssh_config.root` の HostName を上記 IP で更新します。 (update ssh_config.root)
* `root` としてログインできることを確認します。 (check ssh login as root)

```
ssh -F ssh_config.root my-webapp-dev
[root@my-webapp-dev ~]# whoami
root
```


## デプロイ用ユーザー作成 (Create deploy user)

パスワード無しで sudo できる deployer ユーザーを作成します。

```
cd ansible
```

* `development` を適宜更新します。 (update development if needed)
* `ssh_config.root` HostName を上記IPアドレスで更新します。 (update ssh_config)
* `ansible-playbook` を実行します。 (run ansible-playbook)

```
ansible-playbook -i development create-deploy-user.yml
```

* `ssh_config.deployer` HostName を上記IPアドレスで更新します。 (update ssh_config)
* `deployer` としてログインできることを確認します。 (check ssh login as deployer)

```
ssh -F ssh_config.deployer deployer@my-webapp-dev
```

* password 無しで sudo できることを確認します。 (check sudo without password)

```
[deploy@my-webapp-dev ~]$ sudo whoami
root
```


## nginx のデプロイ (test deploy nginx)

テスト用に、nginx のサンプル playbook をデプロイします。

```
cd nginx
```

* `ssh_config.deployer` HostName を上記IPアドレスで更新します。 (update ssh_config)
* `ansible-playbook` を実行します。 (run ansible-playbook)

```
ansible-playbook -i development -u deployer sample-playbook.yml
```

上記IPアドレスにアクセスします。 (access to the IP address)

http://47.74.xx.xx/

Hello World! と表示されるはずです。 (Now you should see Hello World!)


## 片付け (clean up)

* VM を削除します。 (delete VM)

```
terraform plan -destroy
terraform destroy
```


## 参照 (Reference)

* https://github.com/alibaba/terraform-provider/tree/master/terraform/examples/alicloud-ecs-key-pair
