# Deployment Guide

## Production Deployment on Ubuntu Server

### Prerequisites

- Ubuntu 22.04.2 LTS or later
- Docker and Docker Compose installed
- PostgreSQL 15+ (optional, can use included PostgreSQL container)

### Installation

#### 1. Install Docker and Docker Compose

Use instruction by [link](https://docs.docker.com/engine/install/ubuntu/).

```bash
# Verify installation
docker --version
docker compose version
```

#### 2. Clone Repository

```bash
git clone <your-repo-url>
cd scrum-poker-llm
```

#### 3. Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Edit environment variables
nano .env
```

**Important:** Change these values in `.env`:
- `SECRET_KEY` - Generate a strong random string
- `POSTGRES_PASSWORD` - Use a strong password
- `VITE_API_URL` - Set to your server URL (e.g., `http://your-server-ip:5000`)

#### 4. Build and Start Services

```bash
# Build images
docker compose build

# Start services
docker compose -f docker-compose.prod.yml up -d

# Check status
docker compose ps

# View logs
docker compose -f docker-compose.prod.yml logs -f backend
```

#### 5. Database Migrations

```bash
# Run migrations
docker compose -f docker-compose.prod.yml exec backend alembic upgrade head
```

### Access Application

- **Backend API:** `http://your-server-ip:5000`
- **Frontend:** Build and deploy separately (see Frontend section)

### Frontend Deployment

#### Option 1: Build and Serve Static Files

```bash
# Build frontend
cd frontend
npm run build

# Serve with nginx or similar
# Build output is in frontend/dist/
```

#### Option 2: Deploy to GitHub Pages

```bash
cd frontend
npm run build

# Configure GitHub Pages to serve from gh-pages branch
```

### Maintenance

#### View Logs

```bash
# All services
docker compose -f docker-compose.prod.yml logs -f

# Specific service
docker compose -f docker-compose.prod.yml logs -f backend
```

#### Restart Services

```bash
docker compose -f docker-compose.prod.yml restart
```

#### Stop Services

```bash
docker compose -f docker-compose.prod.yml down
```
