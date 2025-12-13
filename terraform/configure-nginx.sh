#!/bin/bash
set -e

echo "=========================================="
echo "Configuring Nginx for Django App"
echo "=========================================="

# Get the server's private IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Remove default Nginx config
sudo rm -f /etc/nginx/sites-enabled/default

# Create Nginx configuration for Django
sudo tee /etc/nginx/sites-available/ecommerce > /dev/null << EOF
server {
    listen 80;
    server_name _;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        alias /var/www/ecommerce/staticfiles/;
    }
    
    location /media/ {
        alias /var/www/ecommerce/media/;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/ecommerce /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "Nginx configured successfully!"
echo "Server listening on port 80"
