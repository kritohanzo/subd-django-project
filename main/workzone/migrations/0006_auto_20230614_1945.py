# Generated by Django 2.2.19 on 2023-06-14 19:45

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('workzone', '0005_auto_20230614_1723'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='typeproduct',
            options={'verbose_name': 'Необходимый продукт для выполнения работы', 'verbose_name_plural': 'Необходимые продукты для выполнения работы'},
        ),
        migrations.AlterField(
            model_name='order',
            name='client_fullname',
            field=models.CharField(max_length=64, verbose_name='ФИО клиента'),
        ),
    ]
