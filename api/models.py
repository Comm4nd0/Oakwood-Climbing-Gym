from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator


class MemberProfile(models.Model):
    """Extended user profile for gym members."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone = models.CharField(max_length=20, blank=True)
    emergency_contact_name = models.CharField(max_length=100, blank=True)
    emergency_contact_phone = models.CharField(max_length=20, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    profile_image = models.ImageField(upload_to='profiles/', blank=True, null=True)
    climbing_since = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.get_full_name() or self.user.username}"


class Membership(models.Model):
    """Gym membership plans and active memberships."""
    MEMBERSHIP_TYPES = [
        ('day_pass', 'Day Pass'),
        ('monthly', 'Monthly'),
        ('annual', 'Annual'),
        ('student', 'Student'),
        ('family', 'Family'),
    ]
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('expired', 'Expired'),
        ('cancelled', 'Cancelled'),
        ('frozen', 'Frozen'),
    ]

    member = models.ForeignKey(User, on_delete=models.CASCADE, related_name='memberships')
    membership_type = models.CharField(max_length=20, choices=MEMBERSHIP_TYPES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    auto_renew = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.member.username} - {self.get_membership_type_display()}"

    class Meta:
        ordering = ['-start_date']


class WallSection(models.Model):
    """Sections/areas of the climbing gym."""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    wall_type = models.CharField(max_length=50, choices=[
        ('bouldering', 'Bouldering'),
        ('top_rope', 'Top Rope'),
        ('lead', 'Lead'),
        ('auto_belay', 'Auto Belay'),
        ('kids', 'Kids'),
    ])
    image = models.ImageField(upload_to='walls/', blank=True, null=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.name} ({self.get_wall_type_display()})"


class ClimbingRoute(models.Model):
    """Climbing routes/problems set in the gym."""
    GRADE_SYSTEMS = [
        ('v_scale', 'V Scale (Bouldering)'),
        ('yds', 'YDS (Rope)'),
        ('font', 'Font Scale'),
    ]
    COLORS = [
        ('red', 'Red'),
        ('blue', 'Blue'),
        ('green', 'Green'),
        ('yellow', 'Yellow'),
        ('orange', 'Orange'),
        ('purple', 'Purple'),
        ('pink', 'Pink'),
        ('white', 'White'),
        ('black', 'Black'),
    ]

    name = models.CharField(max_length=100)
    grade = models.CharField(max_length=10)
    grade_system = models.CharField(max_length=10, choices=GRADE_SYSTEMS, default='v_scale')
    color = models.CharField(max_length=20, choices=COLORS)
    wall_section = models.ForeignKey(WallSection, on_delete=models.CASCADE, related_name='routes')
    setter = models.CharField(max_length=100)
    date_set = models.DateField()
    date_removed = models.DateField(null=True, blank=True)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='routes/', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.grade}) - {self.wall_section.name}"

    class Meta:
        ordering = ['-date_set']


class RouteLog(models.Model):
    """Log of a member's attempt/send of a route."""
    ATTEMPT_TYPES = [
        ('flash', 'Flash'),
        ('send', 'Send'),
        ('attempt', 'Attempt'),
        ('project', 'Project'),
    ]

    climber = models.ForeignKey(User, on_delete=models.CASCADE, related_name='route_logs')
    route = models.ForeignKey(ClimbingRoute, on_delete=models.CASCADE, related_name='logs')
    attempt_type = models.CharField(max_length=20, choices=ATTEMPT_TYPES)
    rating = models.IntegerField(
        null=True, blank=True,
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    notes = models.TextField(blank=True)
    logged_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.climber.username} - {self.route.name} ({self.get_attempt_type_display()})"

    class Meta:
        ordering = ['-logged_at']


class GymClass(models.Model):
    """Classes and sessions offered by the gym."""
    DIFFICULTY_LEVELS = [
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced'),
        ('all_levels', 'All Levels'),
    ]

    name = models.CharField(max_length=100)
    description = models.TextField()
    instructor = models.CharField(max_length=100)
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_LEVELS)
    max_participants = models.PositiveIntegerField()
    duration_minutes = models.PositiveIntegerField()
    image = models.ImageField(upload_to='classes/', blank=True, null=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.name} ({self.get_difficulty_display()})"

    class Meta:
        verbose_name_plural = 'Gym Classes'


class ClassSchedule(models.Model):
    """Scheduled instances of gym classes."""
    DAYS_OF_WEEK = [
        (0, 'Monday'),
        (1, 'Tuesday'),
        (2, 'Wednesday'),
        (3, 'Thursday'),
        (4, 'Friday'),
        (5, 'Saturday'),
        (6, 'Sunday'),
    ]

    gym_class = models.ForeignKey(GymClass, on_delete=models.CASCADE, related_name='schedules')
    day_of_week = models.IntegerField(choices=DAYS_OF_WEEK)
    start_time = models.TimeField()
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.gym_class.name} - {self.get_day_of_week_display()} {self.start_time}"

    class Meta:
        ordering = ['day_of_week', 'start_time']


class Booking(models.Model):
    """Bookings for gym classes."""
    STATUS_CHOICES = [
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('waitlisted', 'Waitlisted'),
        ('attended', 'Attended'),
        ('no_show', 'No Show'),
    ]

    member = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    class_schedule = models.ForeignKey(ClassSchedule, on_delete=models.CASCADE, related_name='bookings')
    date = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='confirmed')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.member.username} - {self.class_schedule.gym_class.name} ({self.date})"

    class Meta:
        ordering = ['-date']
        unique_together = ['member', 'class_schedule', 'date']


class Announcement(models.Model):
    """Gym announcements and news."""
    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('normal', 'Normal'),
        ('high', 'High'),
        ('urgent', 'Urgent'),
    ]

    title = models.CharField(max_length=200)
    content = models.TextField()
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='normal')
    image = models.ImageField(upload_to='announcements/', blank=True, null=True)
    is_published = models.BooleanField(default=True)
    publish_date = models.DateTimeField()
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='announcements')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-publish_date']


class GymInfo(models.Model):
    """General gym information (singleton-style)."""
    name = models.CharField(max_length=200, default='Oakwood Climbing Gym')
    address = models.TextField()
    phone = models.CharField(max_length=20)
    email = models.EmailField()
    website = models.URLField(blank=True)
    description = models.TextField(blank=True)
    logo = models.ImageField(upload_to='gym/', blank=True, null=True)

    # Operating hours stored as JSON-compatible text
    monday_hours = models.CharField(max_length=50, default='6:00 AM - 10:00 PM')
    tuesday_hours = models.CharField(max_length=50, default='6:00 AM - 10:00 PM')
    wednesday_hours = models.CharField(max_length=50, default='6:00 AM - 10:00 PM')
    thursday_hours = models.CharField(max_length=50, default='6:00 AM - 10:00 PM')
    friday_hours = models.CharField(max_length=50, default='6:00 AM - 9:00 PM')
    saturday_hours = models.CharField(max_length=50, default='8:00 AM - 8:00 PM')
    sunday_hours = models.CharField(max_length=50, default='8:00 AM - 6:00 PM')

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = 'Gym Info'
        verbose_name_plural = 'Gym Info'
