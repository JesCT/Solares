import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/category_model.dart';
import 'package:solares/models/products_model.dart';
import 'package:http/http.dart' as http;
import 'package:solares/models/resuply_model.dart';
import 'package:solares/models/suppliers_model.dart';

int _counter = 1;
int _idProducto = 0;
int _idSupplier = 0;

class QRResuply extends StatefulWidget {
  final String code;

  const QRResuply({super.key, required this.code});

  @override
  State<QRResuply> createState() => _QRResuplyState();
}

class _QRResuplyState extends State<QRResuply> {
  final idProd = TextEditingController();
  final codeProd = TextEditingController();
  final productName = TextEditingController();
  final description = TextEditingController();
  final priceProd = TextEditingController();
  final soldPrice = TextEditingController();
  final stockProd = TextEditingController();
  final minStock = TextEditingController();
  final categoryProd = TextEditingController();
  final totalProd = TextEditingController();

  Future<Product>? _product;
  Future<List<Supplier>>? _suppliers;
  Future<List<Category>>? _categories;

  bool _isLoading = false;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _product = _getProduct();
    _suppliers = _getSuppliers();
    _categories = _getCategories();
  }

  void removeProduct() {
    setState(() {
      if (_counter > 1) _counter--;
    });
  }

  void addProduct() {
    setState(() {
      _counter++;
    });
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
      if (response.body.length > 2) {
        String body = utf8.decode(response.bodyBytes);

        final jsonData = jsonDecode(body);
        product.id = jsonData[0]['productos_id'].toString();
        product.code = jsonData[0]['codigo'].toString();
        product.name = jsonData[0]['producto'].toString();
        product.description = jsonData[0]['descripcion'].toString();
        product.price = jsonData[0]['precio'].toString();
        product.soldPrice = jsonData[0]['precio_compra'].toString();
        product.stock = jsonData[0]['stock'].toString();
        product.minStock = jsonData[0]['stock_min'].toString();
        product.categoryId = jsonData[0]['categorias_id'].toString();
      } else {
        return Future.error('error');
      }

      return product;
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

      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });

        if (jsonResponse['msg'] == "Registro Creado") {
          await showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 250,
                color: const Color.fromARGB(255, 25, 33, 61),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'El reabastecimiento fue completado con exito',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      MaterialButton(
                        minWidth: 200.0,
                        height: 50.0,
                        onPressed: () => Navigator.pop(context),
                        color: const Color.fromARGB(255, 111, 115, 133),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          'Regresar',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        } else {
          setState(() {
            isVisible = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: SafeArea(
            child: ListView(
              children: [
                Column(
                  children: [
                    FutureBuilder(
                      future: _product,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Product prod = snapshot.data as Product;
                          idProd.text = prod.id;
                          codeProd.text = prod.code;
                          productName.text = prod.name;
                          description.text = prod.description;
                          priceProd.text = prod.price;
                          soldPrice.text = prod.soldPrice;
                          stockProd.text = prod.stock;
                          minStock.text = prod.minStock;
                          categoryProd.text = prod.categoryId;
                          totalProd.text = _counter.toString();

                          return Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Reabastecimiento",
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(height: 25.0),
                                SizedBox(
                                  child: TextField(
                                    readOnly: true,
                                    controller: codeProd,
                                    decoration: InputDecoration(
                                        labelText: 'Codigo',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                  ),
                                ),
                                const Divider(height: 15.0),
                                SizedBox(
                                  child: TextField(
                                    readOnly: true,
                                    controller: productName,
                                    decoration: InputDecoration(
                                        labelText: 'Producto',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                  ),
                                ),
                                const Divider(height: 25.0),
                                SizedBox(
                                  child: TextField(
                                    readOnly: true,
                                    maxLines: 3,
                                    controller: description,
                                    decoration: InputDecoration(
                                        labelText: 'Descripción',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                  ),
                                ),
                                const Divider(height: 25.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  0.5) -
                                              35,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        readOnly: true,
                                        controller: priceProd,
                                        decoration: InputDecoration(
                                            labelText: 'Precio',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0))),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  0.5) -
                                              35,
                                      child: TextField(
                                        readOnly: true,
                                        controller: soldPrice,
                                        decoration: InputDecoration(
                                            labelText: 'Precio compra',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0))),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 25.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  0.5) -
                                              35,
                                      child: TextField(
                                        readOnly: true,
                                        controller: stockProd,
                                        decoration: InputDecoration(
                                            labelText: 'Stock',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0))),
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  0.5) -
                                              35,
                                      child: TextField(
                                        readOnly: true,
                                        controller: minStock,
                                        decoration: InputDecoration(
                                            labelText: 'Stock minimo',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0))),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 25.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  0.5) -
                                              35,
                                      child: FutureBuilder(
                                        future: _categories,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return DropDownCategories(
                                              categories: snapshot.data
                                                  as List<Category>,
                                              indexDropDown: prod.categoryId,
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                                'Error en el servidor');
                                          }

                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          (MediaQuery.of(context).size.width *
                                                  0.5) -
                                              35,
                                      child: FutureBuilder(
                                        future: _suppliers,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return DropDownSuppliers(
                                                suppliers: snapshot.data
                                                    as List<Supplier>);
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                                'Error en el servidor');
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFece5eb),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          )),
                                      child: IconButton(
                                        onPressed: () => removeProduct(),
                                        icon: const Icon(Icons.remove),
                                      ),
                                    ),
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 25, 33, 61),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          )),
                                      child: IconButton(
                                        onPressed: () => addProduct(),
                                        icon: const Icon(Icons.add,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100.0,
                                      child: TextField(
                                        readOnly: true,
                                        controller: totalProd,
                                        decoration: InputDecoration(
                                            labelText: 'Unidades',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0))),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 25.0),
                                MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      _idProducto = int.parse(idProd.text);
                                      _isLoading = true;
                                    });

                                    Resuply resuplyM = Resuply(
                                        _counter,
                                        (_counter *
                                            double.parse(soldPrice.text)),
                                        _idProducto,
                                        _idSupplier);
                                    resuply(resuplyM);
                                  },
                                  minWidth:
                                      (MediaQuery.of(context).size.width) - 50,
                                  height: 50,
                                  disabledColor:
                                      const Color.fromARGB(255, 111, 115, 133),
                                  color: const Color.fromARGB(255, 25, 33, 61),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                  child: const Text(
                                    'Actualizar',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'No se encontro el producto',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700),
                                ),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 25, 33, 61),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      )),
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
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
        onChanged: null,
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
    _idSupplier = int.parse(dropdownValueSupplier.toString());
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
          _idSupplier = int.parse(value.toString());
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
