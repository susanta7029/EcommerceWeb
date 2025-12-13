#!/bin/bash
set -e

SLAVE1_IP="$1"
SLAVE2_IP="$2"

echo "=========================================="
echo "Configuring Master as Load Balancer"
echo "=========================================="
echo "Slave 1 IP: $SLAVE1_IP"
echo "Slave 2 IP: $SLAVE2_IP"

# Install Nginx if not already installed
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx

# Create Nginx load balancer configuration
sudo tee /etc/nginx/sites-available/loadbalancer > /dev/null << EOF
upstream django_backend {
    least_conn;
    server ${SLAVE1_IP}:80 max_fails=3 fail_timeout=30s;
    server ${SLAVE2_IP}:80 max_fails=3 fail_timeout=30s;
}

server {
    listen 8080;
    server_name _;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location / {
        proxy_pass http://django_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Enable the load balancer site
sudo ln -sf /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

echo "=========================================="
echo "Load Balancer configured successfully!"
echo "=========================================="
echo "Your e-commerce app is accessible at:"
echo "http://\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo ""
echo "Backend servers:"
echo "  - Slave 1: http://${SLAVE1_IP}:80"
echo "  - Slave 2: http://${SLAVE2_IP}:80"
