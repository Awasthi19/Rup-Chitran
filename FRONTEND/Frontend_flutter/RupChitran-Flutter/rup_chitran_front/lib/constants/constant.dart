import 'package:flutter/material.dart';
import 'package:path/path.dart';


const kErrorTextstyle=TextStyle(color: Colors.red, fontSize: 12);

  void showErrorDialog(BuildContext context,{required String err}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
    
          title: Text('Error'),
          content: Text(err!=null?err:'Something went wrong'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }