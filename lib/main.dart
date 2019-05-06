import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_weather_app/Model/WeatherModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

Future<WeatherModel> getWeather(String lat, String lng) async {
  final response = await http.get(
      'http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=51663d3c484f2d7d48d8a3ab31715333&units=metric');

  if (response.statusCode == 200) {
    var result = json.decode(response.body);
    var model = WeatherModel.fromJson(result);
    return model;
  } else
    throw Exception('Failed to load Weather Information');
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;

  @override
  void initState() {
    super.initState();
    //Default value
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();

    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Weather',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Color.fromRGBO(31, 42, 255, 1.0),
        fontFamily: 'Montserrat',
        backgroundColor: Color.fromRGBO(31, 42, 255, 1.0),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Just Weather',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          backgroundColor: Color.fromRGBO(31, 42, 255, 1.0),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: new BoxDecoration(
                color: Color.fromRGBO(31, 42, 255, 1.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Colors for gradients
                    Color.fromRGBO(31, 42, 255, 1.0),
                    Color.fromRGBO(230, 60, 167, 1.0),
                  ],
                )),
            child: FutureBuilder<WeatherModel>(
              future: getWeather(currentLocation['latitude'].toString(),
                  currentLocation['longitude'].toString()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  WeatherModel model = snapshot.data;

                  //Format date
                  var fm = new DateFormat('MMMM dd, yyyy');
                  var fm_hour = new DateFormat.Hm();

                  print(model.weather[0].icon);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              //Image.network(
                              //  'https://openweathermap.org/img/w/${model.weather[0].icon}.png',
                              //  width: 50,
                              //  height: 50,
                              //),
                              Image.asset(
                                'assets/images/weather/${model.weather[0].icon}.png',
                                width: 100,
                                fit: BoxFit.fitWidth,
                              ),
                              Text(
                                '${model.main.temp}°C',
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                '${model.name}',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                '${model.main.temp_max}/${model.main.temp_min}',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '${model.weather[0].description}'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: 'Roboto',
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 360.0,
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(40.0),
                                  topRight: const Radius.circular(40.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      'TODAY',
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          height: 1,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color:
                                              Color.fromRGBO(31, 42, 255, 1.0)),
                                    ),
                                    new Text(
                                      '${fm.format(new DateTime.fromMillisecondsSinceEpoch((model.dt * 1000), isUtc: true))}',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        height: 1,
                                        letterSpacing: 0.25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      '',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          height: 1.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color:
                                              Color.fromRGBO(31, 42, 255, 1.0)),
                                    ),
                                  ],
                                ),
                                new Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: SizedBox(
                                        height: 150,
                                        child: new ListView(
                                          // This next line does the trick.
                                          scrollDirection: Axis.horizontal,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.all(5),
                                              padding: EdgeInsets.all(20),
                                              width: 160.0,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                              ),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.wb_sunny,
                                                    color: Colors.orange,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    'Feels like',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.5,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${model.main.temp}°C',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.0,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(5),
                                              padding: EdgeInsets.all(20),
                                              width: 160.0,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                              ),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.wb_cloudy,
                                                    color: Colors.blueGrey,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    'Wind',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.5,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${model.wind.speed} m/s',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.0,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(5),
                                              padding: EdgeInsets.all(20),
                                              width: 160.0,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                              ),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.opacity,
                                                    color: Colors.blueAccent,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    'Humidity',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.5,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${model.main.humidity} %',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.0,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(20),
                                              margin: EdgeInsets.all(5),
                                              width: 160.0,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                              ),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.arrow_downward,
                                                    color: Colors.redAccent,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    'Pressure',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.5,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${model.main.pressure} hPa',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.0,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(20),
                                              margin: EdgeInsets.all(5),
                                              width: 160.0,
                                              decoration: new BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                color: Colors.white,
                                                boxShadow: [
                                                  new BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                              ),
                                              child: new Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Icon(
                                                    Icons.visibility,
                                                    color: Colors.black54,
                                                    size: 40,
                                                  ),
                                                  Text(
                                                    'Visibility',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.5,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  Text(
                                                    '${model.visibility / 1000} km',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      height: 1.0,
                                                      letterSpacing: 0.25,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError)
                  return Container(
                    height: 500,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/bug_fixed.png',
                          width: 250,
                          fit: BoxFit.fitWidth,
                        ),
                        Text(
                          ' ',
                          style: TextStyle(
                            height: 1.5,
                          ),
                        ),
                        Text(
                          'Oh Oh, Houston we have a problem!',
                          style: TextStyle(
                              fontSize: 20.0,
                              height: 1.0,
                              letterSpacing: 0.25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          ' ',
                          style: TextStyle(
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Check your network or give the location permission to the app.',
                          style: TextStyle(
                              fontSize: 15.0,
                              height: 1.0,
                              letterSpacing: 0.25,
                              fontWeight: FontWeight.normal,
                              color: Colors.white),
                        ),
                        //Text(
                        //  '${snapshot.error}',
                        //  style: TextStyle(
                        //      fontSize: 20.0,
                        //      height: 1.5,
                        //      letterSpacing: 0.25,
                        //      color: Colors.red),
                        //),
                      ],
                    ),
                  );
                return CircularProgressIndicator(); //Default show loading
              },
            ),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {},
          child: new Icon(Icons.add),
          elevation: 6.0,
          backgroundColor: Color.fromRGBO(31, 42, 255, 1.0),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.home),
                  color: Color.fromRGBO(31, 42, 255, 1.0),
                  onPressed: () {},
                ),
              ),
              Expanded(child: new Text('')),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.search),
                  color: Color.fromRGBO(31, 42, 255, 1.0),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void initPlatformState() async {
    Map<String, double> my_location;
    try {
      my_location = await location.getLocation();
      error = '';
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED')
        error = 'Permission Denied';
      else if (e.code == 'PERMISSION_DENIED_NEVER_ASK')
        error =
        'Permission Denied - Please ask the user to enable it from app settings';
      my_location = null;
    }
    setState(() {
      currentLocation = my_location;
    });
  }
}
