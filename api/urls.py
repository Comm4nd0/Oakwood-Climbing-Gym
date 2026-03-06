from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()

# Profile & Waivers
router.register(r'profile', views.MemberProfileViewSet, basename='profile')
router.register(r'waivers', views.WaiverViewSet, basename='waiver')
router.register(r'safety-signoffs', views.SafetySignOffViewSet, basename='safety-signoff')

# Memberships
router.register(r'membership-plans', views.MembershipPlanViewSet, basename='membership-plan')
router.register(r'memberships', views.MembershipViewSet, basename='membership')
router.register(r'punch-cards', views.PunchCardViewSet, basename='punch-card')

# Check-in & Capacity
router.register(r'checkins', views.CheckInViewSet, basename='checkin')

# Walls & Routes
router.register(r'walls', views.WallSectionViewSet, basename='wall')
router.register(r'routes', views.ClimbingRouteViewSet, basename='route')
router.register(r'logs', views.RouteLogViewSet, basename='log')

# Classes & Bookings
router.register(r'classes', views.GymClassViewSet, basename='class')
router.register(r'bookings', views.BookingViewSet, basename='booking')
router.register(r'party-bookings', views.BirthdayPartyBookingViewSet, basename='party-booking')

# Staff
router.register(r'staff/shifts', views.StaffShiftViewSet, basename='staff-shift')
router.register(r'staff/qualifications', views.StaffQualificationViewSet, basename='staff-qualification')

# Announcements & Events
router.register(r'announcements', views.AnnouncementViewSet, basename='announcement')
router.register(r'events', views.EventViewSet, basename='event')
router.register(r'gym-info', views.GymInfoViewSet, basename='gym-info')

# Support
router.register(r'support-tickets', views.SupportTicketViewSet, basename='support-ticket')

urlpatterns = [
    path('', include(router.urls)),
]
