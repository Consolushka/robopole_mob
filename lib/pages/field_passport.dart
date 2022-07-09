import 'package:flutter/material.dart';

class FieldPassport extends StatelessWidget {
  FieldPassport(this.id);

  final int id;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Паспорт поля ${this.id}"),
        backgroundColor: Colors.deepOrangeAccent.withOpacity(0.8),
      ),
      body: Center(
        child: Text('Поле $id'),
      ),
      backgroundColor: Colors.lightGreen[100],
    );
  }
}
