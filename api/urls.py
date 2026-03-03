from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'profile', views.MemberProfileViewSet, basename='profile')
router.register(r'memberships', views.MembershipViewSet, basename='membership')
router.register(r'walls', views.WallSectionViewSet, basename='wall')
router.register(r'routes', views.ClimbingRouteViewSet, basename='route')
router.register(r'logs', views.RouteLogViewSet, basename='log')
router.register(r'classes', views.GymClassViewSet, basename='class')
router.register(r'bookings', views.BookingViewSet, basename='booking')
router.register(r'announcements', views.AnnouncementViewSet, basename='announcement')
router.register(r'gym-info', views.GymInfoViewSet, basename='gym-info')

urlpatterns = [
    path('', include(router.urls)),
]
