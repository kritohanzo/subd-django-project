# Generated by Django 2.2.19 on 2023-06-14 17:23

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0041_auto_20230613_2216'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='confirm_code',
            field=models.IntegerField(default=272660, verbose_name='Код подтверждения'),
        ),
    ]
