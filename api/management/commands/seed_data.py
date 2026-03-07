"""Management command to seed the database with sample data for Oakwood Climbing Centre."""

from datetime import date, time
from decimal import Decimal
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from api.models import (
    MemberProfile, MembershipPlan, WallSection, ClimbingRoute,
    GymClass, ClassSchedule, GymInfo, Announcement, CapacitySetting,
)
from django.utils import timezone


class Command(BaseCommand):
    help = 'Seeds the database with Oakwood Climbing Centre sample data'

    def handle(self, *args, **options):
        User = get_user_model()
        self.stdout.write('Seeding Oakwood Climbing Centre database...')

        # Gym Info
        GymInfo.objects.get_or_create(
            pk=1,
            defaults={
                'name': 'Oakwood Climbing Centre',
                'address': 'Waterloo Rd, Bracknell, Wokingham RG40 3DA',
                'phone': '0118 979 2246',
                'email': 'enquiries@oakwoodclimbingcentre.com',
                'website': 'https://www.oakwoodclimbingcentre.com',
                'description': (
                    "Oakwood Climbing Centre is Bracknell's premier indoor climbing facility "
                    "featuring bouldering, roped climbing on 9m walls, auto-belays, "
                    "outdoor bouldering, a kids' zone, training area, and gym."
                ),
                'monday_hours': '10:00 - 22:00',
                'tuesday_hours': '10:00 - 22:00',
                'wednesday_hours': '10:00 - 22:00',
                'thursday_hours': '10:00 - 22:00',
                'friday_hours': '10:00 - 22:00',
                'saturday_hours': '10:00 - 18:00',
                'sunday_hours': '10:00 - 18:00',
                'peak_info': 'Peak times: Mon-Fri after 4pm, all day weekends & bank holidays',
            }
        )

        # Capacity setting
        CapacitySetting.objects.get_or_create(
            pk=1, defaults={'max_capacity': 100, 'peak_capacity': 80}
        )

        # Membership Plans
        plans = [
            ('Monthly Adult', 'monthly_adult', Decimal('45.00'), True, 2, 1),
            ('Monthly Concession', 'monthly_concession', Decimal('38.00'), True, 2, 1),
            ('Monthly Family', 'monthly_family', Decimal('99.00'), True, 2, 1),
            ('Punch Card (10 Visits)', 'punch_card_10', Decimal('110.00'), False, 0, 0),
            ('Day Pass (Peak)', 'day_pass_peak', Decimal('13.00'), False, 0, 0),
            ('Day Pass (Off-Peak)', 'day_pass_offpeak', Decimal('11.00'), False, 0, 0),
            ('Morning Discount', 'day_pass_morning', Decimal('9.00'), False, 0, 0),
            ('Under 18 (Peak)', 'under_18_peak', Decimal('9.00'), False, 0, 0),
            ('Under 18 (Off-Peak)', 'under_18_offpeak', Decimal('6.50'), False, 0, 0),
        ]
        for name, plan_type, price, recurring, min_months, cancel_months in plans:
            MembershipPlan.objects.get_or_create(
                plan_type=plan_type,
                defaults={
                    'name': name, 'price': price, 'is_recurring': recurring,
                    'min_commitment_months': min_months,
                    'cancellation_notice_months': cancel_months,
                }
            )

        # Wall Sections
        walls = {}
        wall_data = [
            ('Main Boulder', 'bouldering', 'Central bouldering area with varied angles', None),
            ('The Cave', 'bouldering', 'Steep overhanging bouldering cave', None),
            ('Slab Wall', 'bouldering', 'Technical slab bouldering', None),
            ('Outdoor Bouldering', 'outdoor', 'Illuminated outdoor bouldering area', None),
            ('North Face', 'top_rope', 'Main roped climbing wall', Decimal('9.0')),
            ('Auto Belay Bay', 'auto_belay', 'Six auto belay stations', Decimal('9.0')),
            ('Lead Tower', 'lead', 'Lead climbing wall', Decimal('9.0')),
            ('Kids Zone', 'kids', "Dedicated area for younger climbers with shorter walls and a slide", None),
            ('Training Area', 'training', 'Fingerboards, campus boards, and training equipment', None),
        ]
        for name, wtype, desc, height in wall_data:
            wall, _ = WallSection.objects.get_or_create(
                name=name,
                defaults={'wall_type': wtype, 'description': desc, 'height_metres': height}
            )
            walls[name] = wall

        # Sample Routes
        route_data = [
            ('Crimpy Larry', 'f4', 'font', 'green', 'Main Boulder', 'Alex',
             'routes/crimpy_larry.jpg', 'Technical crimp-heavy problem with a tricky top-out.'),
            ('Sloper City', 'f5+', 'font', 'blue', 'The Cave', 'Jordan',
             'routes/sloper_city.jpg', 'All slopers, all the time. Keep your hips in!'),
            ('Balance Beam', 'f3', 'font', 'yellow', 'Slab Wall', 'Alex',
             'routes/balance_beam.jpg', 'Delicate slab climbing with small footholds and balance moves.'),
            ('Pinch Me', 'f6a', 'font', 'red', 'Main Boulder', 'Sam',
             'routes/pinch_me.jpg', 'Sustained pinch grips on the 45-degree wall. Strong thumbs required.'),
            ('The Dyno', 'f6b+', 'font', 'purple', 'The Cave', 'Jordan',
             'routes/the_dyno.jpg', 'Big dynamic move to the finishing jug. Commit or fall!'),
            ('Night Moves', 'f5', 'font', 'orange', 'Outdoor Bouldering', 'Pat',
             'routes/night_moves.jpg', 'Fun outdoor problem under the floodlights. Great for evening sessions.'),
            ('Smooth Operator', '5+', 'uk_tech', 'green', 'North Face', 'Pat',
             'routes/smooth_operator.jpg', 'Flowing roped route with good rests. Perfect for warming up.'),
            ('Vertical Limit', '6b', 'uk_tech', 'red', 'North Face', 'Sam',
             'routes/vertical_limit.jpg', 'Sustained and technical. The crux is at two-thirds height.'),
            ('Sky High', '6a', 'uk_tech', 'orange', 'Lead Tower', 'Pat',
             'routes/sky_high.jpg', 'Classic lead route with a pumpy finish. Clip early!'),
            ('First Steps', '4', 'uk_tech', 'yellow', 'Auto Belay Bay', 'Alex',
             'routes/first_steps.jpg', 'Great first route for beginners. Big holds all the way up.'),
            ('Rainbow Road', 'f2', 'font', 'pink', 'Kids Zone', 'Jordan',
             'routes/rainbow_road.jpg', 'Colourful jugs for the little ones. A kids favourite!'),
        ]
        for name, grade, system, color, wall_name, setter, img, desc in route_data:
            ClimbingRoute.objects.get_or_create(
                name=name,
                defaults={
                    'grade': grade, 'grade_system': system, 'color': color,
                    'wall_section': walls[wall_name], 'setter': setter,
                    'date_set': date.today(), 'image': img,
                    'description': desc,
                }
            )

        # Create sample staff user
        staff_user, created = User.objects.get_or_create(
            email='lisa@oakwoodclimbing.com',
            defaults={'first_name': 'Lisa', 'last_name': 'Staff'}
        )
        if created:
            staff_user.set_password('staffpass123')
            staff_user.save()
            MemberProfile.objects.create(
                user=staff_user, role='instructor', phone='07700 900123'
            )

        # Gym Classes (matching real Oakwood offerings)
        class_data = [
            ('Boulder Taster', 'boulder_taster', 'beginner', 'adult', 6, 60, Decimal('20.00'), True,
             'Learn the basics of bouldering. Shoe and chalk hire included, plus a 25% off voucher for your next visit.'),
            ('Auto Belay Induction', 'auto_belay_induction', 'beginner', 'adult', 8, 30, Decimal('10.00'), False,
             'Learn how to safely put on a harness and use the auto belays.'),
            ("Beginner's Rope Course", 'beginner_rope', 'beginner', 'adult', 8, 150, Decimal('60.00'), False,
             'Learn basic rope safety over 2 weeks: tying in, belaying with an ATC, ground anchors, and auto belays.'),
            ('Lead Climbing', 'lead_climbing', 'intermediate', 'adult', 6, 120, Decimal('45.00'), False,
             'Learn about lead climbing risks, belay styles, and how to lead climb and lead belay safely.'),
            ('Coaching Session', 'coaching', 'intermediate', 'adult', 8, 90, Decimal('15.00'), False,
             'Monthly adult coaching focusing on footwork, dynamic movement, body positioning, and session planning.'),
            ('Adult Social', 'adult_social', 'all_levels', 'adult', 20, 120, Decimal('0.00'), False,
             'Meet others, build your climbing network, and improve technique with coach Lisa. Free for members!'),
            ('Private Session', 'private_session', 'all_levels', 'all_ages', 4, 60, Decimal('50.00'), True,
             'Tailored 1-hour instructed session for any age (4+). Adults and children can climb together.'),
            ('Youth Session (5-7)', 'youth_session', 'beginner', 'youth_5_7', 10, 75, Decimal('8.00'), False,
             'Fun introduction to climbing for 5-7 year olds in a supervised group setting.'),
            ('Youth Session (7-12)', 'youth_session', 'all_levels', 'youth_7_12', 12, 75, Decimal('8.00'), False,
             'Climbing sessions for 7-12 year olds, building skills and confidence.'),
            ('Youth Session (13-17)', 'youth_session', 'all_levels', 'youth_13_17', 12, 75, Decimal('8.00'), False,
             'Sessions for teen climbers, developing technique and strength.'),
            ('NICAS Course', 'nicas', 'all_levels', 'youth_7_12', 8, 90, Decimal('12.00'), False,
             'Nationally recognised award scheme for indoor roped climbing, progressing through levels.'),
            ('NIBAS Course', 'nibas', 'all_levels', 'youth_7_12', 8, 90, Decimal('12.00'), False,
             'Nationally recognised award scheme for indoor bouldering, progressing through levels.'),
            ('Birthday Party', 'birthday_party', 'all_levels', 'all_ages', 12, 90, Decimal('150.00'), True,
             'Instructed birthday party for age 5+. Children scale bouldering walls and try auto-belays.'),
        ]
        classes = {}
        for name, ctype, diff, age, max_p, dur, price, shoes, desc in class_data:
            gc, _ = GymClass.objects.get_or_create(
                name=name,
                defaults={
                    'class_type': ctype, 'difficulty': diff, 'age_group': age,
                    'max_participants': max_p, 'duration_minutes': dur,
                    'price': price, 'includes_shoe_hire': shoes,
                    'description': desc, 'instructor': staff_user,
                }
            )
            classes[name] = gc

        # Schedules
        schedule_data = [
            ('Boulder Taster', 5, '10:00'),
            ('Auto Belay Induction', 5, '14:00'),
            ('Adult Social', 3, '19:15'),  # Thursday 7:15pm
            ('Coaching Session', 0, '19:00'),  # Monthly Monday
            ('Youth Session (5-7)', 5, '09:00'),
            ('Youth Session (7-12)', 5, '10:30'),
            ('Youth Session (13-17)', 5, '12:00'),
            ('NICAS Course', 2, '16:30'),  # Wednesday
            ('NIBAS Course', 2, '16:30'),  # Wednesday
        ]
        for class_name, day, t in schedule_data:
            if class_name in classes:
                h, m = t.split(':')
                ClassSchedule.objects.get_or_create(
                    gym_class=classes[class_name], day_of_week=day,
                    defaults={'start_time': time(int(h), int(m))}
                )

        # Announcements
        Announcement.objects.get_or_create(
            title='Welcome to Oakwood Climbing Center!',
            defaults={
                'content': (
                    'Welcome to our state-of-the-art climbing facility featuring '
                    'bouldering, 9m roped walls, auto-belays, outdoor climbing, '
                    "a kids' zone, and training area. No need to book - just turn up!"
                ),
                'priority': 'normal',
                'publish_date': timezone.now(),
            }
        )
        Announcement.objects.get_or_create(
            title='Mighty Oak 2026',
            defaults={
                'content': (
                    "Oakwood's flagship annual bouldering competition returns 28-29 March 2026! "
                    'Featuring world-class routes, a mini marketplace with climbing gear, food, '
                    'limited-edition beer, plus a DJ and live entertainment.'
                ),
                'priority': 'high',
                'publish_date': timezone.now(),
            }
        )

        self.stdout.write(self.style.SUCCESS('Oakwood Climbing Center database seeded successfully!'))
