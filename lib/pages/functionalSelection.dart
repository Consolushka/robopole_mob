import 'package:flutter/material.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:robopole_mob/pages/inventory.dart';

class FunctionalPage extends StatefulWidget {
  const FunctionalPage({Key? key}) : super(key: key);

  @override
  State<FunctionalPage> createState() => _FunctionalPageState();
}

class _FunctionalPageState extends State<FunctionalPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Робополе 2022"),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          body: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(2));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: const Text(
                      "Инвентаризация",
                      style: TextStyle(fontSize: 20),
                    )),
                ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(1));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent,
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: const Text(
                      "Информация",
                      style: TextStyle(fontSize: 20),
                    ))
              ],
            ),
          ),
        )
    );
  }
}

Route _createRoute(int functionalId) {
  if(functionalId == 1){
    return PageRouteBuilder(
      pageBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation) {
        return const MapSample();
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation,
          Widget child) {
        return child;
      },
    );
  }
  else{
    return PageRouteBuilder(
      pageBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation) {
        return const Inventory();
      },
      transitionsBuilder: (BuildContext context,
          Animation<double> animation, //
          Animation<double> secondaryAnimation,
          Widget child) {
        return child;
      },
    );
  }
  switch(functionalId){
    case 1:
  }
}
