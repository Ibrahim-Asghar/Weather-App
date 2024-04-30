import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State {
  final Api_key = 'a19ac5ed42c436634a170333b3d18673';
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _weatherDescription = '';
  String _temperature = '';
  String _humidity = '';
  String _windSpeed = '';
  bool _isLoading = false;
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        setState(() {
          _isLoading = true;
        });
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isLoading = false;
          _fetchWeatherData();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error getting current location: $e");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Failed to get current location. Please make sure location services are enabled.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Location permission denied');
    }
  }

  _fetchWeatherData() async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${_latitude}&lon=${_longitude}&units=metric&appid=${Api_key}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _weatherDescription = jsonData['weather'][0]['description'];
        _temperature = jsonData['main']['temp'].toString();
        _humidity = jsonData['main']['humidity'].toString();
        _windSpeed = jsonData['wind']['speed'].toString();
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  _fetchWeatherDataByLocation(String location) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=${location}&units=metric&appid=${Api_key}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _weatherDescription = jsonData['weather'][0]['description'];
        _temperature = jsonData['main']['temp'].toString();
        _humidity = jsonData['main']['humidity'].toString();
        _windSpeed = jsonData['wind']['speed'].toString();
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueAccent),
                        foregroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                      ),
                      onPressed: _getCurrentLocation,
                      child: Container(
                        height: 50,
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Get Current Location'),
                            Icon(Icons.location_on_outlined)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      textAlign: TextAlign.center,
                      'Current Location:\n $_latitude, $_longitude',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                          hintText: 'Enter Location',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.location_on_outlined)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blueAccent),
                        foregroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                      ),
                      onPressed: () {
                        _fetchWeatherDataByLocation(_locationController.text);
                        _isLoading;
                      },
                      child: Container(
                        height: 50,
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Get Weather by Location'),
                            Icon(Icons.location_on_outlined)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      textAlign: TextAlign.center,
                      'Location : \n${_locationController.text.isNotEmpty ? _locationController.text : '$_latitude, $_longitude'}',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      textAlign: TextAlign.center,
                      'Weather: \n$_weatherDescription',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Temperature: $_temperature°C',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Humidity: $_humidity%',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Wind Speed: $_windSpeed m/s',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
