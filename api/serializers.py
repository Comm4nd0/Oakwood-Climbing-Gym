from django.contrib.auth import get_user_model
from rest_framework import serializers

from .models import (
    MemberProfile, Waiver, SafetySignOff,
    MembershipPlan, Membership, PunchCard,
    CheckIn, CapacitySetting,
    WallSection, ClimbingRoute, RouteLog,
    GymClass, ClassSchedule, Booking, BirthdayPartyBooking,
    StaffShift, StaffQualification,
    Announcement, Event, GymInfo,
)


# =============================================================================
# User & Profile
# =============================================================================

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']


class MemberProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    is_under_18 = serializers.BooleanField(read_only=True)
    is_staff_role = serializers.BooleanField(read_only=True)

    class Meta:
        model = MemberProfile
        fields = [
            'id', 'user', 'role', 'phone', 'date_of_birth', 'profile_image',
            'emergency_contact_name', 'emergency_contact_phone',
            'climbing_since', 'is_student', 'is_nhs', 'is_military',
            'is_under_18', 'is_staff_role', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'role', 'created_at', 'updated_at']


# =============================================================================
# Waivers & Safety
# =============================================================================

class WaiverSerializer(serializers.ModelSerializer):
    class Meta:
        model = Waiver
        fields = [
            'id', 'member', 'waiver_type', 'guardian_name', 'guardian_phone',
            'guardian_email', 'guardian_relationship', 'has_medical_conditions',
            'medical_details', 'accepts_terms', 'accepts_photo_consent',
            'signed_at', 'expires_at', 'is_active',
        ]
        read_only_fields = ['id', 'member', 'signed_at']


class SafetySignOffSerializer(serializers.ModelSerializer):
    signed_off_by_name = serializers.CharField(
        source='signed_off_by.get_full_name', read_only=True
    )

    class Meta:
        model = SafetySignOff
        fields = [
            'id', 'member', 'sign_off_type', 'signed_off_by',
            'signed_off_by_name', 'date_signed', 'notes', 'is_active',
        ]
        read_only_fields = ['id', 'date_signed']


# =============================================================================
# Memberships & Pricing
# =============================================================================

class MembershipPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = MembershipPlan
        fields = [
            'id', 'name', 'plan_type', 'price', 'description',
            'is_recurring', 'min_commitment_months',
            'cancellation_notice_months', 'is_active',
        ]


class MembershipSerializer(serializers.ModelSerializer):
    plan_name = serializers.CharField(source='plan.name', read_only=True)
    plan_price = serializers.DecimalField(
        source='plan.price', max_digits=6, decimal_places=2, read_only=True
    )
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Membership
        fields = [
            'id', 'member', 'plan', 'plan_name', 'plan_price',
            'status', 'status_display', 'start_date', 'end_date',
            'frozen_until', 'cancellation_requested_at',
            'cancellation_effective_date', 'auto_renew', 'created_at',
        ]
        read_only_fields = ['id', 'member', 'created_at']


class PunchCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = PunchCard
        fields = ['id', 'member', 'total_visits', 'remaining_visits', 'purchased_at', 'expires_at']
        read_only_fields = ['id', 'member', 'purchased_at']


# =============================================================================
# Check-in & Capacity
# =============================================================================

class CheckInSerializer(serializers.ModelSerializer):
    member_name = serializers.SerializerMethodField()

    class Meta:
        model = CheckIn
        fields = [
            'id', 'member', 'visitor_name', 'member_name', 'entry_type',
            'checked_in_at', 'checked_out_at', 'checked_in_by',
        ]
        read_only_fields = ['id', 'checked_in_at']

    def get_member_name(self, obj):
        if obj.member:
            return obj.member.get_full_name() or obj.member.email
        return obj.visitor_name


class CapacitySerializer(serializers.Serializer):
    current_count = serializers.IntegerField()
    max_capacity = serializers.IntegerField()
    peak_capacity = serializers.IntegerField()
    is_peak = serializers.BooleanField()
    percentage = serializers.IntegerField()


# =============================================================================
# Walls & Routes
# =============================================================================

class WallSectionSerializer(serializers.ModelSerializer):
    wall_type_display = serializers.CharField(source='get_wall_type_display', read_only=True)
    route_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = WallSection
        fields = [
            'id', 'name', 'description', 'wall_type', 'wall_type_display',
            'height_metres', 'image', 'is_active', 'route_count',
        ]


