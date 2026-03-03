from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Count, Q
from .models import (
    MemberProfile, Membership, WallSection, ClimbingRoute,
    RouteLog, GymClass, ClassSchedule, Booking, Announcement, GymInfo,
)
from .serializers import (
    MemberProfileSerializer, MembershipSerializer, WallSectionSerializer,
    ClimbingRouteSerializer, RouteLogSerializer, GymClassSerializer,
    BookingSerializer, AnnouncementSerializer, GymInfoSerializer,
)


class MemberProfileViewSet(viewsets.ModelViewSet):
    serializer_class = MemberProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return MemberProfile.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['get'])
    def me(self, request):
        profile, created = MemberProfile.objects.get_or_create(user=request.user)
        serializer = self.get_serializer(profile)
        return Response(serializer.data)


class MembershipViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = MembershipSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Membership.objects.filter(member=self.request.user)


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
        return RouteLog.objects.filter(
            climber=self.request.user
        ).select_related('route')

    def perform_create(self, serializer):
        serializer.save(climber=self.request.user)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        logs = RouteLog.objects.filter(climber=request.user)
        total = logs.count()
        sends = logs.filter(attempt_type__in=['flash', 'send']).count()
        flashes = logs.filter(attempt_type='flash').count()
        return Response({
            'total_logs': total,
            'total_sends': sends,
            'total_flashes': flashes,
        })


class GymClassViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = GymClassSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return GymClass.objects.filter(is_active=True).prefetch_related('schedules')


class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
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


class AnnouncementViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = AnnouncementSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return Announcement.objects.filter(is_published=True)


class GymInfoViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = GymInfoSerializer
    permission_classes = [permissions.AllowAny]
    queryset = GymInfo.objects.all()
