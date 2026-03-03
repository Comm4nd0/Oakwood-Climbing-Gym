"""Push notification utilities using Firebase Cloud Messaging."""

import logging

logger = logging.getLogger(__name__)


def send_push_notification(token, title, body, data=None):
    """Send a push notification via Firebase Cloud Messaging."""
    try:
        import firebase_admin
        from firebase_admin import messaging

        if not firebase_admin._apps:
            logger.warning('Firebase not initialized. Skipping notification.')
            return False

        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data=data or {},
            token=token,
        )
        response = messaging.send(message)
        logger.info(f'Notification sent: {response}')
        return True
    except Exception as e:
        logger.error(f'Failed to send notification: {e}')
        return False


def send_booking_confirmation(booking):
    """Send a booking confirmation notification."""
    title = 'Booking Confirmed'
    body = (
        f'Your booking for {booking.class_schedule.gym_class.name} '
        f'on {booking.date} has been confirmed.'
    )
    # In production, retrieve the user's FCM token from their profile
    logger.info(f'Booking confirmation for {booking.member.username}: {body}')


def send_announcement_notification(announcement):
    """Send a notification for a new announcement."""
    title = announcement.title
    body = announcement.content[:200]
    logger.info(f'Announcement notification: {title}')
