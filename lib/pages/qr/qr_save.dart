import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/models/category_model.dart';
import 'package:solares/models/products_model.dart';
import 'package:http/http.dart' as http;

class QRSave extends StatefulWidget {
  final String code;

  const QRSave({super.key, required this.code});

  @override
  State<QRSave> createState() => _QRSaveState();
}

class _QRSaveState extends State<QRSave> {
  final codeProd = TextEditingController();
  final productName = TextEditingController();
  final description = TextEditingController();
  final priceProd = TextEditingController();
  final soldPrice = TextEditingController();
  final minStock = TextEditingController();
  final stock = TextEditingController();
  final categoryProd = TextEditingController();
  final totalProd = TextEditingController();

  Future<List<Category>>? _categories;

  bool _isLoading = false;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _categories = _getCategories();
    codeProd.text = widget.code;
    stock.text = '0';
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

  createProduct(Product prodU) async {
    String? token = await _getToken();

    Map data = {
      'codigo': prodU.code,
      'producto': prodU.name,
      'descripcion': prodU.description,
      'precio': prodU.price,
      'precio_compra': prodU.soldPrice,
      'stock_min': prodU.minStock,
      'stock': 0,
      'categorias_id': 1,
    };

    final response = await http.post(
      Uri.parse('http://172.17.251.219/api/productos/crear'),
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

        if (jsonResponse['codigo'] != "") {
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
                        'Se creo el producto correctamente',
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
                      future: _categories,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Detalles del producto",
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(height: 25.0),
                                SizedBox(
                                  child: TextField(
                                    enableInteractiveSelection: true,
                                    autofocus: true,
                                    controller: codeProd,
                                    decoration: InputDecoration(
                                        hintText: 'Ingrese el codigo',
                                        labelText: 'Codigo',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                  ),
                                ),
                                const Divider(height: 15.0),
                                SizedBox(
                                  child: TextField(
                                    enableInteractiveSelection: true,
                                    controller: productName,
                                    decoration: InputDecoration(
                                        hintText: 'Ingrese el producto',
                                        labelText: 'Producto',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0))),
                                  ),
                                ),
                                const Divider(height: 25.0),
                                SizedBox(
                                  child: TextField(
                                    enableInteractiveSelection: true,
                                    maxLines: 3,
                                    controller: description,
                                    decoration: InputDecoration(
                                        hintText: 'Ingrese la descripción',
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
                                        enableInteractiveSelection: true,
                                        controller: priceProd,
                                        decoration: InputDecoration(
                                            hintText: 'Ingrese el precio',
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
                                        enableInteractiveSelection: true,
                                        keyboardType: TextInputType.number,
                                        controller: soldPrice,
                                        decoration: InputDecoration(
                                            hintText:
                                                'Ingrese el precio compra',
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
                                        controller: stock,
                                        enableInteractiveSelection: true,
                                        keyboardType: TextInputType.number,
                                        enabled: false,
                                        decoration: InputDecoration(
                                            hintText: 'Ingrese el stock',
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
                                        enableInteractiveSelection: true,
                                        keyboardType: TextInputType.number,
                                        controller: minStock,
                                        decoration: InputDecoration(
                                            hintText: 'Ingrese el stock minimo',
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
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width) - 50,
                                  child: DropDownCategories(
                                    categories: snapshot.data as List<Category>,
                                  ),
                                ),
                                const Divider(height: 25.0),
                                MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    Product prodf = Product(
                                        '0',
                                        codeProd.text,
                                        description.text,
                                        productName.text,
                                        priceProd.text,
                                        soldPrice.text,
                                        '0',
                                        minStock.text,
                                        categoryProd.text);
                                    createProduct(prodf);
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
                                    'Guardar',
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
  const DropDownCategories({super.key, required this.categories});

  @override
  State<DropDownCategories> createState() => _DropDownCategoriesState();
}

class _DropDownCategoriesState extends State<DropDownCategories> {
  String? dropdownValueCategory;

  @override
  void initState() {
    super.initState();
    dropdownValueCategory = widget.categories.first.id;
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
