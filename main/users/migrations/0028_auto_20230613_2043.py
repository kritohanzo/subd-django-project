# Generated by Django 2.2.19 on 2023-06-13 20:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0027_auto_20230613_1912'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='confirm_code',
            field=models.IntegerField(default=859548, verbose_name='Код подтверждения'),
        ),
    ]
