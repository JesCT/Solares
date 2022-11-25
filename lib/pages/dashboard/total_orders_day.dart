import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/order_model.dart';
import 'dart:convert';

class TotalOrders extends StatefulWidget {
  const TotalOrders({super.key});

  @override
  State<TotalOrders> createState() => _TotalOrdersState();
}

class _TotalOrdersState extends State<TotalOrders> {
  Future<List<Order>>? _totalOrdersList;

  @override
  void initState() {
    super.initState();
    _totalOrdersList = _getTotalOrders();
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Order>> _getTotalOrders() async {
    String? token = await _getToken();
    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/TotalDay'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<Order> orders = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);
        for (var i in jsonData) {
          orders.add(
            Order(
              i['orden_id'].toString(),
              i['codigo'].toString(),
              i['fecha'].toString(),
              i['total'].toString(),
            ),
          );
        }

        return orders;
      } catch (e) {
        return orders;
      }
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ImageArea(),
          Expanded(
            child: FutureBuilder(
              future: _totalOrdersList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Order> prods = snapshot.data as List<Order>;
                  return InteractiveViewer(
                    constrained: false,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DataTable(
                        dividerThickness: 5,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Id',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Codigo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Fecha',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: [
                          ...prods.map(
                            (prod) => DataRow(
                              cells: [
                                DataCell(
                                  Text(prod.id),
                                ),
                                DataCell(
                                  Text(prod.code),
                                ),
                                DataCell(
                                  Text(prod.date),
                                ),
                                DataCell(
                                  Text(
                                    "Q.${prod.total}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text('Error en el servidor');
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ImageArea extends StatelessWidget {
  const ImageArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 35,
          right: 60,
          child: Container(
            height: 55,
            width: 55,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              color: Colors.red,
            ),
            child: IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: (() {
                Navigator.of(context).pop();
              }),
            ),
          ),
        )
      ],
    );
  }
}
