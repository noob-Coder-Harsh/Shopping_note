import 'package:flutter/material.dart';
enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
  carbs
}
class Category {
  const Category(this.title,this.color);
  final String title;
  final Color color;
}