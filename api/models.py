from django.conf import settings
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models


# =============================================================================
# Custom User Model
# =============================================================================

class UserManager(BaseUserManager):
    """Custom manager for User model where email is the unique identifier."""

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Users must have an email address')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)


class User(AbstractUser):
    """Custom user model that uses email instead of username for authentication."""
    username = None
    email = models.EmailField('email address', unique=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    objects = UserManager()

    def __str__(self):
        return self.email


# =============================================================================
# User & Profile Models
# =============================================================================

class MemberProfile(models.Model):
    """Extended user profile for gym members and staff."""
    ROLE_CHOICES = [
        ('member', 'Member'),
        ('staff', 'Staff'),
        ('instructor', 'Instructor'),
        ('duty_manager', 'Duty Manager'),
        ('admin', 'Admin'),
    ]

    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='profile')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='member')
    phone = models.CharField(max_length=20, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    profile_image = models.ImageField(upload_to='profiles/', blank=True, null=True)

    # Emergency contact
    emergency_contact_name = models.CharField(max_length=100, blank=True)
    emergency_contact_phone = models.CharField(max_length=20, blank=True)

    # Member-specific
    climbing_since = models.DateField(null=True, blank=True)

    # Concession eligibility
    is_student = models.BooleanField(default=False)
    is_nhs = models.BooleanField(default=False)
    is_military = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def is_staff_role(self):
        return self.role in ('staff', 'instructor', 'duty_manager', 'admin')

    @property
    def is_under_18(self):
        if not self.date_of_birth:
            return False
        from datetime import date
        today = date.today()
        age = today.year - self.date_of_birth.year
        if (today.month, today.day) < (self.date_of_birth.month, self.date_of_birth.day):
            age -= 1
        return age < 18

    def __str__(self):
        return f"{self.user.get_full_name() or self.user.email} ({self.get_role_display()})"


# =============================================================================
# Waiver & Safety Models
# =============================================================================

class Waiver(models.Model):
    """Safety waivers and pre-registration forms."""
    WAIVER_TYPES = [
        ('adult', 'Adult Waiver'),
        ('under_18', 'Under 18 Guardian Waiver'),
    ]

    member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='waivers')
    waiver_type = models.CharField(max_length=20, choices=WAIVER_TYPES)

    # Guardian details (for under-18 waivers)
    guardian_name = models.CharField(max_length=100, blank=True)
    guardian_phone = models.CharField(max_length=20, blank=True)
    guardian_email = models.EmailField(blank=True)
    guardian_relationship = models.CharField(max_length=50, blank=True)

    # Health & safety
    has_medical_conditions = models.BooleanField(default=False)
    medical_details = models.TextField(blank=True)
    accepts_terms = models.BooleanField(default=False)
    accepts_photo_consent = models.BooleanField(default=False)

    signed_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateField(null=True, blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.member.email} - {self.get_waiver_type_display()}"

    class Meta:
        ordering = ['-signed_at']


class SafetySignOff(models.Model):
    """Tracks safety sign-offs for different climbing activities."""
    SIGN_OFF_TYPES = [
        ('bouldering', 'Bouldering Health & Safety'),
        ('auto_belay', 'Auto Belay Induction'),
        ('top_rope', 'Top Rope Competency'),
        ('lead', 'Lead Climbing Competency'),
    ]

    member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='safety_signoffs')
    sign_off_type = models.CharField(max_length=20, choices=SIGN_OFF_TYPES)
    signed_off_by = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, related_name='signoffs_given'
    )
    date_signed = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.member.email} - {self.get_sign_off_type_display()}"

    class Meta:
        unique_together = ['member', 'sign_off_type']
        ordering = ['-date_signed']


# =============================================================================
# Membership & Pricing Models
# =============================================================================