class ClimbingRouteSerializer(serializers.ModelSerializer):
    wall_section_name = serializers.CharField(source='wall_section.name', read_only=True)
    color_display = serializers.CharField(source='get_color_display', read_only=True)

    class Meta:
        model = ClimbingRoute
        fields = [
            'id', 'name', 'grade', 'grade_system', 'color', 'color_display',
            'wall_section', 'wall_section_name', 'setter', 'date_set',
            'date_removed', 'description', 'image', 'is_active', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class RouteLogSerializer(serializers.ModelSerializer):
    route_name = serializers.CharField(source='route.name', read_only=True)
    route_grade = serializers.CharField(source='route.grade', read_only=True)
    route_grade_system = serializers.CharField(source='route.grade_system', read_only=True)
    attempt_type_display = serializers.CharField(source='get_attempt_type_display', read_only=True)
    climber_name = serializers.SerializerMethodField()

    class Meta:
        model = RouteLog
        fields = [
            'id', 'climber', 'climber_name', 'route', 'route_name', 'route_grade',
            'route_grade_system', 'attempt_type', 'attempt_type_display',
            'rating', 'notes', 'logged_at',
        ]
        read_only_fields = ['id', 'climber', 'logged_at']

    def get_climber_name(self, obj):
        user = obj.climber
        if user.first_name:
            return f"{user.first_name} {user.last_name}".strip()
        return user.email.split('@')[0]


# =============================================================================
# Classes & Bookings
# =============================================================================

class ClassScheduleSerializer(serializers.ModelSerializer):
    day_of_week_display = serializers.CharField(source='get_day_of_week_display', read_only=True)

    class Meta:
        model = ClassSchedule
        fields = ['id', 'day_of_week', 'day_of_week_display', 'start_time', 'term_time_only', 'is_active']


class GymClassSerializer(serializers.ModelSerializer):
    difficulty_display = serializers.CharField(source='get_difficulty_display', read_only=True)
    class_type_display = serializers.CharField(source='get_class_type_display', read_only=True)
    age_group_display = serializers.CharField(source='get_age_group_display', read_only=True)
    instructor_name = serializers.SerializerMethodField()
    schedules = ClassScheduleSerializer(many=True, read_only=True)

    class Meta:
        model = GymClass
        fields = [
            'id', 'name', 'class_type', 'class_type_display', 'description',
            'instructor', 'instructor_name', 'difficulty', 'difficulty_display',
            'age_group', 'age_group_display', 'max_participants',
            'duration_minutes', 'price', 'includes_shoe_hire',
            'image', 'is_active', 'schedules',
        ]

    def get_instructor_name(self, obj):
        if obj.instructor:
            return obj.instructor.get_full_name() or obj.instructor.email
        return None


class BookingSerializer(serializers.ModelSerializer):
    class_name = serializers.CharField(source='class_schedule.gym_class.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Booking
        fields = [
            'id', 'member', 'class_schedule', 'class_name', 'date',
            'status', 'status_display', 'participants', 'notes', 'created_at',
        ]
        read_only_fields = ['id', 'member', 'created_at']


class BirthdayPartyBookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = BirthdayPartyBooking
        fields = [
            'id', 'booking', 'child_name', 'child_age', 'num_children',
            'num_adults', 'special_requirements', 'guardian_name', 'guardian_phone',
        ]


# =============================================================================
# Staff
# =============================================================================

class StaffShiftSerializer(serializers.ModelSerializer):
    staff_name = serializers.SerializerMethodField()
    shift_type_display = serializers.CharField(source='get_shift_type_display', read_only=True)
    shift_role_display = serializers.CharField(source='get_shift_role_display', read_only=True)

    class Meta:
        model = StaffShift
        fields = [
            'id', 'staff_member', 'staff_name', 'shift_type', 'shift_type_display',
            'shift_role', 'shift_role_display', 'date', 'start_time', 'end_time',
            'is_key_holder', 'notes', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']

    def get_staff_name(self, obj):
        return obj.staff_member.get_full_name() or obj.staff_member.email


class StaffQualificationSerializer(serializers.ModelSerializer):
    qualification_type_display = serializers.CharField(
        source='get_qualification_type_display', read_only=True
    )

    class Meta:
        model = StaffQualification
        fields = [
            'id', 'staff_member', 'qualification_type', 'qualification_type_display',
            'awarded_date', 'expiry_date', 'certificate_number', 'is_active',
        ]
        read_only_fields = ['id']


# =============================================================================
# Announcements & Events
# =============================================================================

class AnnouncementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Announcement
        fields = [
            'id', 'title', 'content', 'priority', 'image',
            'is_published', 'publish_date', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = [
            'id', 'name', 'description', 'event_date', 'end_date',
            'location', 'price', 'max_participants', 'image',
            'is_published', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class GymInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = GymInfo
        fields = '__all__'
