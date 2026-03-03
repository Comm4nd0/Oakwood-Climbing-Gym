# Oakwood Climbing Gym

A mobile app and backend for the Oakwood Climbing Gym, built with **Flutter** (Dart) and **Django REST Framework** (Python).

## Architecture

```
Oakwood-Climbing-Gym/
├── climbing_gym_backend/   # Django project configuration
├── api/                    # Django REST API app
│   ├── models.py           # Database models
│   ├── serializers.py      # API serializers
│   ├── views.py            # API viewsets
│   ├── urls.py             # URL routing
│   └── management/         # Management commands (seed_data)
├── my_app/                 # Flutter mobile app
│   └── lib/
│       ├── main.dart       # App entry point
│       ├── constants/      # API URLs, theme
│       ├── models/         # Data models
│       ├── screens/        # UI screens
│       ├── services/       # API & auth services
│       └── widgets/        # Reusable components
├── templates/              # Django admin templates
├── scripts/                # Setup & dev scripts
├── Dockerfile              # Production container
├── docker-compose.yml      # Local dev environment
└── requirements.txt        # Python dependencies
```

## Features

- **Route Browsing** — View all climbing routes by wall section, grade, and color
- **Route Logging** — Log sends, flashes, attempts, and projects
- **Class Booking** — Browse gym classes and book sessions
- **Membership Management** — View membership status and details
- **Announcements** — Stay up to date with gym news
- **User Authentication** — Token-based auth via Djoser

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | Django + Django REST Framework |
| Database | PostgreSQL |
| Auth | Djoser (Token Authentication) |
| Containerization | Docker + Docker Compose |
| Storage | django-storages + boto3 (S3) |
| Notifications | Firebase Cloud Messaging |

## Getting Started

### Quick Start (Docker)

```bash
docker compose up --build
```

The API will be available at `http://localhost:8000/api/`.

### Manual Setup

```bash
# Run the setup script
./scripts/setup.sh

# Or manually:
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py seed_data
python manage.py runserver
```

### Flutter App

```bash
cd my_app
flutter pub get
flutter run
```

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/routes/` | List climbing routes |
| `GET /api/walls/` | List wall sections |
| `GET /api/classes/` | List gym classes |
| `GET /api/announcements/` | List announcements |
| `GET /api/gym-info/` | Gym information |
| `POST /api/logs/` | Log a climb |
| `GET /api/logs/stats/` | Climbing statistics |
| `POST /api/bookings/` | Book a class |
| `POST /auth/token/login/` | Login |
| `POST /auth/users/` | Register |

## Package ID

`com.oakwoodclimbinggym.oakwoodclimbinggym`
