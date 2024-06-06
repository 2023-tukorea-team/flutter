import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'package:team2/config/ApiConfig.dart';
import 'package:team2/config/NaverMapConfig.dart';

import '../models/Sensor.dart';
import '../models/User.dart';
import '../models/Usersensor.dart';
import '../theme/Colors.dart';

class MapPage extends StatefulWidget {
  final Usersensor usersensor;
  final User user;

  MapPage({required this.usersensor, required this.user});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String url = ApiConfig.baseUrl;
  late Future<List<Sensor>> sensorDataFuture;
  double latitude = 37.340523;
  double longitude = 126.734424;
  List<Sensor> sensorData = [];
  String address = "";

  @override
  void initState() {
    super.initState();
    sensorDataFuture = fetchSensorData();
  }

  Future<List<Sensor>> fetchSensorData() async {
    final response = await http.post(
      Uri.parse('$url/sensor/locate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': widget.usersensor.sensorid}),
    );
    if (response.statusCode == 200) {
      List<dynamic> sensorlogJsonList = json.decode(response.body);
      findAddress(sensorlogJsonList[0]['latitude'], sensorlogJsonList[0]['longitude']);
      return sensorlogJsonList.map((json) => Sensor.fromJson(json)).toList();
    } else {
      throw Exception('서버로부터 데이터를 읽어오는 데 실패했습니다.');
    }
  }

  Future<String> findAddress(double lat, double lng) async {
    final response = await http.get(
      Uri.parse(
          "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=$lng,$lat&sourcecrs=epsg:4326&output=json&orders=roadaddr"),
      headers: {
        "X-NCP-APIGW-API-KEY-ID": NaverMapConfig.ClientID,
        "X-NCP-APIGW-API-KEY": NaverMapConfig.ClientSecret
      },
    );

    if (response.statusCode == 200) {
      final addressData = json.decode(response.body);
      var result = addressData['results'][0];
      var region = result['region'];
      var land = result['land'];

      String area1 = region['area1']['name'];
      String area2 = region['area2']['name'];
      String area3 = region['area3']['name'];
      String landName = land['name'];
      String landNumber1 = land['number1'];
      String landNumber2 = land['number2'];
      String buildingName = land['addition0']['value'];

      if (landNumber2 == '') {
        setState(() {
          address = '$area1 $area2 $area3 $landName $landNumber1 $buildingName';
        });
        return '$area1 $area2 $area3 $landName $landNumber1 $buildingName';
      } else {
        setState(() {
          address = '$area1 $area2 $area3 $landName $landNumber1-$landNumber2 $buildingName';
        });
        return '$area1 $area2 $area3 $landName $landNumber1-$landNumber2 $buildingName';
      }
      } else {
      return "잘못된 주소입니다";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('현재 위치 조회'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                " 실시간 내 차 위치",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                height: 400,
                child: FutureBuilder<List<Sensor>>(
                  future: sensorDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('데이터를 불러오는 중에 오류가 발생했습니다.'));
                    } else {
                      sensorData = snapshot.data!;
                      if (sensorData.isNotEmpty) {
                        latitude = sensorData.first.latitude;
                        longitude = sensorData.first.longitude;
                      }
                      return NaverMap(
                        options: NaverMapViewOptions(
                          initialCameraPosition: NCameraPosition(
                            target: NLatLng(latitude, longitude),
                            zoom: 15,
                            bearing: 0,
                            tilt: 0,
                          ),
                        ),
                        onMapReady: (controller) {
                          for (var sensor in sensorData) {
                            final marker = NMarker(
                              id: sensor.id.toString(),
                              position: NLatLng(
                                  sensor.latitude, sensor.longitude),
                            );
                            controller.addOverlay(marker);
                            final onMarkerInfoWindow = NInfoWindow.onMarker(
                              id: marker.info.id,
                              text: widget.usersensor.name,
                            );
                            marker.openInfoWindow(onMarkerInfoWindow);
                          }
                        },
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                " 좌표 및 주소",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      color: blueStyle4,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              tileColor: whiteStyle2,
                              title: Text(
                                ' - 위도 : $latitude',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            _buildDivider(),
                            ListTile(
                              tileColor: whiteStyle2,
                              title: Text(
                                ' - 경도 : $longitude',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey, width: 1),
                      ),
                      child: ListTile(
                        tileColor: whiteStyle2,
                        title: Text(
                          address,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery
            .of(context).size.width,
        height: 1,
        color: whiteStyle3,
      ),
    );
  }
}