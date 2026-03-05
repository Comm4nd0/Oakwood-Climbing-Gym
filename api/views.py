from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Count, Q
from django.utils import timezone
from .models import (
    MemberProfile, Waiver, SafetySignOff,
    MembershipPlan, Membership, PunchCard,
    CheckIn, CapacitySetting,
    WallSection, ClimbingRoute, RouteLog,
    GymClass, ClassSchedule, Booking, BirthdayPartyBooking,
    StaffShift, StaffQualification,
    Announcement, Event, GymInfo,
)
from .serializers import (
    MemberProfileSerializer, WaiverSerializer, SafetySignOffSerializer,
    MembershipPlanSerializer, MembershipSerializer, PunchCardSerializer,
    CheckInSerializer, CapacitySerializer,
    WallSectionSerializer, ClimbingRouteSerializer, RouteLogSerializer,
    GymClassSerializer, BookingSerializer, BirthdayPartyBookingSerializer,
    StaffShiftSerializer, StaffQualificationSerializer,
    AnnouncementSerializer, EventSerializer, GymInfoSerializer,
)


class IsStaffRole(permissions.BasePermission):
    """Allow access only to users with a staff role."""
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        profile = getattr(request.user, 'profile', None)
        if profile is None:
            return request.user.is_staff
        return profile.is_staff_role or request.user.is_staff


# =============================================================================
# Profile & Waivers
# =============================================================================

class MemberProfileViewSet(viewsets.ModelViewSet):
    serializer_class = MemberProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if getattr(self.request.user, 'profile', None) and self.request.user.profile.is_staff_role:
            return MemberProfile.objects.all().select_related('user')
        return MemberProfile.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['get', 'patch'], url_path='me')
    def me(self, request):
        profile, _ = MemberProfile.objects.get_or_create(user=request.user)
        if request.method == 'PATCH':
            serializer = MemberProfileSerializer(profile, data=request.data, partial=True)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)
        return Response(MemberProfileSerializer(profile).data)


class WaiverViewSet(viewsets.ModelViewSet):
    serializer_class = WaiverSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if getattr(self.request.user, 'profile', None) and self.request.user.profile.is_staff_role:
            return Waiver.objects.all()
        return Waiver.objects.filter(member=self.request.user)

    def perform_create(self, serializer):
        serializer.save(member=self.request.user)


class SafetySignOffViewSet(viewsets.ModelViewSet):
    serializer_class = SafetySignOffSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if getattr(self.request.user, 'profile', None) and self.request.user.profile.is_staff_role:
            return SafetySignOff.objects.all()
        return SafetySignOff.objects.filter(member=self.request.user)

    def perform_create(self, serializer):
        serializer.save(signed_off_by=self.request.user)


# =============================================================================
# Memberships
# =============================================================================

class MembershipPlanViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = MembershipPlanSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    queryset = MembershipPlan.objects.filter(is_active=True)


