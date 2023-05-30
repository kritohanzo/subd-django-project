# Generated by Django 2.2.19 on 2023-05-29 06:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_auto_20230529_0601'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='confirmed',
            field=models.BooleanField(default=False, verbose_name='Подтверждено'),
        ),
        migrations.AddField(
            model_name='user',
            name='confirmed_code',
            field=models.CharField(default=0, max_length=32, verbose_name='Код подтверждения'),
            preserve_default=False,
        ),
    ]