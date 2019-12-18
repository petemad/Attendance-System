import 'dart:async';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String status = "Please, scan the attendance QR_Code";
  String flag = 'Unknown';
  String qrResult = "Null";
  String id = "";
  String token= "";
  bool enabling = true;
  Future _scanQR() async {
    try {
      qrResult = await BarcodeScanner.scan();
      setState(() {
        status = "Waiting for response";
        flag = 'Unknown';
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          status = "You must accept the camera permission to scan the QR_Code";
          flag = 'Failed';
        });
      } else {
        setState(() {
          status = "Unknown Error $ex. Please, Try again";
          flag = 'Unknown';
        });
      }
    } on FormatException {
      setState(() {
        status = "You didn't scan the QR_Code yet";
        flag = 'Failed';
      });
    } catch (ex) {
      setState(() {
        status = "Unknown Error $ex. Please, Try again";
        flag = 'Unknown';
      });
    }

    var url = "http://172.28.132.108:8099/verify/" + qrResult + "/" + id;
    if (token != ""){
      url = "http://172.28.132.108:8099/verify-token/" + qrResult + "/" + id +"/"+ token;
      print(url);
    }

    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        status = "Step 1 is done Successfuly";
        flag = 'Step1';
        if (token != ""){
          status = "Pay attention to the lecture";
          flag = 'Done';
        }
        enabling =false;
      });
    } else {
      setState(() {
        status = "Try again";
        flag = "Unknown";
      });
    }
  }

  Map<String, IconData> icons = {
    'Done': Icons.sentiment_very_satisfied,
    'Unknown': Icons.sentiment_satisfied,
    'Failed': Icons.sentiment_very_dissatisfied,
    'Step1' : Icons.sentiment_neutral
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
        centerTitle: true,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 80,
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Your ID',
                      labelText: "ID",
                      alignLabelWithHint: true,
                      enabled: enabling,
                    ),
                    onChanged: (value) {
                      id = value;
                    },
                  ),
                ),
                Text(
                  status,
                  style: new TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Icon(icons[flag], size: 300.0),
                Container(
                  width: 100,
                  height: 80,
                  child: TextField(
                    decoration: InputDecoration(
                    border: InputBorder.none,
                      hintText: 'Enter the token',
                      labelText: "Token",
                      alignLabelWithHint: true,
                      enabled: !enabling
                    ),
                    onChanged: (value){
                      token = value;
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_enhance),
        label: Text("Scan QR_Code"),
        onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