class MembershipPlan(models.Model):
    """Available membership plans and pricing."""
    PLAN_TYPES = [
        ('monthly_adult', 'Monthly Adult'),
        ('monthly_concession', 'Monthly Concession'),
        ('monthly_family', 'Monthly Family'),
        ('punch_card_10', 'Punch Card (10 Visits)'),
        ('day_pass_peak', 'Day Pass (Peak)'),
        ('day_pass_offpeak', 'Day Pass (Off-Peak)'),
        ('day_pass_morning', 'Morning Discount'),
        ('under_18_peak', 'Under 18 (Peak)'),
        ('under_18_offpeak', 'Under 18 (Off-Peak)'),
    ]

    name = models.CharField(max_length=100)
    plan_type = models.CharField(max_length=30, choices=PLAN_TYPES, unique=True)
    price = models.DecimalField(max_digits=6, decimal_places=2)
    description = models.TextField(blank=True)
    is_recurring = models.BooleanField(default=False)
    min_commitment_months = models.PositiveIntegerField(default=0)
    cancellation_notice_months = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.name} - £{self.price}"

    class Meta:
        ordering = ['price']


class Membership(models.Model):
    """Active memberships for gym members."""
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('frozen', 'Frozen'),
        ('pending_cancellation', 'Pending Cancellation'),
        ('cancelled', 'Cancelled'),
        ('expired', 'Expired'),
    ]

    member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='memberships')
    plan = models.ForeignKey(MembershipPlan, on_delete=models.PROTECT, related_name='memberships')
    status = models.CharField(max_length=25, choices=STATUS_CHOICES, default='active')
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    frozen_until = models.DateField(null=True, blank=True)
    cancellation_requested_at = models.DateTimeField(null=True, blank=True)
    cancellation_effective_date = models.DateField(null=True, blank=True)
    auto_renew = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.member.email} - {self.plan.name} ({self.get_status_display()})"

    class Meta:
        ordering = ['-start_date']


class PunchCard(models.Model):
    """Pre-paid punch cards for pay-per-visit members."""
    member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='punch_cards')
    total_visits = models.PositiveIntegerField(default=10)
    remaining_visits = models.PositiveIntegerField(default=10)
    purchased_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.member.email} - {self.remaining_visits}/{self.total_visits} visits"


# =============================================================================
# Check-in & Capacity Models
# =============================================================================

class CheckIn(models.Model):
    """Member/visitor check-in and check-out records."""
    ENTRY_TYPES = [
        ('membership', 'Membership'),
        ('day_pass', 'Day Pass'),
        ('punch_card', 'Punch Card'),
        ('class_booking', 'Class Booking'),
        ('party', 'Birthday Party'),
        ('spectator', 'Spectator'),
    ]

    member = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name='checkins', null=True, blank=True
    )
    visitor_name = models.CharField(max_length=100, blank=True)
    entry_type = models.CharField(max_length=20, choices=ENTRY_TYPES)
    checked_in_at = models.DateTimeField(auto_now_add=True)
    checked_out_at = models.DateTimeField(null=True, blank=True)
    checked_in_by = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, related_name='checkins_processed'
    )

    @property
    def is_currently_in(self):
        return self.checked_out_at is None

    def __str__(self):
        name = (self.member.get_full_name() or self.member.email) if self.member else self.visitor_name
        return f"{name} - {self.checked_in_at.strftime('%H:%M %d/%m')}"

    class Meta:
        ordering = ['-checked_in_at']


class CapacitySetting(models.Model):
    """Gym capacity limits configuration."""
    max_capacity = models.PositiveIntegerField(default=100)
    peak_capacity = models.PositiveIntegerField(default=80)
    updated_at = models.DateTimeField(auto_now=True)
    updated_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)

    def __str__(self):
        return f"Max: {self.max_capacity}, Peak: {self.peak_capacity}"

    class Meta:
        verbose_name = 'Capacity Setting'
        verbose_name_plural = 'Capacity Settings'


# =============================================================================
# Climbing Wall & Route Models
# =============================================================================

