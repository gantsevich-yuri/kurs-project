## 1 Deploy vms :fast_forward:

```
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

## 2 Install packages from playbook :fast_forward:
```
cd ..
cd ansible
ansible-playbook -i hosts.ini playbook.yaml
```

## 3 Pull app image from docker hub and change nginx config :fast_forward:
```
# run app in container
docker login
docker pull fox4kids/myrepo:currency
docker run -d -p 5000:5000 fox4kids/myrepo:currency

# add nginx config
sudo tee /etc/nginx/sites-available/my-app > /dev/null <<'EOF'
server {
    listen 80;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/my-app /etc/nginx/sites-enabled/my-app
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

## Install Node Exporter and Nginx Log Exporter

```
sudo docker run -d \
    --name nginx-exporter \
    -v /var/log/nginx/:/mnt/nginxlogs \
    -p 4040:4040 \
    quay.io/martinhelmich/prometheus-nginxlog-exporter:v1.11.0 \
    mnt/nginxlogs/access.log
```
