from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from datetime import date
from decimal import Decimal
from .models import (
    MemberProfile, MembershipPlan, Membership,
    WallSection, ClimbingRoute, GymClass, ClassSchedule,
    Booking, CheckIn, CapacitySetting, SafetySignOff,
)


User = get_user_model()


class ClimbingRouteAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='testclimber@example.com', password='testpass123')
        self.wall = WallSection.objects.create(name='Test Wall', wall_type='bouldering')
        self.route = ClimbingRoute.objects.create(
            name='Test Route', grade='f4', grade_system='font',
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
        self.user = User.objects.create_user(email='testclimber@example.com', password='testpass123')
        self.wall = WallSection.objects.create(name='Test Wall', wall_type='bouldering')
        self.route = ClimbingRoute.objects.create(
            name='Test Route', grade='f4', grade_system='font',
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


class MembershipAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='testmember@example.com', password='testpass123')
        self.plan = MembershipPlan.objects.create(
            name='Monthly Adult', plan_type='monthly_adult',
            price=Decimal('45.00'), is_recurring=True,
            min_commitment_months=2, cancellation_notice_months=1,
        )
        self.membership = Membership.objects.create(
            member=self.user, plan=self.plan, start_date=date.today(),
        )

    def test_list_memberships(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get('/api/memberships/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_freeze_membership(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(
            f'/api/memberships/{self.membership.id}/freeze/',
            {'frozen_until': '2026-04-01'},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'frozen')

    def test_request_cancellation(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(
            f'/api/memberships/{self.membership.id}/request_cancellation/'
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'pending_cancellation')


class CheckInAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.staff_user = User.objects.create_user(email='staffmember@example.com', password='testpass123')
        MemberProfile.objects.create(user=self.staff_user, role='duty_manager')
        CapacitySetting.objects.create(max_capacity=100, peak_capacity=80)

    def test_capacity_public(self):
        response = self.client.get('/api/checkins/capacity/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('current_count', response.data)
        self.assertIn('percentage', response.data)

    def test_checkin_requires_staff(self):
        regular_user = User.objects.create_user(email='regular@example.com', password='testpass123')
        MemberProfile.objects.create(user=regular_user, role='member')
        self.client.force_authenticate(user=regular_user)
        response = self.client.post('/api/checkins/', {
            'visitor_name': 'Test Visitor',
            'entry_type': 'day_pass',
        })
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    def test_checkin_as_staff(self):
        self.client.force_authenticate(user=self.staff_user)
        response = self.client.post('/api/checkins/', {
            'visitor_name': 'Test Visitor',
            'entry_type': 'day_pass',
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)


class BookingAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(email='testclimber@example.com', password='testpass123')
        self.gym_class = GymClass.objects.create(
            name='Boulder Taster', class_type='boulder_taster',
            description='Learn the basics', difficulty='beginner',
            age_group='adult', max_participants=6, duration_minutes=60,
            price=Decimal('20.00'), includes_shoe_hire=True,
        )
        self.schedule = ClassSchedule.objects.create(
            gym_class=self.gym_class, day_of_week=5, start_time='10:00'
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

    def test_mark_attended(self):
        self.client.force_authenticate(user=self.user)
        booking = Booking.objects.create(
            member=self.user, class_schedule=self.schedule, date=date.today()
        )
        response = self.client.post(f'/api/bookings/{booking.id}/mark_attended/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status'], 'attended')


class SafetySignOffAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.staff = User.objects.create_user(email='instructor@example.com', password='testpass123')
        MemberProfile.objects.create(user=self.staff, role='instructor')
        self.member = User.objects.create_user(email='climber@example.com', password='testpass123')

    def test_create_signoff_as_staff(self):
        self.client.force_authenticate(user=self.staff)
        response = self.client.post('/api/safety-signoffs/', {
            'member': self.member.id,
            'sign_off_type': 'bouldering',
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
