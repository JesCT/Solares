import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/login.dart';

Future<List<String?>>? _datauser;

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  void initState() {
    super.initState();
    _datauser = _getData();
  }

  bool _isLoading = false;
  //Future<List<String?>>? _datauser;

  Future<List<String?>> _getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return [prefs.getString('name'), prefs.getString('email')];
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : FutureBuilder(
            future: _datauser,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<String?> myData = snapshot.data as List<String?>;
                return Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.35,
                      color: const Color.fromARGB(255, 52, 60, 84),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 80,
                              child: CircleAvatar(
                                radius: 100.0,
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage('images/logo.png'),
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  myData[0].toString(),
                                  style: const TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  myData[1].toString(),
                                  style: const TextStyle(
                                      fontSize: 18.0, color: Colors.white30),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.17,
                        color: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: const [
                              Icon(Icons.info, size: 30, color: Colors.white70),
                              SizedBox(width: 10.0),
                              Text(
                                'Más información',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationIcon: const FlutterLogo(),
                          applicationName: 'Solares App',
                          applicationVersion: '1.0.0',
                          applicationLegalese: "Cuevo equipo 2022",
                          children: [
                            const Text(
                              'Ingeniería en Sistemas, Univesidad Mesoamericana Quetzaltenango',
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Text(
                              "William Hernandez",
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              "Jhony Hernandez",
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              "Miguel Terraza",
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              "Jesús Capriel",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.17,
                        color: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: const [
                              Icon(Icons.logout,
                                  size: 30, color: Colors.white70),
                              SizedBox(width: 10.0),
                              Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _isLoading = true;
                        });
                        logOut();
                      },
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('Ocurrio un error la autentificar datos');
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
  }

  logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isLoading = false;
      });

      sharedPreferences.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const Login(),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }
}
