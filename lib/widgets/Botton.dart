import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  final String title;
  final VoidCallback ontap;

  const Bottom({
    super.key,
    required this.title,
    required this.ontap,
    });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        child: Center(
          child:  Text(
            title,
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
        ),
      ),

    );
  }
}