class WallSection(models.Model):
    """Sections/areas of the climbing gym."""
    WALL_TYPES = [
        ('bouldering', 'Bouldering'),
        ('top_rope', 'Top Rope'),
        ('lead', 'Lead'),
        ('auto_belay', 'Auto Belay'),
        ('kids', 'Kids Zone'),
        ('outdoor', 'Outdoor'),
        ('training', 'Training Area'),
    ]

    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    wall_type = models.CharField(max_length=20, choices=WALL_TYPES)
    height_metres = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    image = models.ImageField(upload_to='walls/', blank=True, null=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.name} ({self.get_wall_type_display()})"


class ClimbingRoute(models.Model):
    """Climbing routes/problems set in the gym."""
    GRADE_SYSTEMS = [
        ('v_scale', 'V Scale (Bouldering)'),
        ('font', 'Font Scale'),
        ('yds', 'YDS (Rope)'),
        ('uk_tech', 'UK Technical'),
        ('french', 'French Sport'),
    ]
    COLORS = [
        ('red', 'Red'), ('blue', 'Blue'), ('green', 'Green'),
        ('yellow', 'Yellow'), ('orange', 'Orange'), ('purple', 'Purple'),
        ('pink', 'Pink'), ('white', 'White'), ('black', 'Black'),
    ]

    name = models.CharField(max_length=100)
    grade = models.CharField(max_length=10, blank=True, default='')
    grade_system = models.CharField(max_length=10, choices=GRADE_SYSTEMS, default='font')
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

    climber = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='route_logs')
    route = models.ForeignKey(ClimbingRoute, on_delete=models.CASCADE, related_name='logs')
    attempt_type = models.CharField(max_length=20, choices=ATTEMPT_TYPES)
    rating = models.IntegerField(
        null=True, blank=True,
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    notes = models.TextField(blank=True)
    logged_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.climber.email} - {self.route.name} ({self.get_attempt_type_display()})"

    class Meta:
        ordering = ['-logged_at']


# =============================================================================
# Classes, Courses & Booking Models
# =============================================================================

class GymClass(models.Model):
    """Classes, courses, and sessions offered by the gym."""
    CLASS_TYPES = [
        ('boulder_taster', 'Boulder Taster'),
        ('auto_belay_induction', 'Auto Belay Induction'),
        ('beginner_rope', "Beginner's Rope Course"),
        ('lead_climbing', 'Lead Climbing'),
        ('coaching', 'Coaching Session'),
        ('private_session', 'Private Session'),
        ('adult_social', 'Adult Social'),
        ('youth_session', 'Youth Session'),
        ('nicas', 'NICAS Course'),
        ('nibas', 'NIBAS Course'),
        ('yoga', 'Yoga for Climbers'),
        ('birthday_party', 'Birthday Party'),
    ]
    DIFFICULTY_LEVELS = [
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced'),
        ('all_levels', 'All Levels'),
    ]
    AGE_GROUPS = [
        ('adult', 'Adult (18+)'),
        ('youth_5_7', 'Youth (5-7)'),
        ('youth_7_12', 'Youth (7-12)'),
        ('youth_13_17', 'Youth (13-17)'),
        ('all_ages', 'All Ages (4+)'),
    ]

    name = models.CharField(max_length=100)
    class_type = models.CharField(max_length=25, choices=CLASS_TYPES)
    description = models.TextField()
    instructor = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, blank=True, related_name='classes_taught'
    )
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_LEVELS, default='all_levels')
    age_group = models.CharField(max_length=20, choices=AGE_GROUPS, default='adult')
    max_participants = models.PositiveIntegerField()
    duration_minutes = models.PositiveIntegerField()
    price = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    includes_shoe_hire = models.BooleanField(default=False)
    requires_safety_signoff = models.CharField(
        max_length=20, blank=True,
        help_text='Required SafetySignOff type, if any'
    )
    image = models.ImageField(upload_to='classes/', blank=True, null=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.name} ({self.get_class_type_display()})"

    class Meta:
        verbose_name_plural = 'Gym Classes'


