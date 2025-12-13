#!/bin/bash
set -e

echo "=========================================="
echo "Django E-commerce Deployment Script"
echo "=========================================="

# Update system
echo "Updating system packages..."
sudo apt-get update -qq

# Install Python and dependencies
echo "Installing Python and dependencies..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    supervisor \
    git

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /var/www/ecommerce
sudo chown -R ubuntu:ubuntu /var/www/ecommerce
cd /var/www/ecommerce

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install gunicorn

# Create requirements file
cat > requirements.txt << 'EOF'
asgiref==3.9.1
certifi==2025.8.3
charset-normalizer==3.4.3
crispy-bootstrap5==2025.6
Django==5.2.5
django-allauth==65.11.0
django-crispy-forms==2.4
django-environ==0.12.0
idna==3.10
pillow==11.3.0
python-dotenv==1.1.1
requests==2.32.5
sqlparse==0.5.3
stripe==12.4.0
typing_extensions==4.14.1
tzdata==2025.2
urllib3==2.5.0
EOF

pip install -r requirements.txt

# Create placeholder directories
mkdir -p media/product_images
mkdir -p static

echo "Django environment setup complete!"
echo "Application directory: /var/www/ecommerce"
echo "Virtual environment: /var/www/ecommerce/venv"
