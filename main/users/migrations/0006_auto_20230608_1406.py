# Generated by Django 2.2.19 on 2023-06-08 14:06

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0005_auto_20230608_1404'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='confirm_code',
            field=models.IntegerField(default=226625, verbose_name='Код подтверждения'),
        ),
    ]