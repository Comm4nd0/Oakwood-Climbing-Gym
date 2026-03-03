from django.contrib import admin
from .models import (
    MemberProfile, Membership, WallSection, ClimbingRoute,
    RouteLog, GymClass, ClassSchedule, Booking, Announcement, GymInfo,
)


@admin.register(MemberProfile)
class MemberProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'phone', 'climbing_since', 'created_at']
    search_fields = ['user__username', 'user__email', 'phone']


@admin.register(Membership)
class MembershipAdmin(admin.ModelAdmin):
    list_display = ['member', 'membership_type', 'status', 'start_date', 'end_date']
    list_filter = ['membership_type', 'status']
    search_fields = ['member__username']


@admin.register(WallSection)
class WallSectionAdmin(admin.ModelAdmin):
    list_display = ['name', 'wall_type', 'is_active']
    list_filter = ['wall_type', 'is_active']


@admin.register(ClimbingRoute)
class ClimbingRouteAdmin(admin.ModelAdmin):
    list_display = ['name', 'grade', 'color', 'wall_section', 'setter', 'date_set', 'is_active']
    list_filter = ['grade_system', 'color', 'wall_section', 'is_active']
    search_fields = ['name', 'setter']


@admin.register(RouteLog)
class RouteLogAdmin(admin.ModelAdmin):
    list_display = ['climber', 'route', 'attempt_type', 'rating', 'logged_at']
    list_filter = ['attempt_type']
    search_fields = ['climber__username', 'route__name']


@admin.register(GymClass)
class GymClassAdmin(admin.ModelAdmin):
    list_display = ['name', 'instructor', 'difficulty', 'max_participants', 'is_active']
    list_filter = ['difficulty', 'is_active']


@admin.register(ClassSchedule)
class ClassScheduleAdmin(admin.ModelAdmin):
    list_display = ['gym_class', 'day_of_week', 'start_time', 'is_active']
    list_filter = ['day_of_week', 'is_active']


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['member', 'class_schedule', 'date', 'status', 'created_at']
    list_filter = ['status', 'date']
    search_fields = ['member__username']


@admin.register(Announcement)
class AnnouncementAdmin(admin.ModelAdmin):
    list_display = ['title', 'priority', 'is_published', 'publish_date']
    list_filter = ['priority', 'is_published']


@admin.register(GymInfo)
class GymInfoAdmin(admin.ModelAdmin):
    list_display = ['name', 'phone', 'email']
