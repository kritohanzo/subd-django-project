# Generated by Django 2.2.19 on 2023-06-13 19:11

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0025_auto_20230613_1910'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='confirm_code',
            field=models.IntegerField(default=838517, verbose_name='Код подтверждения'),
        ),
    ]
