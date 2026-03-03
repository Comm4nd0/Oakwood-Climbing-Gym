from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from .models import WallSection, ClimbingRoute, GymClass, ClassSchedule, Booking


class ClimbingRouteAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testclimber', password='testpass123'
        )
        self.wall = WallSection.objects.create(
            name='Test Wall', wall_type='bouldering'
        )
        self.route = ClimbingRoute.objects.create(
            name='Test Route', grade='V3', grade_system='v_scale',
            color='red', wall_section=self.wall, setter='Tester',
            date_set=date.today(),
        )

    def test_list_routes_unauthenticated(self):
        response = self.client.get('/api/routes/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_list_routes_authenticated(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get('/api/routes/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['results']), 1)

    def test_route_detail(self):
        response = self.client.get(f'/api/routes/{self.route.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['name'], 'Test Route')


class RouteLogAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testclimber', password='testpass123'
        )
        self.wall = WallSection.objects.create(
            name='Test Wall', wall_type='bouldering'
        )
        self.route = ClimbingRoute.objects.create(
            name='Test Route', grade='V3', grade_system='v_scale',
            color='red', wall_section=self.wall, setter='Tester',
            date_set=date.today(),
        )

    def test_create_log_authenticated(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post('/api/logs/', {
            'route': self.route.id,
            'attempt_type': 'send',
            'rating': 4,
            'notes': 'Great route!',
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_log_unauthenticated(self):
        response = self.client.post('/api/logs/', {
            'route': self.route.id,
            'attempt_type': 'send',
        })
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_log_stats(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get('/api/logs/stats/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('total_logs', response.data)


class BookingAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username='testclimber', password='testpass123'
        )
        self.gym_class = GymClass.objects.create(
            name='Test Class', description='A test class',
            instructor='Test', difficulty='beginner',
            max_participants=10, duration_minutes=60,
        )
        self.schedule = ClassSchedule.objects.create(
            gym_class=self.gym_class, day_of_week=0, start_time='18:00'
        )

    def test_create_booking(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post('/api/bookings/', {
            'class_schedule': self.schedule.id,
            'date': date.today().isoformat(),
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_cancel_booking(self):
        self.client.force_authenticate(user=self.user)
        booking = Booking.objects.create(
            member=self.user, class_schedule=self.schedule, date=date.today()
        )
        response = self.client.post(f'/api/bookings/{booking.id}/cancel/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'cancelled')
