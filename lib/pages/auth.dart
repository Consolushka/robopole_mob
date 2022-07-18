import 'package:flutter/material.dart';
import 'package:robopole_mob/classes.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  Future authenticate() async {
    var response = await http.post(
        Uri.parse(
            'http://192.168.1.10:7196/api/v1/user/authenticate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'login': login, 'password': password}));

    if(response.statusCode == 200){
      User user = User.fromJson(response.body);
      print(user.toJson());
      if(!user.MobileAccess!){
        causedError("У пользователя нет доступа к мобильному приложению");
        return;
      }
      //
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setInt("userId", user.ID as int);
      // await prefs.setString("user", jsonEncode(user.toJson()));
      // final String? counter = prefs.getString('user');
      // print(counter);
      // Navigator.pushAndRemoveUntil(context,
      //     MaterialPageRoute(builder: (context) => MapSample()), (route) => false);
    }
    else{
      print("Error Message: ${response.body}");
      causedError(response.body);
      return;
    }

    print("everything is fine");
  }

  void causedError(message) {
    setState(() {
      isError = true;
      errorMessage = message;
    });
  }

  void closeErrorDialog(){
    setState((){
      isError = false;
      errorMessage = "";
    });

    Navigator.pop(context);
  }

  Widget handleAuthenticationResult(){
    if (isError) {
      return Expanded(
          child: AlertDialog(
            title: const Text('Ошибка'),
            content: Text(errorMessage),
            actions: [
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  closeErrorDialog();
                },
                child: const Text('Ok'),
              ),
            ],
          ));
    }
    else {
      return Expanded(
          child: AlertDialog(
            title: const Text('Ошибка'),
            content: const Text("Все нормально"),
            actions: [
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  closeErrorDialog();
                },
                child: const Text('Ok'),
              ),
            ],
          ));
    }
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
                  onPressed: () async {
                    // print("Response status: ${response.statusCode}");
                    // print("Response body: ${response.body}");
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FutureBuilder(
                              future: authenticate(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if(snapshot.connectionState==ConnectionState.done){
                                  return handleAuthenticationResult();
                                }
                                else{
                                  return const SpinKitRing(
                                    color: Colors.deepOrangeAccent,
                                    size: 100,
                                  );
                                }
                              });
                        });
                    // if (response.statusCode == 400) {
                    //   // causedError();
                    //   //
                    //   // return;
                    // }
                    // User user = new User(response.body);
                    //
                    // final prefs = await SharedPreferences.getInstance();
                    // await prefs.setInt("userId", user.ID as int);
                    // await prefs.setString("user", jsonEncode(user.toJson()));
                    // final String? counter = prefs.getString('user');
                    // print(counter);
                    // Navigator.pushAndRemoveUntil(context,
                    //     MaterialPageRoute(builder: (context) => MapSample()), (route) => false);
                  },
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
