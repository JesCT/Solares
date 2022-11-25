import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/products_model.dart';
import 'dart:convert';

class MinStock extends StatefulWidget {
  const MinStock({super.key});

  @override
  State<MinStock> createState() => _MinStockState();
}

class _MinStockState extends State<MinStock> {
  Future<List<Product>>? _productsList;

  @override
  void initState() {
    super.initState();
    _productsList = _getProducts();
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Product>> _getProducts() async {
    String? token = await _getToken();
    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/stockMin'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<Product> products = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);
        for (var i in jsonData) {
          products.add(
            Product(
              i['productos_id'].toString(),
              i['codigo'].toString(),
              i['descripcion'].toString(),
              i['producto'].toString(),
              i['precio'].toString(),
              i['precio_compra'].toString(),
              i['stock'].toString(),
              i['stock_min'].toString(),
              i['categorias_id'].toString(),
            ),
          );
        }
        return products;
      } catch (e) {
        return products;
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
              future: _productsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Product> prods = snapshot.data as List<Product>;
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
                              'Producto',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Stock',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Stock minimo',
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
                                  Text(prod.name),
                                ),
                                DataCell(
                                  Text(
                                    prod.stock,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    prod.minStock,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
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
