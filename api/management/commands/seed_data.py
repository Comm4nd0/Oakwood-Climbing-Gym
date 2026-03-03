"""Management command to seed the database with sample data."""

from datetime import date, time
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from api.models import (
    WallSection, ClimbingRoute, GymClass, ClassSchedule,
    GymInfo, Announcement,
)
from django.utils import timezone


class Command(BaseCommand):
    help = 'Seeds the database with sample climbing gym data'

    def handle(self, *args, **options):
        self.stdout.write('Seeding database...')

        # Gym Info
        gym, _ = GymInfo.objects.get_or_create(
            pk=1,
            defaults={
                'name': 'Oakwood Climbing Gym',
                'address': '123 Oakwood Drive\nBoulder, CO 80301',
                'phone': '(303) 555-0142',
                'email': 'info@oakwoodclimbing.com',
                'website': 'https://oakwoodclimbing.com',
                'description': 'Boulder\'s premier indoor climbing facility featuring '
                               'world-class bouldering, top rope, and lead climbing walls.',
            }
        )

        # Wall Sections
        walls = []
        wall_data = [
            ('The Cave', 'bouldering', 'Steep overhanging bouldering cave'),
            ('Slab Wall', 'bouldering', 'Technical slab bouldering wall'),
            ('Main Boulder', 'bouldering', 'Central bouldering area with varied angles'),
            ('North Face', 'top_rope', 'Tall top rope wall with varied routes'),
            ('Lead Tower', 'lead', '15m lead climbing tower'),
            ('Auto Belay Bay', 'auto_belay', 'Six auto belay stations'),
            ('Kids Zone', 'kids', 'Fun climbing area for children'),
        ]
        for name, wall_type, desc in wall_data:
            wall, _ = WallSection.objects.get_or_create(
                name=name, defaults={'wall_type': wall_type, 'description': desc}
            )
            walls.append(wall)

        # Sample Routes
        route_data = [
            ('Crimpy Larry', 'V2', 'v_scale', 'green', walls[0], 'Alex'),
            ('Sloper City', 'V4', 'v_scale', 'blue', walls[0], 'Jordan'),
            ('Balance Beam', 'V1', 'v_scale', 'yellow', walls[1], 'Alex'),
            ('Pinch Me', 'V5', 'v_scale', 'red', walls[2], 'Sam'),
            ('The Dyno', 'V6', 'v_scale', 'purple', walls[2], 'Jordan'),
            ('Smooth Operator', '5.9', 'yds', 'green', walls[3], 'Pat'),
            ('Vertical Limit', '5.11a', 'yds', 'red', walls[3], 'Sam'),
            ('Sky High', '5.10c', 'yds', 'orange', walls[4], 'Pat'),
            ('First Steps', '5.6', 'yds', 'yellow', walls[5], 'Alex'),
            ('Rainbow Road', 'V0', 'v_scale', 'pink', walls[6], 'Jordan'),
        ]
        for name, grade, system, color, wall, setter in route_data:
            ClimbingRoute.objects.get_or_create(
                name=name,
                defaults={
                    'grade': grade, 'grade_system': system, 'color': color,
                    'wall_section': wall, 'setter': setter, 'date_set': date.today(),
                }
            )

        # Gym Classes
        class_data = [
            ('Intro to Climbing', 'Learn the basics of indoor climbing.', 'Staff', 'beginner', 12, 90),
            ('Lead Climbing Clinic', 'Master lead climbing techniques.', 'Pat', 'intermediate', 8, 120),
            ('Advanced Bouldering', 'Push your bouldering to the next level.', 'Jordan', 'advanced', 10, 90),
            ('Youth Climbing Club', 'Fun climbing sessions for kids 6-14.', 'Alex', 'all_levels', 15, 60),
            ('Yoga for Climbers', 'Flexibility and recovery for climbers.', 'Sam', 'all_levels', 20, 60),
        ]
        classes = []
        for name, desc, instructor, diff, max_p, dur in class_data:
            gc, _ = GymClass.objects.get_or_create(
                name=name,
                defaults={
                    'description': desc, 'instructor': instructor,
                    'difficulty': diff, 'max_participants': max_p,
                    'duration_minutes': dur,
                }
            )
            classes.append(gc)

        # Schedules
        schedule_data = [
            (classes[0], 1, '18:00'),  # Intro - Tuesday 6pm
            (classes[0], 5, '10:00'),  # Intro - Saturday 10am
            (classes[1], 3, '19:00'),  # Lead Clinic - Thursday 7pm
            (classes[2], 0, '18:30'),  # Advanced Boulder - Monday 6:30pm
            (classes[2], 4, '18:30'),  # Advanced Boulder - Friday 6:30pm
            (classes[3], 2, '16:00'),  # Youth - Wednesday 4pm
            (classes[3], 5, '11:00'),  # Youth - Saturday 11am
            (classes[4], 0, '07:00'),  # Yoga - Monday 7am
            (classes[4], 3, '07:00'),  # Yoga - Thursday 7am
        ]
        for gc, day, t in schedule_data:
            h, m = t.split(':')
            ClassSchedule.objects.get_or_create(
                gym_class=gc, day_of_week=day,
                defaults={'start_time': time(int(h), int(m))}
            )

        # Announcements
        Announcement.objects.get_or_create(
            title='Welcome to Oakwood Climbing Gym!',
            defaults={
                'content': 'We are thrilled to welcome you to our state-of-the-art climbing facility. '
                           'Check out our new routes and class schedule!',
                'priority': 'normal',
                'publish_date': timezone.now(),
            }
        )
        Announcement.objects.get_or_create(
            title='Route Reset: Main Boulder Area',
            defaults={
                'content': 'The Main Boulder area will be getting a full reset this weekend. '
                           'Exciting new problems coming your way!',
                'priority': 'high',
                'publish_date': timezone.now(),
            }
        )

        self.stdout.write(self.style.SUCCESS('Database seeded successfully!'))
