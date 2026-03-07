#!/bin/bash
# Start the development environment

set -e

echo "Starting Oakwood Climbing Center development environment..."

# Check if Docker is available
if command -v docker &> /dev/null; then
    echo "Starting with Docker..."
    docker compose up --build
else
    echo "Docker not found. Starting Django dev server directly..."
    echo "Make sure PostgreSQL is running and configured."

    # Activate virtual environment if it exists
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi

    python manage.py migrate
    python manage.py runserver 0.0.0.0:8000
fi
