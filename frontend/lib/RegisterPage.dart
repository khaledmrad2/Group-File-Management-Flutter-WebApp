import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ia/constant.dart';
import 'package:lottie/lottie.dart';

class registerPage extends StatefulWidget {
  @override
  _registerPageState createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse(MainURL + registerURL),
        headers: SendHeaders,
        body: {
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "password_confirmation": _passwordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register Done Successfully!")),
        );
        Future.delayed(const Duration(seconds: 1))
            .then((value) => {Navigator.pop(context)});
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: Text(response.body),
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
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Card(
                color: Colors.white,
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
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Create New Account !',
                                  style: TextStyle(fontSize: 40),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 500,
                                  child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Name'),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Name is required';
                                        }
                                        if (value.toString().length < 2) {
                                          return 'UserName must be at least 2 character';
                                        }
                                        return null;
                                      }),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                SizedBox(
                                  width: 500,
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                        labelText: 'Email'),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 2) {
                                        return 'Please enter valide email';
                                      }
                                      return null; // Return null if the validation passes
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                SizedBox(
                                  width: 500,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    decoration: const InputDecoration(
                                        labelText: 'Password'),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Password is required';
                                      } else if (value.length < 8) {
                                        return 'Password Must be more than 8 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                SizedBox(
                                  width: 500,
                                  child: TextFormField(
                                    controller: _password2Controller,
                                    decoration: const InputDecoration(
                                        labelText: 'Confirm Password'),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 2) {
                                        if (value != _passwordController.text) {
                                          return 'Confirm Password Not Equal Password!';
                                        }
                                      }
                                      return null; // Return null if the validation passes
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                ElevatedButton(
                                  onPressed: _register,
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
                                    'SignUp',
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