class ClassSchedule(models.Model):
    """Scheduled instances of gym classes."""
    DAYS_OF_WEEK = [
        (0, 'Monday'), (1, 'Tuesday'), (2, 'Wednesday'),
        (3, 'Thursday'), (4, 'Friday'), (5, 'Saturday'), (6, 'Sunday'),
    ]

    gym_class = models.ForeignKey(GymClass, on_delete=models.CASCADE, related_name='schedules')
    day_of_week = models.IntegerField(choices=DAYS_OF_WEEK)
    start_time = models.TimeField()
    term_time_only = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.gym_class.name} - {self.get_day_of_week_display()} {self.start_time}"

    class Meta:
        ordering = ['day_of_week', 'start_time']


class Booking(models.Model):
    """Bookings for gym classes and sessions."""
    STATUS_CHOICES = [
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('waitlisted', 'Waitlisted'),
        ('attended', 'Attended'),
        ('no_show', 'No Show'),
    ]

    member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='bookings')
    class_schedule = models.ForeignKey(ClassSchedule, on_delete=models.CASCADE, related_name='bookings')
    date = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='confirmed')
    participants = models.PositiveIntegerField(default=1)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.member.email} - {self.class_schedule.gym_class.name} ({self.date})"

    class Meta:
        ordering = ['-date']
        unique_together = ['member', 'class_schedule', 'date']


class BirthdayPartyBooking(models.Model):
    """Birthday party specific booking details."""
    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name='party_details')
    child_name = models.CharField(max_length=100)
    child_age = models.PositiveIntegerField()
    num_children = models.PositiveIntegerField()
    num_adults = models.PositiveIntegerField(default=0)
    special_requirements = models.TextField(blank=True)
    guardian_name = models.CharField(max_length=100)
    guardian_phone = models.CharField(max_length=20)

    def __str__(self):
        return f"Party for {self.child_name} (age {self.child_age})"


# =============================================================================
# Staff Management Models
# =============================================================================

class StaffShift(models.Model):
    """Staff shift scheduling."""
    SHIFT_TYPES = [
        ('open', 'Opening'),
        ('close', 'Closing'),
        ('day', 'Day Shift'),
        ('evening', 'Evening Shift'),
        ('weekend', 'Weekend Shift'),
    ]
    SHIFT_ROLES = [
        ('reception', 'Reception'),
        ('instructor', 'Instructor'),
        ('duty_manager', 'Duty Manager'),
        ('route_setter', 'Route Setter'),
        ('general', 'General'),
    ]

    staff_member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='shifts')
    shift_type = models.CharField(max_length=20, choices=SHIFT_TYPES)
    shift_role = models.CharField(max_length=20, choices=SHIFT_ROLES, default='general')
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_key_holder = models.BooleanField(default=False)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.staff_member.email} - {self.get_shift_type_display()} ({self.date})"

    class Meta:
        ordering = ['date', 'start_time']


class StaffQualification(models.Model):
    """Staff climbing and instructing qualifications."""
    QUALIFICATION_TYPES = [
        ('cwa', 'Climbing Wall Award'),
        ('cwi', 'Climbing Wall Instructor'),
        ('rci', 'Rock Climbing Instructor'),
        ('mia', 'Mountain Instructor Award'),
        ('first_aid', 'First Aid'),
        ('safeguarding', 'Safeguarding'),
        ('nicas_tutor', 'NICAS Tutor'),
        ('nibas_tutor', 'NIBAS Tutor'),
    ]

    staff_member = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='qualifications')
    qualification_type = models.CharField(max_length=20, choices=QUALIFICATION_TYPES)
    awarded_date = models.DateField()
    expiry_date = models.DateField(null=True, blank=True)
    certificate_number = models.CharField(max_length=50, blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.staff_member.email} - {self.get_qualification_type_display()}"

    class Meta:
        unique_together = ['staff_member', 'qualification_type']
        ordering = ['-awarded_date']


