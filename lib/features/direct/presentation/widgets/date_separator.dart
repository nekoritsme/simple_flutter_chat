import 'package:flutter/material.dart';

class DateSeparatorWidget extends StatelessWidget {
  const DateSeparatorWidget({super.key, required this.dateString});

  final String dateString;

  @override
  Widget build(BuildContext context) {
    return Text(dateString);
  }
}
