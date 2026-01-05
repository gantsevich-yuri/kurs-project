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

## 3 Configuration web server :fast_forward:
```
# download and run app
docker login
docker pull fox4kids/myrepo:currency
```

```
# Create docker-compose file with our APP, nginx and node exporter services
sudo tee docker-compose.yaml > /dev/null <<'EOF'
services:
  app:
    image: fox4kids/myrepo:currency
    container_name: currency
    ports:
      - 5000:5000
    restart: unless-stopped

  nginx-exporter:
    image: quay.io/martinhelmich/prometheus-nginxlog-exporter:v1.11.0
    volumes:
      - /var/log/nginx/:/mnt/nginxlogs
    ports:
      - 4040:4040
    restart: unless-stopped

  node_exporter:
    image: quay.io/prometheus/node-exporter:latest
    container_name: node_exporter
    network_mode: host
    pid: host
    restart: unless-stopped
    volumes:
      - '/:/host:ro,rslave'
    command:
      - '--path.rootfs=/host'
      - '--collector.cpu'
      - '--collector.meminfo'
      - '--collector.diskstats'
      - '--collector.filesystem'
      - '--collector.netdev'
      - '--collector.loadavg'
      - '--collector.time'
      - '--collector.systemd'
EOF

sudo docker compose up -d
```

```
# add nginx config for redirection traffic to APP
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

## 4 Install, config and run Prometheus
```
# prometheus config
mkdir -p ~/prometheus
sudo tee ~/prometheus/prometheus.yml > /dev/null <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'node_exporters'
    static_configs:
      - targets:
          - '10.0.10.35:9100'  # app1
          - '10.0.20.12:9100'  # app2

  - job_name: 'nginx_log_exporters'
    metrics_path: '/metrics'
    static_configs:
      - targets:
          - '10.0.10.35:4040'  # app1
          - '10.0.20.12:4040'  # app2
EOF
```

```
# prometheus docker-compose
sudo tee docker-compose.yaml > /dev/null <<'EOF'
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
```

## 5 Install and run Grafana
```
sudo tee docker-compose.yaml > /dev/null <<'EOF'
services:
  grafana:
    image: grafana/grafana:11.6.1
    container_name: grafana
    volumes:
      - grafana-data:/grafana
    ports:
      - 80:3000
    restart: unless-stopped
volumes:
   grafana-data:
EOF
```

## 6 Install and run ELK
```
sudo tee docker-compose.yaml > /dev/null <<'EOF'
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

## 7 Install and run Filebeat
```
sudo tee docker-compose.yaml > /dev/null <<'EOF'
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

## 8 Install and run Kibana
```
sudo tee docker-compose.yaml > /dev/null <<'EOF'
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