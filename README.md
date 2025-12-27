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
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  app:
    image: fox4kids/myrepo:currency
    container_name: currency
    ports:
      - 5000:5000
    restart: unless-stopped
EOF

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

## 4 Install and run Node Exporter and Nginx Log Exporter

```
# Nginx Log Exporter
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  nginx-exporter:
    image: quay.io/martinhelmich/prometheus-nginxlog-exporter:v1.11.0
    volumes: 
      - /var/log/nginx/:/mnt/nginxlogs
    ports:
      - 4040:4040
    restart: unless-stopped
EOF

sudo docker run -d \
    --name nginx-exporter \
    -v /var/log/nginx/:/mnt/nginxlogs \
    -p 4040:4040 \
    quay.io/martinhelmich/prometheus-nginxlog-exporter:v1.11.0 \
    mnt/nginxlogs/access.log

# Node Exporter
cd ~
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
tar xvfz node_exporter-1.10.2.linux-amd64.tar.gz

sudo cp node_exporter-files/node_exporter /usr/bin/
sudo chown node_exporter:node_exporter /usr/bin/node_exporter

sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
sudo groupadd -f node_exporter
sudo mkdir /etc/node_exporter
sudo chown node_exporter:node_exporter /etc/node_exporter

sudo tee /etc/systemd/system/node_exporter.service > /den/null <<'EOF'
[Unit]
Description=My Node exporter service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter \
  --web.listen-address=:9200

[Install]
WantedBy=graphical.target
EOF
```

## 5 Install and run Prometheus
```
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  prometheus:
    image: prom/prometheus:v3.3.0
    container_name: prometheus
    volumes: 
      - ./prometheus:/etc/prometheus/
      -  prometheus-data:/prometheus
    ports:
      - 9090:9090
    restart: unless-stopped
volumes:
   prometheus-data:
EOF

cd ~
wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
tar xvzf prometheus-3.5.0.linux-amd64.tar.gz 
cd prometheus-3.5.0.linux-amd64/

sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo cp prometheus promtool /usr/local/bin/
sudo cp prometheus.yml /etc/prometheus/

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/

# Automation run
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<'EOF'
[Unit]
Description=My Prometheus service
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/
ExecReload=/bin/kill -HUP $MAINPID Restart=on-failure

[Install]
WantedBy=graphical.target
EOF

systemctl enable prometheus.service
systemctl start prometheus.service
systemctl daemon-reload
systemctl status prometheus.service
```

## 6 Install and run Grafana
```
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  grafana:
    image: grafana/grafana:11.6.1
    container_name: grafana
    volumes:
      - ./grafana/:/etc/grafana/
      - grafana-data:/grafana
    environment:
      - GF_PATHS_CONFIG=/etc/grafana/custom.ini
    ports:
      - 80:3000
    restart: unless-stopped
volumes:
   grafana-data:
EOF
```

## 7 Install and run ELK
```
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  elasticsearch:
    image: elasticsearch:9.1.5
    container_name: elasticsearch
    environment:
      - cluster.name="my-elk-cluster"
      - xpack.security.enabled=false
      - discovery.type=single-node
    mem_limit: 1073741824
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    cap_add:
      - IPC_LOCK
    volumes:
      - "./elasticsearch-data:/usr/share/elasticsearch/data"
    ports:
      - 9200:9200
EOF
```

## 8 Install and run Filebeat
```
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  filebeat:
    container_name: filebeat
    image: elastic/filebeat:9.1.5
    command: --strict.perms=false
    environment:
      - ELASTIC_HOSTS="http://${CONTAINER_NAME}:9200"
    volumes:
      - "./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro"
      - "./nginx/log:/usr/share/logstash/nginx/log:ro"
EOF
```

## 9 Install and run Kibana
```
sudo tee docker-compose.yaml > /den/null <<'EOF'
services:
  kibana:
    container_name: kibana
    image: kibana:9.1.5
    environment:
      - ELASTICSEARCH_HOSTS="http://${CONTAINER_NAME}:9200"
    ports:
      - 5601:5601
    mem_limit: 1073741824
EOF
```