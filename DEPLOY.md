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
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f backend
```

#### 5. Database Migrations

```bash
# Run migrations
docker compose exec backend flask db upgrade
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
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f db
```

#### Restart Services

```bash
docker compose restart
```

#### Stop Services

```bash
docker compose down
```

#### Update Application

```bash
# Pull latest code
git pull

# Rebuild and restart
docker compose build
docker compose up -d

# Run migrations if needed
docker compose exec backend flask db upgrade
```

### Backup

#### Backup PostgreSQL Data

```bash
# Create backup directory
mkdir -p backups

# Backup database
docker compose exec db pg_dump -U scrum_poker scrum_poker > backups/backup-$(date +%Y%m%d).sql

# Restore from backup
cat backups/backup-20240101.sql | docker compose exec -T db psql -U scrum_poker scrum_poker
```

#### Backup Location

PostgreSQL data is stored in Docker volume `pgdata`. To backup:

```bash
docker run --rm -v scrum-poker-pgdata:/data -v $(pwd):/backup alpine tar czf /backup/pgdata-backup-$(date +%Y%m%d).tar.gz /data
```

### Security Recommendations

1. **Use HTTPS:** Setup nginx reverse proxy with SSL
2. **Change default passwords:** Always change in `.env`
3. **Firewall:** Only expose necessary ports (80, 443)
4. **Regular updates:** Keep Docker and system packages updated
5. **Secrets management:** Use Docker secrets or environment variables from secure source

### Troubleshooting

#### Backend won't start

```bash
# Check logs
docker compose logs backend

# Check database connection
docker compose exec backend python -c "from app import db; print(db.engine.url)"
```

#### Database connection issues

```bash
# Check if database is running
docker compose ps db

# Check database logs
docker compose logs db

# Test connection
docker compose exec backend python -c "import psycopg2; psycopg2.connect('postgresql://scrum_poker:password@db:5432/scrum_poker')"
```

#### Migration errors

```bash
# Check current migration status
docker compose exec backend flask db current

# Run migrations
docker compose exec backend flask db upgrade

# If stuck, try
docker compose exec backend flask db stamp head
```

### Monitoring

#### Check Resource Usage

```bash
docker compose stats
```

#### Health Check

```bash
# Backend health
curl http://localhost:5000/api/rooms

# Database health
docker compose exec db pg_isready -U scrum_poker
```
