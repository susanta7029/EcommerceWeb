#!/bin/bash
cd /var/www/ecommerce
source venv/bin/activate

# Update Django settings
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['*']/" ecommerce/settings.py
sed -i 's/DEBUG = True/DEBUG = False/' ecommerce/settings.py
echo "STATIC_ROOT = '/var/www/ecommerce/staticfiles/'" >> ecommerce/settings.py

# Run migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --noinput

# Set proper permissions
sudo chown -R ubuntu:www-data /var/www/ecommerce
sudo chmod -R 755 /var/www/ecommerce

echo "Django configuration complete!"
