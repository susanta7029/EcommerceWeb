# Deploy Django E-commerce App to AWS EC2
$SERVER_IP = "3.237.179.154"
$KEY_PATH = "terraform\private-key.pem"
$REMOTE_USER = "ubuntu"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Django App to AWS EC2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Create directory and upload files
Write-Host "`n[1/5] Creating directory and uploading files..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -i $KEY_PATH "${REMOTE_USER}@${SERVER_IP}" "mkdir -p /home/ubuntu/ecommerce-app"
scp -o StrictHostKeyChecking=no -i $KEY_PATH -r ecommerce store manage.py requirements.txt db.sqlite3 media "${REMOTE_USER}@${SERVER_IP}:/home/ubuntu/ecommerce-app/"

# Step 2: Install Python venv package
Write-Host "`n[2/5] Installing python3-venv..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -i $KEY_PATH "${REMOTE_USER}@${SERVER_IP}" "sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-venv python3-pip"

# Step 3: Create virtual environment and install dependencies
Write-Host "`n[3/5] Setting up virtual environment..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -i $KEY_PATH "${REMOTE_USER}@${SERVER_IP}" "cd /home/ubuntu/ecommerce-app && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt"

# Step 4: Run migrations
Write-Host "`n[4/5] Running Django migrations..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -i $KEY_PATH "${REMOTE_USER}@${SERVER_IP}" "cd /home/ubuntu/ecommerce-app && source venv/bin/activate && python manage.py migrate"

# Step 5: Start Django server
Write-Host "`n[5/5] Starting Django development server..." -ForegroundColor Yellow
ssh -o StrictHostKeyChecking=no -i $KEY_PATH "${REMOTE_USER}@${SERVER_IP}" "cd /home/ubuntu/ecommerce-app && source venv/bin/activate && nohup python manage.py runserver 0.0.0.0:8000 > django.log 2>&1 & sleep 2 && ps aux | grep 'manage.py runserver' | grep -v grep"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nYour app should be accessible at:" -ForegroundColor Cyan
Write-Host "http://${SERVER_IP}:8000" -ForegroundColor Yellow
Write-Host "`nTo view logs:" -ForegroundColor Cyan
Write-Host "ssh -i $KEY_PATH $REMOTE_USER@$SERVER_IP 'tail -f /home/ubuntu/ecommerce-app/django.log'" -ForegroundColor Gray
