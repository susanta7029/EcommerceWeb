#!/bin/bash
set -e

echo "=========================================="
echo "Creating Gunicorn Systemd Service"
echo "=========================================="

# Create Gunicorn systemd service
sudo tee /etc/systemd/system/gunicorn.service > /dev/null << 'EOF'
[Unit]
Description=Gunicorn daemon for Django E-commerce App
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/var/www/ecommerce
Environment="PATH=/var/www/ecommerce/venv/bin"
ExecStart=/var/www/ecommerce/venv/bin/gunicorn \
    --workers 3 \
    --bind 127.0.0.1:8000 \
    --timeout 120 \
    ecommerce.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start Gunicorn
sudo systemctl enable gunicorn
sudo systemctl restart gunicorn

echo "Gunicorn service created and started!"
echo "Status:"
sudo systemctl status gunicorn --no-pager
