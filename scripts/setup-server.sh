#!/bin/bash
# Deployment script for Oakwood Climbing Center API
# Run this ON the Hetzner server as root
#
# Prerequisites:
#   - Docker already installed (shared with p4td)
#   - SSH access as root
#
# Usage: ./scripts/setup-server.sh

set -e

APP_DIR="/opt/oakwood-climbing"
REPO_URL="https://github.com/Comm4nd0/Oakwood-Climbing-Gym.git"
SERVER_IP="178.104.29.66"

echo "=== Oakwood Climbing Center: Server Setup ==="
echo ""

# ============================================================================
# 1. Check Docker is available (should already be installed for p4td)
# ============================================================================
echo "1. Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "   ERROR: Docker not found. Install Docker first or run the p4td setup."
    exit 1
fi
echo "   Docker is available."

# ============================================================================
# 2. Clone repo
# ============================================================================
echo ""
echo "2. Setting up application..."
if [ -d "$APP_DIR" ]; then
    echo "   $APP_DIR already exists, pulling latest..."
    cd "$APP_DIR"
    git pull origin main
else
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

# ============================================================================
# 3. Create .env file
# ============================================================================
echo ""
echo "3. Setting up environment..."
if [ ! -f "$APP_DIR/.env" ]; then
    SECRET_KEY=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 50)
    DB_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 24)

    cat > "$APP_DIR/.env" << EOF
# Django
SECRET_KEY=$SECRET_KEY
DEBUG=False
ALLOWED_HOSTS=$SERVER_IP,localhost,127.0.0.1

# Database
DB_NAME=oakwood_climbing
DB_USER=postgres
DB_PASSWORD=$DB_PASSWORD
DB_HOST=db
DB_PORT=5432

# CORS - allow the Flutter app to connect
CORS_ALLOWED_ORIGINS=http://$SERVER_IP:8001
CORS_ALLOW_ALL_ORIGINS=False
EOF
    echo "   .env created with generated secrets."
    echo "   Review and edit $APP_DIR/.env if needed."
else
    echo "   .env already exists, skipping."
fi

# ============================================================================
# 4. Start the stack
# ============================================================================
echo ""
echo "4. Building and starting services..."
cd "$APP_DIR"
docker compose -f docker-compose.prod.yml up -d --build
echo "   Waiting for services to start..."
sleep 10

# ============================================================================
# 5. Verify
# ============================================================================
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Services:"
docker compose -f docker-compose.prod.yml ps
echo ""
echo "API available at: http://$SERVER_IP:8001"
echo ""
echo "Next steps:"
echo "  1. Create a superuser:"
echo "     cd $APP_DIR"
echo "     docker compose -f docker-compose.prod.yml exec web python manage.py createsuperuser"
echo ""
echo "  2. Update your Flutter app's API URL to: http://$SERVER_IP:8001"
echo ""
echo "Useful commands:"
echo "  cd $APP_DIR"
echo "  docker compose -f docker-compose.prod.yml logs -f        # View logs"
echo "  docker compose -f docker-compose.prod.yml restart web    # Restart app"
echo "  docker compose -f docker-compose.prod.yml down           # Stop all"
echo "  docker compose -f docker-compose.prod.yml up -d --build  # Rebuild & restart"
