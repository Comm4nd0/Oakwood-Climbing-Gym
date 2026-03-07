#!/bin/bash
# Initial setup script for the Oakwood Climbing Center project

set -e

echo "Setting up Oakwood Climbing Center..."

# Backend setup
echo "Setting up Python backend..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from .env.example. Please update with your settings."
fi

# Run migrations
python manage.py migrate

# Seed database
python manage.py seed_data

# Create superuser
echo "Creating admin superuser..."
python manage.py createsuperuser

echo ""
echo "Setup complete!"
echo "Run 'python manage.py runserver' to start the backend."
echo "Run 'cd my_app && flutter run' to start the mobile app."
