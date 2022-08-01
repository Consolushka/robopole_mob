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

    return Scaffold(
          appBar: AppBar(
            title: const Text("Робополе 2022"),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          body: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(2));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: Container(
                      height: 75,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: const [
                          Icon(Icons.add_business, size: 50,color: Colors.black54,),
                          Text(
                            "Инвентаризация",
                            style: TextStyle(fontSize: 10,color: Colors.black54),
                          )
                        ],
                      )
                    )),
                ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(_createRoute(1));
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: Container(
                        height: 75,
                        width: 75,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: const [
                            Icon(Icons.info_outline, size: 50,color: Colors.black54,),
                            Text(
                              "Информация",
                              style: TextStyle(fontSize: 10,color: Colors.black54),
                            )
                          ],
                        )
                    ))
              ],
            ),
          ),
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
