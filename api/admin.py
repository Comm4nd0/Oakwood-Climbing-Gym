from django.contrib import admin
from django.contrib.auth import get_user_model
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import (
    MemberProfile, Waiver, SafetySignOff,
    MembershipPlan, Membership, PunchCard,
    CheckIn, CapacitySetting,
    WallSection, ClimbingRoute, RouteLog,
    GymClass, ClassSchedule, Booking, BirthdayPartyBooking,
    StaffShift, StaffQualification,
    Announcement, Event, GymInfo,
)

User = get_user_model()


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    ordering = ['email']
    list_display = ['email', 'first_name', 'last_name', 'is_staff']
    search_fields = ['email', 'first_name', 'last_name']
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'first_name', 'last_name', 'password1', 'password2'),
        }),
    )


# User & Profile
@admin.register(MemberProfile)
class MemberProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'role', 'phone', 'is_student', 'is_nhs', 'is_military', 'created_at']
    list_filter = ['role', 'is_student', 'is_nhs', 'is_military']
    search_fields = ['user__email', 'user__email', 'phone']


# Waivers & Safety
@admin.register(Waiver)
class WaiverAdmin(admin.ModelAdmin):
    list_display = ['member', 'waiver_type', 'accepts_terms', 'signed_at', 'is_active']
    list_filter = ['waiver_type', 'is_active']
    search_fields = ['member__email', 'guardian_name']


@admin.register(SafetySignOff)
class SafetySignOffAdmin(admin.ModelAdmin):
    list_display = ['member', 'sign_off_type', 'signed_off_by', 'date_signed', 'is_active']
    list_filter = ['sign_off_type', 'is_active']
    search_fields = ['member__email']


# Memberships & Pricing
@admin.register(MembershipPlan)
class MembershipPlanAdmin(admin.ModelAdmin):
    list_display = ['name', 'plan_type', 'price', 'is_recurring', 'is_active']
    list_filter = ['plan_type', 'is_recurring', 'is_active']


@admin.register(Membership)
class MembershipAdmin(admin.ModelAdmin):
    list_display = ['member', 'plan', 'status', 'start_date', 'end_date', 'auto_renew']
    list_filter = ['status', 'plan']
    search_fields = ['member__email']


@admin.register(PunchCard)
class PunchCardAdmin(admin.ModelAdmin):
    list_display = ['member', 'remaining_visits', 'total_visits', 'purchased_at']
    search_fields = ['member__email']


# Check-in & Capacity
@admin.register(CheckIn)
class CheckInAdmin(admin.ModelAdmin):
    list_display = ['get_name', 'entry_type', 'checked_in_at', 'checked_out_at', 'checked_in_by']
    list_filter = ['entry_type']
    search_fields = ['member__email', 'visitor_name']

    def get_name(self, obj):
        return obj.member.email if obj.member else obj.visitor_name
    get_name.short_description = 'Name'


@admin.register(CapacitySetting)
class CapacitySettingAdmin(admin.ModelAdmin):
    list_display = ['max_capacity', 'peak_capacity', 'updated_at']


# Walls & Routes
@admin.register(WallSection)
class WallSectionAdmin(admin.ModelAdmin):
    list_display = ['name', 'wall_type', 'height_metres', 'is_active']
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
    search_fields = ['climber__email', 'route__name']


# Classes & Bookings
class ClassScheduleInline(admin.TabularInline):
    model = ClassSchedule
    extra = 1


@admin.register(GymClass)
class GymClassAdmin(admin.ModelAdmin):
    list_display = ['name', 'class_type', 'instructor', 'difficulty', 'age_group', 'price', 'is_active']
    list_filter = ['class_type', 'difficulty', 'age_group', 'is_active']
    inlines = [ClassScheduleInline]


@admin.register(ClassSchedule)
class ClassScheduleAdmin(admin.ModelAdmin):
    list_display = ['gym_class', 'day_of_week', 'start_time', 'term_time_only', 'is_active']
    list_filter = ['day_of_week', 'term_time_only', 'is_active']


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['member', 'class_schedule', 'date', 'status', 'participants', 'created_at']
    list_filter = ['status', 'date']
    search_fields = ['member__email']


@admin.register(BirthdayPartyBooking)
class BirthdayPartyBookingAdmin(admin.ModelAdmin):
    list_display = ['child_name', 'child_age', 'num_children', 'guardian_name', 'guardian_phone']
    search_fields = ['child_name', 'guardian_name']


# Staff
@admin.register(StaffShift)
class StaffShiftAdmin(admin.ModelAdmin):
    list_display = ['staff_member', 'shift_type', 'shift_role', 'date', 'start_time', 'end_time', 'is_key_holder']
    list_filter = ['shift_type', 'shift_role', 'date', 'is_key_holder']
    search_fields = ['staff_member__email']


@admin.register(StaffQualification)
class StaffQualificationAdmin(admin.ModelAdmin):
    list_display = ['staff_member', 'qualification_type', 'awarded_date', 'expiry_date', 'is_active']
    list_filter = ['qualification_type', 'is_active']
    search_fields = ['staff_member__email']


# Announcements & Events
@admin.register(Announcement)
class AnnouncementAdmin(admin.ModelAdmin):
    list_display = ['title', 'priority', 'is_published', 'publish_date']
    list_filter = ['priority', 'is_published']


@admin.register(Event)
class EventAdmin(admin.ModelAdmin):
    list_display = ['name', 'event_date', 'price', 'max_participants', 'is_published']
    list_filter = ['is_published']


@admin.register(GymInfo)
class GymInfoAdmin(admin.ModelAdmin):
    list_display = ['name', 'phone', 'email']
