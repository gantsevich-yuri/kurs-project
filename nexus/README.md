## Deploy :fast_forward:

```
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

- check white vm cloud ip
- in host.ini set ip addr ansible_host

```
cd ..
cd ansible
ansible-playbook -i host.ini playbook.yml
```