class MembershipViewSet(viewsets.ModelViewSet):
    serializer_class = MembershipSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if getattr(self.request.user, 'profile', None) and self.request.user.profile.is_staff_role:
            return Membership.objects.all().select_related('plan')
        return Membership.objects.filter(member=self.request.user).select_related('plan')

    @action(detail=True, methods=['post'])
    def freeze(self, request, pk=None):
        membership = self.get_object()
        if membership.status != 'active':
            return Response(
                {'detail': 'Only active memberships can be frozen.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        frozen_until = request.data.get('frozen_until')
        if not frozen_until:
            return Response(
                {'detail': 'Please provide a frozen_until date.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        membership.status = 'frozen'
        membership.frozen_until = frozen_until
        membership.save()
        return Response(MembershipSerializer(membership).data)

    @action(detail=True, methods=['post'])
    def request_cancellation(self, request, pk=None):
        membership = self.get_object()
        if membership.status in ('cancelled', 'expired'):
            return Response(
                {'detail': 'Membership is already cancelled or expired.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        membership.status = 'pending_cancellation'
        membership.cancellation_requested_at = timezone.now()
        membership.save()
        return Response(MembershipSerializer(membership).data)


class PunchCardViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = PunchCardSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return PunchCard.objects.filter(member=self.request.user)


# =============================================================================
# Check-in & Capacity
# =============================================================================

class CheckInViewSet(viewsets.ModelViewSet):
    serializer_class = CheckInSerializer
    permission_classes = [permissions.IsAuthenticated, IsStaffRole]

    def get_queryset(self):
        queryset = CheckIn.objects.all().select_related('member', 'checked_in_by')
        date = self.request.query_params.get('date')
        active_only = self.request.query_params.get('active')
        if date:
            queryset = queryset.filter(checked_in_at__date=date)
        if active_only == 'true':
            queryset = queryset.filter(checked_out_at__isnull=True)
        return queryset

    def perform_create(self, serializer):
        serializer.save(checked_in_by=self.request.user)

    @action(detail=True, methods=['post'])
    def checkout(self, request, pk=None):
        checkin = self.get_object()
        if checkin.checked_out_at:
            return Response(
                {'detail': 'Already checked out.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        checkin.checked_out_at = timezone.now()
        checkin.save()
        return Response(CheckInSerializer(checkin).data)

    @action(detail=False, methods=['get'], permission_classes=[permissions.AllowAny])
    def capacity(self, request):
        current_count = CheckIn.objects.filter(
            checked_in_at__date=timezone.now().date(),
            checked_out_at__isnull=True,
        ).count()

        setting = CapacitySetting.objects.first()
        max_cap = setting.max_capacity if setting else 100
        peak_cap = setting.peak_capacity if setting else 80

        now = timezone.localtime()
        is_weekday = now.weekday() < 5
        is_peak = (is_weekday and now.hour >= 16) or now.weekday() >= 5

        effective_cap = peak_cap if is_peak else max_cap
        percentage = int((current_count / effective_cap) * 100) if effective_cap > 0 else 0

        return Response(CapacitySerializer({
            'current_count': current_count,
            'max_capacity': max_cap,
            'peak_capacity': peak_cap,
            'is_peak': is_peak,
            'percentage': min(percentage, 100),
        }).data)


# =============================================================================
# Walls & Routes
# =============================================================================

class WallSectionViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = WallSectionSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return WallSection.objects.filter(is_active=True).annotate(
            route_count=Count('routes', filter=Q(routes__is_active=True))
        )


class ClimbingRouteViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = ClimbingRouteSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        queryset = ClimbingRoute.objects.filter(is_active=True).select_related('wall_section')
        wall = self.request.query_params.get('wall_section')
        grade = self.request.query_params.get('grade')
        color = self.request.query_params.get('color')
        if wall:
            queryset = queryset.filter(wall_section_id=wall)
        if grade:
            queryset = queryset.filter(grade=grade)
        if color:
            queryset = queryset.filter(color=color)
        return queryset


class RouteLogViewSet(viewsets.ModelViewSet):
    serializer_class = RouteLogSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return RouteLog.objects.filter(climber=self.request.user).select_related('route', 'climber')

    def perform_create(self, serializer):
        serializer.save(climber=self.request.user)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        logs = RouteLog.objects.filter(climber=request.user)
        return Response({
            'total_logs': logs.count(),
            'total_sends': logs.filter(attempt_type__in=['flash', 'send']).count(),
            'total_flashes': logs.filter(attempt_type='flash').count(),
        })

    @action(detail=False, methods=['get'], url_path='for-route/(?P<route_id>[^/.]+)')
    def for_route(self, request, route_id=None):
        """Return all logs for a specific route from all users."""
        logs = RouteLog.objects.filter(
            route_id=route_id
        ).select_related('route', 'climber').order_by('-logged_at')
        serializer = self.get_serializer(logs, many=True)
        return Response(serializer.data)


# =============================================================================
# Classes & Bookings
# =============================================================================

class GymClassViewSet(viewsets.ModelViewSet):
    serializer_class = GymClassSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticatedOrReadOnly()]
        return [IsStaffRole()]

    def get_queryset(self):
        queryset = GymClass.objects.filter(is_active=True).prefetch_related('schedules')
        class_type = self.request.query_params.get('type')
        age_group = self.request.query_params.get('age_group')
        if class_type:
            queryset = queryset.filter(class_type=class_type)
        if age_group:
            queryset = queryset.filter(age_group=age_group)
        return queryset


class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if getattr(self.request.user, 'profile', None) and self.request.user.profile.is_staff_role:
            return Booking.objects.all().select_related('class_schedule__gym_class')
        return Booking.objects.filter(
            member=self.request.user
        ).select_related('class_schedule__gym_class')

    def perform_create(self, serializer):
        serializer.save(member=self.request.user)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        booking = self.get_object()
        if booking.status == 'cancelled':
            return Response(
                {'detail': 'Booking is already cancelled.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        booking.status = 'cancelled'
        booking.save()
        return Response(BookingSerializer(booking).data)

    @action(detail=True, methods=['post'])
    def mark_attended(self, request, pk=None):
        booking = self.get_object()
        booking.status = 'attended'
        booking.save()
        return Response(BookingSerializer(booking).data)


class BirthdayPartyBookingViewSet(viewsets.ModelViewSet):
    serializer_class = BirthdayPartyBookingSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = BirthdayPartyBooking.objects.all()


# =============================================================================
# Staff Management
# =============================================================================

class StaffShiftViewSet(viewsets.ModelViewSet):
    serializer_class = StaffShiftSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        profile = getattr(user, 'profile', None)

        # Admins/duty managers see all shifts
        if profile and profile.role in ('admin', 'duty_manager'):
            queryset = StaffShift.objects.all()
        elif profile and profile.is_staff_role:
            queryset = StaffShift.objects.filter(staff_member=user)
        else:
            return StaffShift.objects.none()

        date = self.request.query_params.get('date')
        if date:
            queryset = queryset.filter(date=date)
        return queryset.select_related('staff_member')

    @action(detail=False, methods=['get'])
    def my_shifts(self, request):
        shifts = StaffShift.objects.filter(
            staff_member=request.user,
            date__gte=timezone.now().date(),
        ).select_related('staff_member')
        return Response(StaffShiftSerializer(shifts, many=True).data)


class StaffQualificationViewSet(viewsets.ModelViewSet):
    serializer_class = StaffQualificationSerializer
    permission_classes = [permissions.IsAuthenticated, IsStaffRole]

    def get_queryset(self):
        user = self.request.user
        profile = getattr(user, 'profile', None)
        if profile and profile.role in ('admin', 'duty_manager'):
            return StaffQualification.objects.all()
        return StaffQualification.objects.filter(staff_member=user)


# =============================================================================
# Announcements & Events
# =============================================================================

class AnnouncementViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = AnnouncementSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return Announcement.objects.filter(is_published=True)


class EventViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = EventSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return Event.objects.filter(is_published=True, event_date__gte=timezone.now().date())


class GymInfoViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = GymInfoSerializer
    permission_classes = [permissions.AllowAny]
    queryset = GymInfo.objects.all()
