import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/category_model.dart';
import 'package:solares/models/products_model.dart';
import 'package:http/http.dart' as http;
import 'package:solares/models/resuply_model.dart';
import 'package:solares/models/suppliers_model.dart';

class QRUpdate extends StatefulWidget {
  final String code;

  const QRUpdate({super.key, required this.code});

  @override
  State<QRUpdate> createState() => _QRUpdateState();
}

class _QRUpdateState extends State<QRUpdate> {
  final codeProd = TextEditingController();
  final productName = TextEditingController();
  final description = TextEditingController();
  final priceProd = TextEditingController();
  final soldPrice = TextEditingController();
  final stockProd = TextEditingController();
  final minStock = TextEditingController();
  final categoryProd = TextEditingController();
  /*  String? dropdownValueCategory = '1'; */
  String? dropdownValueSupplier = '1';

  Future<Product>? _product;
  Future<List<Supplier>>? _suppliers;
  Future<List<Category>>? _categories;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _product = _getProduct();
    _suppliers = _getSuppliers();
    _categories = _getCategories();
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Product> _getProduct() async {
    String? token = await _getToken();
    String code = widget.code;

    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/productos/$code'), headers: {
      'Authorization': 'Bearer $token',
    });

    Product product = Product("", "", "", "", "", "", "", "", "");

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);

        product.code = jsonData[0]['codigo'].toString();
        product.name = jsonData[0]['producto'].toString();
        product.price = jsonData[0]['precio'].toString();
        product.stock = jsonData[0]['stock'].toString();
        product.minStock = jsonData[0]['stock_min'].toString();
        product.categoryId = jsonData[0]['categorias_id'].toString();

        return product;
      } catch (e) {
        return product;
      }
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  Future<List<Supplier>> _getSuppliers() async {
    String? token = await _getToken();

    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/proveedores'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<Supplier> suppliers = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);

        for (var i in jsonData) {
          suppliers.add(
            Supplier(
              i['proveedor_id'].toString(),
              i['proveedor'].toString(),
            ),
          );
        }

        return suppliers;
      } catch (e) {
        return suppliers;
      }
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  Future<List<Category>> _getCategories() async {
    String? token = await _getToken();

    final response = await http
        .get(Uri.parse('http://172.17.251.219/api/categorias'), headers: {
      'Authorization': 'Bearer $token',
    });

    List<Category> categories = [];

    if (response.statusCode == 200) {
      try {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);

        for (var i in jsonData) {
          categories.add(
            Category(
              i['categorias_id'].toString(),
              i['categoria'].toString(),
            ),
          );
        }

        return categories;
      } catch (e) {
        return categories;
      }
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  resuply(Resuply resuply) async {
    String? token = await _getToken();

    Map data = {
      'unidades': resuply.units,
      'total': resuply.total,
      'productos_id': resuply.productId,
      'proveedor_id': resuply.supplierId,
    };

    final response = await http.post(
      Uri.parse('http://172.17.251.219/api/abastecimiento/crear'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          FutureBuilder(
            future: _product,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Product prod = snapshot.data as Product;

                codeProd.text = prod.code;
                productName.text = prod.name;
                description.text = prod.name;
                priceProd.text = prod.price;
                soldPrice.text = prod.price;
                stockProd.text = prod.stock;
                minStock.text = prod.minStock;
                categoryProd.text = prod.categoryId;

                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      const Text(
                        "Detalles del producto",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 25.0),
                      SizedBox(
                        child: TextField(
                          enableInteractiveSelection: true,
                          autofocus: true,
                          readOnly: !_isAvailable,
                          controller: codeProd,
                          decoration: InputDecoration(
                              hintText: 'Ingrese el codigo',
                              labelText: 'Codigo',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                        ),
                      ),
                      const Divider(height: 15.0),
                      SizedBox(
                        child: TextField(
                          enableInteractiveSelection: true,
                          readOnly: !_isAvailable,
                          controller: productName,
                          decoration: InputDecoration(
                              hintText: 'Ingrese el producto',
                              labelText: 'Producto',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                        ),
                      ),
                      const Divider(height: 25.0),
                      SizedBox(
                        child: TextField(
                          enableInteractiveSelection: true,
                          readOnly: !_isAvailable,
                          maxLines: 3,
                          controller: description,
                          decoration: InputDecoration(
                              hintText: 'Ingrese la descripción',
                              labelText: 'Descripción',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                        ),
                      ),
                      const Divider(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width * 0.5) - 35,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              enableInteractiveSelection: true,
                              readOnly: !_isAvailable,
                              controller: priceProd,
                              decoration: InputDecoration(
                                  hintText: 'Ingrese el precio',
                                  labelText: 'Precio',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                            ),
                          ),
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width * 0.5) - 35,
                            child: TextField(
                              enableInteractiveSelection: true,
                              keyboardType: TextInputType.number,
                              readOnly: !_isAvailable,
                              controller: soldPrice,
                              decoration: InputDecoration(
                                  hintText: 'Ingrese el precio compra',
                                  labelText: 'Precio compra',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width * 0.5) - 35,
                            child: TextField(
                              enableInteractiveSelection: true,
                              keyboardType: TextInputType.number,
                              readOnly: !_isAvailable,
                              controller: stockProd,
                              decoration: InputDecoration(
                                  hintText: 'Ingrese el stock',
                                  labelText: 'Stock',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                            ),
                          ),
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width * 0.5) - 35,
                            child: TextField(
                              enableInteractiveSelection: true,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              controller: minStock,
                              decoration: InputDecoration(
                                  hintText: 'Ingrese el stock minimo',
                                  labelText: 'Stock minimo',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width * 0.5) - 35,
                            child: FutureBuilder(
                              future: _categories,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DropDownCategories(
                                    categories: snapshot.data as List<Category>,
                                    indexDropDown: prod.categoryId,
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
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width * 0.5) - 35,
                            child: FutureBuilder(
                              future: _suppliers,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DropDownSuppliers(
                                      suppliers:
                                          snapshot.data as List<Supplier>);
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
                      ),
                      const Divider(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MaterialButton(
                            disabledColor:
                                const Color.fromARGB(255, 111, 115, 133),
                            onPressed: _isAvailable == false
                                ? () {
                                    setState(() {
                                      _isAvailable = true;
                                    });
                                    //ase algo
                                  }
                                : null,
                            minWidth:
                                (MediaQuery.of(context).size.width * 0.3) - 20,
                            height: 50,
                            color: const Color.fromARGB(255, 25, 33, 61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: const BorderSide(color: Colors.blue),
                            ),
                            child: const Text(
                              'Editar',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          MaterialButton(
                            onPressed: _isAvailable
                                ? () {
                                    Resuply _resuply = Resuply(1, 200, 1, 1);
                                    resuply(_resuply);
                                    print('Se envio');
                                  }
                                : null,
                            minWidth:
                                (MediaQuery.of(context).size.width * 0.3) - 20,
                            height: 50,
                            disabledColor:
                                const Color.fromARGB(255, 111, 115, 133),
                            color: const Color.fromARGB(255, 25, 33, 61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: const BorderSide(color: Colors.blue),
                            ),
                            child: const Text(
                              'Guardar',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          MaterialButton(
                            onPressed: _isAvailable
                                ? () {
                                    setState(() {
                                      _isAvailable = false;
                                    });
                                  }
                                : null,
                            height: 50,
                            minWidth:
                                (MediaQuery.of(context).size.width * 0.3) - 20,
                            disabledColor:
                                const Color.fromARGB(255, 111, 115, 133),
                            color: const Color.fromARGB(255, 25, 33, 61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: const BorderSide(color: Colors.blue),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return const Text('No se encontro el producto');
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    ));
  }
}

class DropDownCategories extends StatefulWidget {
  final List<Category> categories;
  final String indexDropDown;
  const DropDownCategories(
      {super.key, required this.categories, required this.indexDropDown});

  @override
  State<DropDownCategories> createState() => _DropDownCategoriesState();
}

class _DropDownCategoriesState extends State<DropDownCategories> {
  String? dropdownValueCategory;

  @override
  void initState() {
    super.initState();
    dropdownValueCategory = widget.indexDropDown;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: dropdownValueCategory,
        underline: Container(
          height: 2,
          color: Colors.blue,
        ),
        onChanged: (String? value) {
          setState(() {
            dropdownValueCategory = value;
          });
        },
        items: widget.categories.map((e) {
          return DropdownMenuItem<String>(
            value: e.id,
            child: Text(e.name),
          );
        }).toList());
  }
}

class DropDownSuppliers extends StatefulWidget {
  final List<Supplier> suppliers;
  const DropDownSuppliers({super.key, required this.suppliers});

  @override
  State<DropDownSuppliers> createState() => _DropDownSuppliersState();
}

class _DropDownSuppliersState extends State<DropDownSuppliers> {
  String? dropdownValueSupplier;

  @override
  void initState() {
    super.initState();
    dropdownValueSupplier = widget.suppliers.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValueSupplier,
      underline: Container(
        height: 2,
        color: Colors.blue[900],
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValueSupplier = value;
        });
      },
      items: widget.suppliers.map((e) {
        return DropdownMenuItem<String>(
          value: e.id,
          child: Text(e.name),
        );
      }).toList(),
    );
  }
}
