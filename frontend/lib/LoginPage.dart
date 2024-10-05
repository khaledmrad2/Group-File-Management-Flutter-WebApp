import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ia/HomePage.dart';
import 'package:ia/RegisterPage.dart';
import 'package:ia/constant.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final SharedPreferences prefs;

  LoginPage(this.prefs);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse(MainURL + LoginURL),
        headers: SendHeaders,
        body: {
          "email": _emailController.text,
          "password": _passwordController.text,
        },
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var Mapvalue = json.decode(response.body);

        User user = User.fromJson(Mapvalue);
        await widget.prefs.setString('token', user.token);
        await widget.prefs.setString('user_id', user.id.toString());
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(widget.prefs)),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: const Text('Email or Password is Wrong'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Card(
              color: Colors.white,
              // elevation: 23.0,
              child: Form(
                key: _formKey,
                child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      children: [
                        Expanded(
                            child: Lottie.asset(
                          'assets/images/a.json',
                        )),
                        const SizedBox(
                          width: 50,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 40),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Container(
                                  width: 500,
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                        labelText: 'Email'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter valide email';
                                      }
                                      return null; // Return null if the validation passes
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  width: 500,
                                  child: TextFormField(
                                      controller: _passwordController,
                                      decoration: const InputDecoration(
                                          labelText: 'Password'),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Password is required';
                                        } else if (value!.length < 8) {
                                          return 'Password Must be more than 8 characters';
                                        }
                                        return null;
                                      }),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Not Have An Account ? ",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    registerPage()),
                                          );
                                        },
                                        child: const Text(
                                          "Create Now ! ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.blueAccent),
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.green,
                                      // Change the text color
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      // Change padding
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Change border radius
                                      ),
                                      fixedSize: const Size(500, 50)),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 18), // Change text size
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['data']['id'] as int,
      name: json['data']['name'] as String,
      email: json['data']['email'] as String,
      token: json['data']['token'] as String,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, token: $token}';
  }
}
