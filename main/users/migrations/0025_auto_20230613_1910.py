# Generated by Django 2.2.19 on 2023-06-13 19:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0024_auto_20230613_1908'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='confirm_code',
            field=models.IntegerField(default=553500, verbose_name='Код подтверждения'),
        ),
    ]