# =============================================================================
# Announcements & Events Models
# =============================================================================

class Announcement(models.Model):
    """Gym announcements and news."""
    PRIORITY_CHOICES = [
        ('low', 'Low'), ('normal', 'Normal'),
        ('high', 'High'), ('urgent', 'Urgent'),
    ]

    title = models.CharField(max_length=200)
    content = models.TextField()
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='normal')
    image = models.ImageField(upload_to='announcements/', blank=True, null=True)
    is_published = models.BooleanField(default=True)
    publish_date = models.DateTimeField()
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='announcements')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-publish_date']


class Event(models.Model):
    """Special gym events like competitions."""
    name = models.CharField(max_length=200)
    description = models.TextField()
    event_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    location = models.CharField(max_length=200, blank=True)
    price = models.DecimalField(max_digits=6, decimal_places=2, default=0)
    max_participants = models.PositiveIntegerField(null=True, blank=True)
    image = models.ImageField(upload_to='events/', blank=True, null=True)
    is_published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.event_date})"

    class Meta:
        ordering = ['-event_date']


# =============================================================================
# Gym Configuration
# =============================================================================

class GymInfo(models.Model):
    """General gym information."""
    name = models.CharField(max_length=200, default='Oakwood Climbing Centre')
    address = models.TextField(default='Waterloo Rd, Bracknell, Wokingham RG40 3DA')
    phone = models.CharField(max_length=20, default='0118 979 2246')
    email = models.EmailField(default='enquiries@oakwoodclimbingcentre.com')
    website = models.URLField(default='https://www.oakwoodclimbingcentre.com')
    description = models.TextField(blank=True)
    logo = models.ImageField(upload_to='gym/', blank=True, null=True)

    # Operating hours (Mon-Fri 10:00-22:00, Sat-Sun 10:00-18:00)
    monday_hours = models.CharField(max_length=50, default='10:00 - 22:00')
    tuesday_hours = models.CharField(max_length=50, default='10:00 - 22:00')
    wednesday_hours = models.CharField(max_length=50, default='10:00 - 22:00')
    thursday_hours = models.CharField(max_length=50, default='10:00 - 22:00')
    friday_hours = models.CharField(max_length=50, default='10:00 - 22:00')
    saturday_hours = models.CharField(max_length=50, default='10:00 - 18:00')
    sunday_hours = models.CharField(max_length=50, default='10:00 - 18:00')

    # Peak time info
    peak_info = models.TextField(
        default='Peak times: Mon-Fri after 4pm, all day weekends & bank holidays'
    )

    def __str__(self):
        return self.name

    class Meta:
        verbose_name = 'Gym Info'
        verbose_name_plural = 'Gym Info'


# =============================================================================
# Support Tickets
# =============================================================================

class SupportTicket(models.Model):
    """Support tickets submitted by members."""
    CATEGORY_CHOICES = [
        ('general', 'General Enquiry'),
        ('billing', 'Billing & Payments'),
        ('classes', 'Classes & Bookings'),
        ('facilities', 'Facilities & Equipment'),
        ('feedback', 'Feedback & Suggestions'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('in_progress', 'In Progress'),
        ('resolved', 'Resolved'),
        ('closed', 'Closed'),
    ]
    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='support_tickets')
    subject = models.CharField(max_length=200)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='general')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='medium')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"#{self.pk} {self.subject} ({self.get_status_display()})"

    class Meta:
        ordering = ['-updated_at']


class TicketMessage(models.Model):
    """Individual messages within a support ticket thread."""
    ticket = models.ForeignKey(SupportTicket, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='ticket_messages')
    body = models.TextField()
    is_staff_reply = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message on #{self.ticket_id} by {self.sender.email}"

    class Meta:
        ordering = ['created_at']
