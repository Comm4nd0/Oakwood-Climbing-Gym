from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0003_supportticket_ticketmessage'),
    ]

    operations = [
        migrations.AlterField(
            model_name='climbingroute',
            name='grade',
            field=models.CharField(blank=True, default='', max_length=10),
        ),
    ]
