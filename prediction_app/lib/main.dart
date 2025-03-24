import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediction App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(
            color: Colors.blue[800],
            fontSize: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all input fields
    _controllers['Age'] = TextEditingController();
    _controllers['G'] = TextEditingController();
    _controllers['GS'] = TextEditingController();
    _controllers['MP'] = TextEditingController();
    _controllers['FG'] = TextEditingController();
    _controllers['FGA'] = TextEditingController();
    _controllers['FG%'] = TextEditingController();
    _controllers['3P'] = TextEditingController();
    _controllers['3PA'] = TextEditingController();
    _controllers['3P%'] = TextEditingController();
    _controllers['2P'] = TextEditingController();
    _controllers['2PA'] = TextEditingController();
    _controllers['2P%'] = TextEditingController();
    _controllers['eFG%'] = TextEditingController();
    _controllers['FT'] = TextEditingController();
    _controllers['FTA'] = TextEditingController();
    _controllers['FT%'] = TextEditingController();
    _controllers['ORB'] = TextEditingController();
    _controllers['DRB'] = TextEditingController();
    _controllers['TRB'] = TextEditingController();
    _controllers['AST'] = TextEditingController();
    _controllers['STL'] = TextEditingController();
    _controllers['BLK'] = TextEditingController();
    _controllers['TOV'] = TextEditingController();
    _controllers['PF'] = TextEditingController();
  }

  String _prediction = '';
  bool _isLoading = false; // Add a loading state variable

  Future<void> _predict() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        // Prepare the input data
        final Map<String, dynamic> inputData = {};
        _controllers.forEach((key, controller) {
          inputData[key] = double.tryParse(controller.text) ?? 0.0;
        });

        // Send the request to the API
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/predict'), // Replace with your API URL
          headers: {'Content-Type': 'application/json'},
          body: json.encode(inputData),
        );

        // Handle the response
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            _prediction = responseData['prediction'][0].toString(); // Extract the prediction value
          });
        } else {
          setState(() {
            _prediction = 'Error: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _prediction = 'Error: $e';
        });
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction App'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              for (var key in _controllers.keys)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _controllers[key],
                    decoration: InputDecoration(
                      labelText: key,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _predict, // Disable button when loading
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text('Predict'),
              ),
              SizedBox(height: 20),
              Text(
                'Prediction: $_prediction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}