# Render Deployment Guide for Django E-commerce App

## Steps to Deploy on Render:

### 1. Push your code to GitHub
```bash
git init
git add .
git commit -m "Initial commit for Render deployment"
git branch -M main
git remote add origin <your-github-repo-url>
git push -u origin main
```

### 2. Create a Render Account
- Go to https://render.com
- Sign up with your GitHub account

### 3. Create a New Web Service
- Click "New +" → "Web Service"
- Connect your GitHub repository
- Configure the service:
  - **Name**: ecommerce-app (or your preferred name)
  - **Runtime**: Python
  - **Build Command**: `./build.sh`
  - **Start Command**: `gunicorn ecommerce.wsgi:application`

### 4. Set Environment Variables
In Render dashboard, add these environment variables:
- `SECRET_KEY`: Generate a new secret key (use Django's get_random_secret_key())
- `DEBUG`: False
- `ALLOWED_HOSTS`: your-app-name.onrender.com
- `STRIPE_PUBLISHABLE_KEY`: (your Stripe publishable key)
- `STRIPE_SECRET_KEY`: (your Stripe secret key)
- `PYTHON_VERSION`: 3.10.6

### 5. Optional: Add PostgreSQL Database
- Click "New +" → "PostgreSQL"
- Create database
- Copy the Internal Database URL
- Add to your web service as `DATABASE_URL` environment variable

### 6. Deploy
- Click "Create Web Service"
- Render will automatically deploy your app
- Access your app at: https://your-app-name.onrender.com

## Important Notes:
- The free tier spins down after inactivity (may take 30-60 seconds to wake up)
- SQLite doesn't persist on Render free tier - use PostgreSQL for production
- Media files won't persist - consider using AWS S3 or Cloudinary
- Make sure build.sh has execute permissions: `chmod +x build.sh`

## Troubleshooting:
- Check deploy logs in Render dashboard
- Ensure all dependencies are in requirements.txt
- Verify environment variables are set correctly
