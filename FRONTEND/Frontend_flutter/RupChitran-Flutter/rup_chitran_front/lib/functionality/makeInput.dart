import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rup_chitran_front/constants/constant.dart';

Widget makeInput({
  required String label,
  required bool obscureText,
  required TextEditingController controller,
  String? errorText,
  Color borderColor = Colors.grey,
  VoidCallback? onTap,
  bool isPasswordField = false, // New parameter
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(height: 5),
      StatefulBuilder( // Use StatefulBuilder to manage the state of obscureText
        builder: (BuildContext context, StateSetter setState) {
          return TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(5),
              ),
              errorText: errorText,
              errorStyle: kErrorTextstyle,
              suffixIcon: isPasswordField
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    )
                  : null,
            ),
          );
        },
      ),
      SizedBox(height: 30),
    ],
  );
}
