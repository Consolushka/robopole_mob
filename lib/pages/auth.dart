import 'package:flutter/material.dart';
import 'package:robopole_mob/classes.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String login = '';
  String password = '';
  bool isError = false;

  void causedError(){
    setState(() {
      isError = true;
    });
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
                )
              ),
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
                        borderSide: const BorderSide(color: Colors.black54, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            color: Colors.deepOrangeAccent.withOpacity(0.5),
                            width: 2)),
                  ),
                ),
              ),
              Column(
                children: [Container(
                  margin: EdgeInsets.only(bottom: 15),
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
                          borderSide: const BorderSide(color: Colors.black54, width: 2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                              color: Colors.deepOrangeAccent.withOpacity(0.5),
                              width: 2)),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Visibility(child: Text("Неверный логи или пароль", style: TextStyle(color: Colors.red),), visible: isError,),
                )],
              ),
              ElevatedButton(
                  onPressed: () async {
                    var response = await http.post(
                        Uri.parse('http://192.168.1.10:7196/api/v1/user/authenticate'),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({'login':login,'password':password})
                    );
                    print("Response status: ${response.statusCode}");
                    print("Response body: ${response.body}");
                    if(response.statusCode == 400){
                      causedError();
                      return;
                    }
                    User user = new User(response.body);

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt("userId", user.ID as int);
                    await prefs.setString("user", jsonEncode(user.toJson()));
                    final String? counter = prefs.getString('user');
                    print(counter);
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
                  ))
            ],
          ),
        ));
  }
}


// class Auth extends StatelessWidget {
//   Auth({Key? key}) : super(key: key);
//
//   String login = '';
//   String password = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Container(
//       padding: EdgeInsets.all(25),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(bottom: 30),
//             child: const Text(
//               "Войдите в РобоПоле",
//               style: TextStyle(color: Colors.black54, fontSize: 24),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: 15),
//             child: TextField(
//               onChanged: (value) {
//                 login = value;
//               },
//               style: TextStyle(fontSize: 20),
//               decoration: InputDecoration(
//                 hintText: 'Логин',
//                 contentPadding: EdgeInsets.all(10),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(50),
//                     borderSide: BorderSide(color: Colors.black54, width: 2)),
//                 focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(50),
//                     borderSide: BorderSide(
//                         color: Colors.deepOrangeAccent.withOpacity(0.5),
//                         width: 2)),
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: 30),
//             child: TextField(
//               onChanged: (value) {
//                 password = value;
//               },
//               obscureText: true,
//               enableSuggestions: false,
//               autocorrect: false,
//               style: TextStyle(fontSize: 20),
//               decoration: InputDecoration(
//                 hintText: 'Пароль',
//                 contentPadding: EdgeInsets.all(10),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(50),
//                     borderSide: BorderSide(color: Colors.black54, width: 2)),
//                 focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(50),
//                     borderSide: BorderSide(
//                         color: Colors.deepOrangeAccent.withOpacity(0.5),
//                         width: 2)),
//               ),
//             ),
//           ),
//           ElevatedButton(
//               onPressed: () async {
//                 print("Login: $login");
//                 print("Password: $password");
//                 final prefs = await SharedPreferences.getInstance();
//                 await prefs.setInt("userId", 1);
//                 final int? counter = prefs.getInt('userId');
//                 print(counter);
//                 // Navigator.pushAndRemoveUntil(context,
//                 //     MaterialPageRoute(builder: (context) => MapSample()), (route) => false);
//               },
//               child: const Text(
//                 "Войти",
//                 style: TextStyle(fontSize: 20),
//               ),
//               style: ElevatedButton.styleFrom(
//                   primary: Colors.deepOrangeAccent,
//                   padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
//                   shape: new RoundedRectangleBorder(
//                       borderRadius: new BorderRadius.circular(30))))
//         ],
//       ),
//     ));
//   }
// }
