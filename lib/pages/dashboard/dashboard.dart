import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/dashboard_report.dart';
import 'package:http/http.dart' as http;

/* Future<List<DashboardReport>>? _dashboardDayList;
Future<List<DashboardReport>>? _dashboardMonthList; */

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<DashboardReport>>? _dashboardDayList;
  Future<List<DashboardReport>>? _dashboardMonthList;

  @override
  void initState() {
    super.initState();
    _dashboardDayList = _getDashboardDay();
    _dashboardMonthList = _getDashboardMonth();
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<DashboardReport>> _getDashboardDay() async {
    String? token = await _getToken();
    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/dayReports'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<DashboardReport> dashboard = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);
        for (var i in jsonData) {
          dashboard.add(
            DashboardReport(
              i['title'].toString(),
              i['value'].toString(),
              i['route'].toString(),
            ),
          );
        }
        return dashboard;
      } catch (e) {
        return dashboard;
      }
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  Future<List<DashboardReport>> _getDashboardMonth() async {
    String? token = await _getToken();
    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/monthReports'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<DashboardReport> dashboard = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);
        for (var i in jsonData) {
          dashboard.add(
            DashboardReport(
              i['title'].toString(),
              i['value'].toString(),
              i['value'].toString(),
            ),
          );
        }

        return dashboard;
      } catch (e) {
        return dashboard;
      }
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _dashboardDayList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TopBar(
                      subtitle: 'Dahsboad',
                      title: 'Reportes del dia',
                    ),
                    DayReportListView(
                        dashboard: snapshot.data as List<DashboardReport>)
                  ]);
            } else if (snapshot.hasError) {
              return const Text('Error en el servidor');
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: _dashboardMonthList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TopBar(
                      subtitle: 'Reportes importantes',
                      title: 'Reportes del mes',
                    ),
                    ReportListView(
                        dashboard: snapshot.data as List<DashboardReport>),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text('Error en el servidor');
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  const TopBar({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Text(subtitle),
        ],
      ),
    );
  }
}

class DayReportListView extends StatelessWidget {
  final List<DashboardReport> dashboard;
  const DayReportListView({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext contex, int index) {
            return GestureDetector(
              child: Card(
                title: dashboard[index].title,
                value: dashboard[index].value,
              ),
              onTap: () {
                Navigator.pushNamed(context, dashboard[index].route);
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 15),
          itemCount: dashboard.length),
    );
  }
}

class Card extends StatelessWidget {
  final String title;
  final String value;

  const Card({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 66, 71, 95),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              Colors.grey.withOpacity(0.0),
              Colors.black38,
            ],
            stops: const [0.5, 1.0],
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Text(
                value,
                style: const TextStyle(
                    fontWeight: FontWeight.w200, fontSize: 15.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportListView extends StatelessWidget {
  final List<DashboardReport> dashboard;
  const ReportListView({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        child: ListView.separated(
            itemBuilder: (BuildContext contex, int index) {
              return CardData(
                title: dashboard[index].title,
                value: dashboard[index].value,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: dashboard.length),
      ),
    );
  }
}

class CardData extends StatelessWidget {
  final String title;
  final String value;

  const CardData({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 208, 210, 215),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 180,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 111, 115, 133),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15)),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
          ),
          const SizedBox(width: 30),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}
