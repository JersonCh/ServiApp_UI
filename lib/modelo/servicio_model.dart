import 'package:flutter/material.dart';

class Servicio {
  final String title;
  final double rating;
  final int reviews;
  final IconData icon;
  final Color color;

  Servicio({
    required this.title,
    required this.rating,
    required this.reviews,
    required this.icon,
    required this.color,
  });
}
