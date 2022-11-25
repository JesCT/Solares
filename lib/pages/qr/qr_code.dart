import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:solares/pages/qr/qr_find.dart';
import 'package:solares/pages/qr/qr_resuply.dart';
import 'package:solares/pages/qr/qr_save.dart';
import 'package:solares/pages/qr/qr_update.dart';

class QRCode extends StatefulWidget {
  const QRCode({super.key});
  @override
  State<QRCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QRCode> {
  final codeController = TextEditingController();
  String _data = "";

  _scanFind() async {
    await FlutterBarcodeScanner.scanBarcode(
            "#19213d", "Cancelar", false, ScanMode.BARCODE)
        .then(
      (value) => setState(() => _data = value),
    );

    /* setState(() {
      _data = "8710398601582";
    }); */

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRFind(code: _data),
      ),
    );
  }

  _scanSuply() async {
    await FlutterBarcodeScanner.scanBarcode(
            "#19213d", "Cancelar", false, ScanMode.BARCODE)
        .then(
      (value) => setState(() => _data = value),
    );

    /* setState(() {
      _data = "8710398601582";
    }); */

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRResuply(code: _data),
      ),
    );
  }

  _scanSave() async {
    await FlutterBarcodeScanner.scanBarcode(
            "#19213d", "Cancelar", false, ScanMode.BARCODE)
        .then(
      (value) => setState(() => _data = value),
    );

    /* setState(() {
      _data = "8710398601582";
    }); */

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRSave(code: _data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                _scanFind();
              },
              height: 50.0,
              minWidth: 400.0,
              color: const Color.fromARGB(255, 25, 33, 61),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.blue),
              ),
              child: const Text(
                'Consultar / Actulizar',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const Divider(
              height: 30.0,
              thickness: 3.0,
            ),
            MaterialButton(
              onPressed: () {
                _scanSuply();
              },
              height: 50,
              minWidth: 400.0,
              color: const Color.fromARGB(255, 25, 33, 61),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.blue),
              ),
              child: const Text(
                'Reabastecer',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const Divider(
              height: 30.0,
              thickness: 3.0,
            ),
            MaterialButton(
              onPressed: () {
                _scanSave();
              },
              height: 50,
              minWidth: 400.0,
              color: const Color.fromARGB(255, 25, 33, 61),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.blue),
              ),
              child: const Text(
                'Crear producto',
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
  }
}
