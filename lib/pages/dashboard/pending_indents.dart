import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/indent_model.dart';
import 'dart:convert';

class PendingIndents extends StatefulWidget {
  const PendingIndents({super.key});

  @override
  State<PendingIndents> createState() => _PendingIndentsState();
}

class _PendingIndentsState extends State<PendingIndents> {
  Future<List<Indent>>? _indentsList;

  @override
  void initState() {
    super.initState();
    _indentsList = _getIndents();
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Indent>> _getIndents() async {
    String? token = await _getToken();
    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/PedidoDay'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<Indent> indents = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);
        for (var i in jsonData) {
          indents.add(
            Indent(
              i['pedidos'].toString(),
              i['estado'].toString(),
              i['cantidad'].toString(),
              i['productos_id'].toString(),
            ),
          );
        }

        return indents;
      } catch (e) {
        return indents;
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
              future: _indentsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Indent> inds = snapshot.data as List<Indent>;
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
                              'Estado',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Cantidad',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'IdProducto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: [
                          ...inds.map(
                            (prod) => DataRow(
                              cells: [
                                DataCell(
                                  Text(prod.id),
                                ),
                                DataCell(
                                  Text(
                                    prod.estado == "1"
                                        ? "Pendiente"
                                        : "Entregado",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(prod.cantidad),
                                ),
                                DataCell(
                                  Text(prod.idProduct),
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
