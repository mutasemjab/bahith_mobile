import 'package:baheth/core/utils/bootstrap_icons.dart';
import 'package:baheth/features/home/data/models/home_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home preserves every API category and its backend order', () {
    final home = HomeModel.fromJson(const {
      'categories': [
        {
          'id': 3,
          'name_ar': 'الروضة',
          'name_en': 'Kindergarten',
          'icon': 'bi-stars',
          'subcategories_count': 2,
        },
        {
          'id': 1,
          'name_ar': 'الصفوف الأساسية',
          'name_en': 'Basic Grades',
          'icon': 'bi-backpack2',
          'subcategories_count': 10,
        },
        {
          'id': 2,
          'name_ar': 'التوجيهي',
          'name_en': 'Tawjihi',
          'icon': 'bi-mortarboard',
          'subcategories_count': 2,
        },
      ],
    });

    expect(home.categories.map((category) => category.id), [3, 1, 2]);
    expect(home.categories.first.name, 'الروضة');
    expect(home.categories.first.icon, 'bi-stars');
    expect(home.categories.first.subcategoriesCount, 2);
    expect(bootstrapIconFor('bi-stars'), Icons.auto_awesome_rounded);
  });
}
