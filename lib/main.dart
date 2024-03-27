import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

GlobalKey globalKey = GlobalKey();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zona Alvo de Treinamento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Zona Alvo de Treinamento'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String gender = 'Homem';
  int age = 0;
  double restingHR = 0;
  double maxHR = 0;
  double reserveHR = 0;
  double lowerZone = 0;
  double upperZone = 0;

  void calculateHR() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        switch (gender) {
          case 'Homem':
            maxHR = (220 - age).toDouble();
            break;
          case 'Mulher':
            maxHR = (206 - (0.88 * age)).toDouble();
            break;
        }
        reserveHR = maxHR - restingHR;
        lowerZone = restingHR + (0.6 * reserveHR);
        upperZone = restingHR + (0.8 * reserveHR);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _buildTextField('Nome', 'Please enter your name'),
                _buildGenderSelector(),
                _buildNumberField('Idade', 'Please enter your age'),
                _buildNumberField(
                    'FC Repouso', 'Please enter your resting heart rate'),
                Slider(
                  //value: lowerZone,
                  value: restingHR + (0.6 * reserveHR),
                  onChanged: (value) {
                    setState(() {
                      lowerZone = value;
                      calculateHR();
                    });
                  },
                ),
                Text('Zona Inferior: ${(lowerZone).round()}%'),
                Slider(
                  //value: upperZone,
                  value: restingHR + (0.8 * reserveHR),
                  onChanged: (value) {
                    setState(() {
                      upperZone = value;
                      calculateHR();
                    });
                  },
                ),
                Text('Zona Superior: ${(upperZone).round()}%'),
                _buildResultText('FC máxima: ${maxHR.toStringAsFixed(0)}'),
                _buildResultText(
                    'Zona Inferior: ${lowerZone.toStringAsFixed(0)}'),
                _buildResultText(
                    'Zona Superior: ${upperZone.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String errorText,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(String label, String errorText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          if (label == 'Idade') {
            age = int.parse(value);
          } else if (label == 'FC Repouso') {
            restingHR = double.parse(value);
          }
          return null;
        },
        onFieldSubmitted: (value) {
          calculateHR();
        },
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: <Widget>[
        _buildRadio('Homem'),
        _buildRadio('Mulher'),
      ],
    );
  }

  Widget _buildRadio(String label) {
    return Row(
      children: <Widget>[
        Radio(
          value: label,
          groupValue: gender,
          onChanged: (String? value) {
            setState(() {
              gender = value ?? gender;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  Widget _buildResultText(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
