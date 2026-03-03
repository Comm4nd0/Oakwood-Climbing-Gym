from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    MemberProfile, Membership, WallSection, ClimbingRoute,
    RouteLog, GymClass, ClassSchedule, Booking, Announcement, GymInfo,
)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']


class MemberProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = MemberProfile
        fields = [
            'id', 'user', 'phone', 'emergency_contact_name',
            'emergency_contact_phone', 'date_of_birth', 'profile_image',
            'climbing_since', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class MembershipSerializer(serializers.ModelSerializer):
    membership_type_display = serializers.CharField(
        source='get_membership_type_display', read_only=True
    )
    status_display = serializers.CharField(
        source='get_status_display', read_only=True
    )

    class Meta:
        model = Membership
        fields = [
            'id', 'member', 'membership_type', 'membership_type_display',
            'status', 'status_display', 'start_date', 'end_date',
            'auto_renew', 'created_at',
        ]
        read_only_fields = ['id', 'member', 'created_at']


class WallSectionSerializer(serializers.ModelSerializer):
    wall_type_display = serializers.CharField(
        source='get_wall_type_display', read_only=True
    )
    route_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = WallSection
        fields = [
            'id', 'name', 'description', 'wall_type', 'wall_type_display',
            'image', 'is_active', 'route_count',
        ]


class ClimbingRouteSerializer(serializers.ModelSerializer):
    wall_section_name = serializers.CharField(
        source='wall_section.name', read_only=True
    )
    color_display = serializers.CharField(
        source='get_color_display', read_only=True
    )

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
    attempt_type_display = serializers.CharField(
        source='get_attempt_type_display', read_only=True
    )

    class Meta:
        model = RouteLog
        fields = [
            'id', 'climber', 'route', 'route_name', 'route_grade',
            'attempt_type', 'attempt_type_display', 'rating', 'notes',
            'logged_at',
        ]
        read_only_fields = ['id', 'climber', 'logged_at']


class ClassScheduleSerializer(serializers.ModelSerializer):
    day_of_week_display = serializers.CharField(
        source='get_day_of_week_display', read_only=True
    )

    class Meta:
        model = ClassSchedule
        fields = ['id', 'day_of_week', 'day_of_week_display', 'start_time', 'is_active']


class GymClassSerializer(serializers.ModelSerializer):
    difficulty_display = serializers.CharField(
        source='get_difficulty_display', read_only=True
    )
    schedules = ClassScheduleSerializer(many=True, read_only=True)

    class Meta:
        model = GymClass
        fields = [
            'id', 'name', 'description', 'instructor', 'difficulty',
            'difficulty_display', 'max_participants', 'duration_minutes',
            'image', 'is_active', 'schedules',
        ]


class BookingSerializer(serializers.ModelSerializer):
    class_name = serializers.CharField(
        source='class_schedule.gym_class.name', read_only=True
    )
    status_display = serializers.CharField(
        source='get_status_display', read_only=True
    )

    class Meta:
        model = Booking
        fields = [
            'id', 'member', 'class_schedule', 'class_name', 'date',
            'status', 'status_display', 'created_at',
        ]
        read_only_fields = ['id', 'member', 'created_at']


class AnnouncementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Announcement
        fields = [
            'id', 'title', 'content', 'priority', 'image',
            'is_published', 'publish_date', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class GymInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = GymInfo
        fields = '__all__'
