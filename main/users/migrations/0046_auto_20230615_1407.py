# Generated by Django 2.2.19 on 2023-06-15 14:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0045_auto_20230615_1401'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='confirm_code',
            field=models.IntegerField(default=542207, verbose_name='Код подтверждения'),
        ),
    ]
