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
  String address = "주소 보기";
  bool isAddressShown = false;

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
      return sensorlogJsonList.map((json) => Sensor.fromJson(json)).toList();
    } else {
      throw Exception('서버로부터 데이터를 읽어오는 데 실패했습니다.');
    }
  }

  Future<String> findAddress(double lat, double lng) async {
    final response = await http.get(
      Uri.parse("https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=$lng,$lat&sourcecrs=epsg:4326&output=json&orders=roadaddr"),
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

      if (landNumber2 == '')
        return '$area1 $area2 $area3 $landName $landNumber1 $buildingName';
      else
        return '$area1 $area2 $area3 $landName $landNumber1-$landNumber2 $buildingName';
    } else {
      return "잘못된 주소입니다";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteStyle1,
      appBar: AppBar(
        backgroundColor: whiteStyle1,
        title: Text('현재 위치 조회'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                          position: NLatLng(sensor.latitude, sensor.longitude),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 4),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blueGrey, width: 1),
                  ),
                  color: blueStyle4,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            ' - 위도 : $latitude',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        ListTile(
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
                    side: BorderSide(color: Colors.blueGrey, width: 1),
                  ),
                  color: isAddressShown ? blueStyle4 : blueStyle3,
                  child: ListTile(
                    title: Text(
                      address,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isAddressShown ? FontWeight.w400 : FontWeight.w600,
                      ),
                      textAlign: isAddressShown ? TextAlign.left : TextAlign.center,
                    ),
                    onTap: () async {
                      String addr = await findAddress(latitude, longitude);
                      setState(() {
                        address = addr;
                        isAddressShown = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}