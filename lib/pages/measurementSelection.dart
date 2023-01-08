import 'package:flutter/material.dart';
import 'package:robopole_mob/utils/classes.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:robopole_mob/pages/measurementField.dart';
import 'package:robopole_mob/pages/passportField.dart';
import 'package:robopole_mob/utils/sofrware_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/dialogs.dart';

class MeasurementSelection extends StatefulWidget {
  const MeasurementSelection({Key? key}) : super(key: key);

  @override
  State<MeasurementSelection> createState() => _MeasurementSelectionState();
}

class _MeasurementSelectionState extends State<MeasurementSelection> {

  Map currentField = Map();

  late User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Замер поля"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MeasurementField()),
                      (route) => true);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Container(
                    height: 160,
                    width: 300,
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: const [
                        Icon(
                          FontAwesomeIcons.xmark,
                          size: 50,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Flexible(
                            child: Text(
                          "Поля нет в РобоПоле (замерить новое)",
                          style: TextStyle(fontSize: 24, color: Colors.black54),
                        ))
                      ],
                    ))),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MapSample()),
                      (route) => true);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Container(
                    height: 160,
                    width: 300,
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 50,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Flexible(
                            child: Text(
                          "Выбрать поле на карте",
                          style: TextStyle(fontSize: 24, color: Colors.black54),
                        ))
                      ],
                    ))),
            ElevatedButton(
                onPressed: () async {
                  showLoader(context);
                  var field = await Software.FindFieldByLocation();
                  if (field.isEmpty) {
                    Navigator.pop(context);
                    setState(() {});
                  } else {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PassportField(
                                  id: field["id"],
                                  isMeasurement: true,
                                )),
                        (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Container(
                    height: 160,
                    width: 300,
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      children: const [
                        Icon(
                          FontAwesomeIcons.arrowsRotate,
                          size: 50,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Flexible(
                            child: Text(
                          "Попробовать еще раз определить автоматически",
                          style: TextStyle(fontSize: 24, color: Colors.black54),
                        ))
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}
