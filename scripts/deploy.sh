#!/bin/bash

# Scrum Poker LLM - Quick Deploy Script
# Usage: ./scripts/deploy.sh

set -e

echo "🚀 Starting deployment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "✅ .env created. Please edit it before continuing."
    echo "📝 Edit .env and set:"
    echo "   - SECRET_KEY"
    echo "   - POSTGRES_PASSWORD"
    echo "   - VITE_API_URL"
    exit 1
fi

# Build images
echo "🔨 Building Docker images..."
docker compose build

# Run migrations
echo "🗄️  Running database migrations..."
docker compose exec -T backend flask db upgrade || echo "⚠️  Migrations failed or not needed"

# Start services
echo "🎬 Starting services..."
docker compose up -d

# Show status
echo ""
echo "✅ Deployment complete!"
echo ""
docker compose ps
echo ""
echo "📊 View logs: docker compose logs -f"
echo "🛑 Stop services: docker compose down"
echo "🔄 Update: git pull && ./scripts/deploy.sh"
echo ""
echo "🌐 Backend: http://localhost:5000"
echo "🎨 Frontend: Build separately (see DEPLOY.md)"
