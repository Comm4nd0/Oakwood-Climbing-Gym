from django.core.exceptions import ValidationError
from datetime import date


def validate_future_date(value):
    """Validate that a date is not in the past."""
    if value < date.today():
        raise ValidationError('Date cannot be in the past.')


def validate_grade_v_scale(value):
    """Validate V-scale bouldering grade format (V0-V17)."""
    if not value.startswith('V'):
        raise ValidationError('V-scale grade must start with "V".')
    try:
        num = int(value[1:])
        if num < 0 or num > 17:
            raise ValidationError('V-scale grade must be between V0 and V17.')
    except ValueError:
        raise ValidationError('Invalid V-scale grade format.')
