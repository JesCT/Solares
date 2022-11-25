import 'package:flutter/material.dart';
import 'package:solares/navigator_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 30.0),
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SOLARES energía sustentable',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'NerkoOne',
                            fontSize: 30.0),
                      ),
                      const Divider(height: 25.0),
                      const CircleAvatar(
                        radius: 100.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage('images/logo.png'),
                      ),
                      const Text(
                        'Iniciar sesión',
                        style:
                            TextStyle(fontFamily: 'NerkoOne', fontSize: 30.0),
                      ),
                      SizedBox(
                        width: 400.0,
                        child: TextField(
                          enableInteractiveSelection: false,
                          autofocus: true,
                          controller: emailController,
                          decoration: InputDecoration(
                              hintText: 'Ingrese su suario',
                              labelText: 'Usuario',
                              suffixIcon: const Icon(Icons.verified_user),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                        ),
                      ),
                      const Divider(height: 25.0),
                      SizedBox(
                        width: 400.00,
                        child: TextField(
                          enableInteractiveSelection: false,
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Ingrese su contraseña',
                            labelText: 'Contraseña',
                            suffixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        height: 12.0,
                      ),
                      Visibility(
                        visible: isVisible,
                        child: const Text(
                          'Contraseña o usuario incorrecto vuelba a intentarlo',
                          style: TextStyle(
                            fontFamily: 'NerkoOne',
                            fontWeight: FontWeight.w300,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 12.0,
                      ),
                      MaterialButton(
                        minWidth: 400.0,
                        height: 50.0,
                        onPressed: () {
                          if (emailController.text != "" ||
                              passwordController.text != "") {
                            setState(() {
                              _isLoading = true;
                            });
                            //signIn("acuramee@gmail.com", "LosInfernos");
                            signIn(
                              emailController.text,
                              passwordController.text,
                            );
                          }
                        },
                        color: const Color.fromARGB(255, 25, 33, 61),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(
                              fontFamily: 'NerkoOne',
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }

  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};

    var response = await http.post(
      Uri.parse('http://172.17.251.219/api/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });

        if (jsonResponse['estado'] == 1) {
          sharedPreferences.setString("token", jsonResponse['msg']);
          sharedPreferences.setString("email", jsonResponse['email']);
          sharedPreferences.setString("name", jsonResponse['name']);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const BottomNavBar()),
              (Route<dynamic> route) => false);
        } else {
          setState(() {
            isVisible = true;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
