import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showLoader(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SpinKitRing(
            color: Colors.deepOrangeAccent,
            size: 100,
          )
        ],
      );
    },
  );
}

void showErrorDialog(context, errorMessage) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Ошибка"),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: const Text("Ok"))
        ],
      ));
}

void showOKDialog(context, message, setState) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("$message"),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState();
              },
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: const Text("Ok"))
        ],
      ));
}