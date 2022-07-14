import 'package:flutter/material.dart';
import 'package:robopole_mob/pages/fields.dart';
import 'package:robopole_mob/shared_preference_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatelessWidget {
  Auth({Key? key}) : super(key: key);

  String login = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: const Text(
              "Войдите в РобоПоле",
              style: TextStyle(color: Colors.black54, fontSize: 24),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: TextField(
              onChanged: (value) {
                login = value;
              },
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Логин',
                contentPadding: EdgeInsets.all(10),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.black54, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                        color: Colors.deepOrangeAccent.withOpacity(0.5),
                        width: 2)),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Пароль',
                contentPadding: EdgeInsets.all(10),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.black54, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                        color: Colors.deepOrangeAccent.withOpacity(0.5),
                        width: 2)),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                print("Login: $login");
                print("Password: $password");
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt("userId", 1);
                final int? counter = prefs.getInt('userId');
                print(counter);
                // Navigator.pushAndRemoveUntil(context,
                //     MaterialPageRoute(builder: (context) => MapSample()), (route) => false);
              },
              child: const Text(
                "Войти",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrangeAccent,
                  padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30))))
        ],
      ),
    ));
  }
}
