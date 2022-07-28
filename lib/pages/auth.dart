import 'package:flutter/material.dart';
import 'package:robopole_mob/classes.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:http/http.dart' as http;
import 'package:robopole_mob/utils.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String login = '';
  String password = '';
  bool isError = false;
  String errorMessage = '';
  final storage = const FlutterSecureStorage();

  void auth() async{
    var response = await http.post(
        Uri.parse(
            '${Utils.uriAPI}user/authenticate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'login': login, 'password': password}));

    if (response.statusCode == 200) {
      User user = User.fromJson(response.body);

      if (user.MobileAccess as bool) {
        await storage.write(key: "User", value: user.toJson());

        var response = await http.get(
            Uri.parse('${Utils.uriAPI}locationCulture/get-all-cultures'),
            headers: {
              "Authorization": user.Token as String
            }
        );
        if(response.statusCode == 200){
          await storage.write(key: "Cultures", value: response.body);
        }

        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => const MapSample()), (
                route) => false);
        debugPrint(await storage.read(key: "User"));
      }
      else{
        errorMessage = "Нет доступа к мобильному приложению";
        showErrorDialog();
      }
    }
    else{
      debugPrint(response.body);
      debugPrint(utf8.decode(response.bodyBytes));
      var error = Error.fromResponse(response);
      errorMessage = "${error.Message} при обращаении к ${error.Path}";
      showErrorDialog();
    }
  }

  void showErrorDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context)=>AlertDialog(
          title: const Text("Ошибка"),
          content: Text(errorMessage),
          actions: [
            ElevatedButton(
                onPressed: ()=>Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    primary: Colors.red
                ),
                child: const Text("Ok"))
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: const Text(
                    "Войдите в РобоПоле",
                    style: TextStyle(color: Colors.black54, fontSize: 24),
                  )),
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: TextField(
                  onChanged: (value) {
                    login = value;
                  },
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Логин',
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide:
                        const BorderSide(color: Colors.black54, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: Colors.deepOrangeAccent.withOpacity(0.5),
                            width: 2)),
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TextField(
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'Пароль',
                        contentPadding: const EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                            const BorderSide(color: Colors.black54, width: 2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color: Colors.deepOrangeAccent.withOpacity(0.5),
                                width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: auth,
                  style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text(
                    "Войти",
                    style: TextStyle(fontSize: 20),
                  )),
            ],
          ),
        ));
  }
}
