# Oakwood Climbing Centre

A mobile app for **Oakwood Climbing Centre** (Bracknell, UK), built with **Flutter** (Dart) and **Django REST Framework** (Python). Designed for managing both **members** and **staff**.

## Architecture

```
Oakwood-Climbing-Gym/
├── climbing_gym_backend/   # Django project configuration
├── api/                    # Django REST API app
│   ├── models.py           # 18 models: profiles, memberships, check-ins, routes, classes, staff
│   ├── serializers.py      # API serializers
│   ├── views.py            # API viewsets with role-based access
│   ├── urls.py             # URL routing (25+ endpoints)
│   └── management/         # Management commands (seed_data)
├── my_app/                 # Flutter mobile app
│   └── lib/
│       ├── main.dart       # App entry point
│       ├── constants/      # API URLs, Oakwood brand theme
│       ├── models/         # Data models (8 model files)
│       ├── screens/        # Member + Staff screens
│       │   ├── staff/      # Staff Hub, Check-in, Shifts
│       │   └── *.dart      # Home, Routes, Classes, Logbook, Profile, Auth
│       ├── services/       # API & auth services
│       └── widgets/        # Reusable components
├── Dockerfile              # Multi-stage production container
├── docker-compose.yml      # Local dev (PostgreSQL + Django)
└── requirements.txt        # Python dependencies
```

## Features

### Member Features
- **Registration & Waivers** — Sign up, submit waivers (adult + under-18 guardian waivers)
- **Live Capacity** — See how busy the gym is in real-time
- **Route Browsing** — View routes by wall, grade (Font/UK Tech), and colour
- **Route Logging** — Log sends, flashes, attempts, and projects with stats
- **Class Booking** — Boulder tasters, rope courses, lead climbing, NICAS/NIBAS, youth sessions, birthday parties
- **Membership Management** — View status, freeze, request cancellation (1 month notice, 2 month min)
- **Safety Sign-offs** — Track bouldering, auto-belay, top rope, and lead competencies
- **Announcements & Events** — Gym news and events (e.g. Mighty Oak competition)

### Staff Features
- **Staff Hub** — Central dashboard with live capacity counter
- **Check-in/Check-out** — Process member and visitor check-ins
- **Shift Management** — View upcoming shifts, roles, key holder status
- **Booking Management** — View and manage class bookings, mark attendance
- **Safety Sign-offs** — Process climbing competency sign-offs
- **Member Lookup** — Search and manage member profiles
- **Qualifications Tracking** — CWA, CWI, RCI, First Aid, Safeguarding, NICAS/NIBAS tutor

### Gym Configuration
- **Opening Hours** — Mon-Fri 10:00-22:00, Sat-Sun 10:00-18:00
- **Peak Times** — Mon-Fri after 4pm, all day weekends & bank holidays
- **Facilities** — Bouldering, 9m roped walls, auto-belay, outdoor walls, kids zone, training area, gym

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | Django 5.2 + Django REST Framework |
| Database | PostgreSQL 15 |
| Auth | Djoser (Token Authentication) |
| Containerization | Docker + Docker Compose |
| Notifications | Firebase Cloud Messaging |

## Getting Started

### Quick Start (Docker)

```bash
docker compose up --build
```

The API will be available at `http://localhost:8000/api/`.

### Manual Setup

```bash
./scripts/setup.sh
```

### Flutter App

```bash
cd my_app
flutter pub get
flutter run
```

### Seed Sample Data

```bash
python manage.py seed_data
```

## API Endpoints

### Public
| Endpoint | Description |
|----------|-------------|
| `GET /api/routes/` | List climbing routes (filter by wall, grade, colour) |
| `GET /api/walls/` | List wall sections |
| `GET /api/classes/` | List classes (filter by type, age group) |
| `GET /api/announcements/` | List announcements |
| `GET /api/events/` | List upcoming events |
| `GET /api/gym-info/` | Gym information |
| `GET /api/checkins/capacity/` | Live capacity counter |
| `GET /api/membership-plans/` | Available membership plans |

### Member (Authenticated)
| Endpoint | Description |
|----------|-------------|
| `GET /api/profile/me/` | Get your profile |
| `POST /api/waivers/` | Submit a waiver |
| `GET /api/memberships/` | Your memberships |
| `POST /api/memberships/{id}/freeze/` | Freeze membership |
| `POST /api/memberships/{id}/request_cancellation/` | Request cancellation |
| `POST /api/logs/` | Log a climb |
| `GET /api/logs/stats/` | Your climbing stats |
| `POST /api/bookings/` | Book a class |
| `POST /auth/token/login/` | Login |

### Staff
| Endpoint | Description |
|----------|-------------|
| `POST /api/checkins/` | Check in a member/visitor |
| `POST /api/checkins/{id}/checkout/` | Check out |
| `GET /api/staff/shifts/my_shifts/` | Your upcoming shifts |
| `POST /api/safety-signoffs/` | Issue a safety sign-off |
| `POST /api/bookings/{id}/mark_attended/` | Mark booking as attended |

## Package ID

`com.oakwoodclimbinggym.oakwoodclimbinggym`

## Contact

Oakwood Climbing Centre
Waterloo Rd, Bracknell, Wokingham RG40 3DA
0118 979 2246 | enquiries@oakwoodclimbingcentre.com
https://www.oakwoodclimbingcentre.com
