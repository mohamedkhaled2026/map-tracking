import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  String userName;
  CollectionReference _usersCollectionReference;
  Home(this._usersCollectionReference, this.userName);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Geolocator geo = Geolocator();
  StreamSubscription streamSubscription;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _controller = Completer();
  getLocationStream() {
    streamSubscription = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high, timeInterval: 5)
        .listen((Position position) {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      if (position != null) {
        widget._usersCollectionReference.document(widget.userName).updateData({
          'user_location': GeoPoint(position.latitude, position.longitude),
          'user_status': 'online'
        });
      }
    });
  }

  Future<Position> getCurrentPos() async {
    Position p = Position();
    p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return p;
  }

  Future<List<Map<String, dynamic>>> getUsersGroup() async {
    List<Map<String, dynamic>> usersData = List<Map<String, dynamic>>();
    QuerySnapshot data = await widget._usersCollectionReference.getDocuments();
    for (DocumentSnapshot doc in data.documents) {
      usersData.add(doc.data);
    }
    return usersData;
  }

  getUsersLocation() async {
    DocumentSnapshot doc =
        await widget._usersCollectionReference.document(widget.userName).get();
    print(doc.data['user_type']);
    if (doc.data['user_type'] == 'admin') {
      widget._usersCollectionReference
          .snapshots(includeMetadataChanges: true)
          .listen((docs) {
        for (DocumentSnapshot doc in docs.documents) {
          print(doc.data['user_location'].latitude.toString());
          print(doc.data['user_name'].toString());
          final Marker marker = Marker(
            markerId: MarkerId(doc.data['user_name']),
            position: LatLng(
              doc.data['user_location'].latitude,
              doc.data['user_location'].longitude,
            ),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
                title: doc.data['user_name'], snippet: doc.data['user_status']),
            onTap: () {
              print('hhhhhhhhhhhhhhh');
            },
          );
          print(mounted.toString());
          if (mounted) {
            setState(() {
              markers[MarkerId(doc.data['user_name'])] = marker;
            });
          }
        }
      });
    }
  }

  isLocationServiceEnabled() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (isEnabled) {
      print('enabled');
      getUsersLocation();
      getCurrentPos();
      getLocationStream();
    } else {
      print('disenabled');
      //await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
    }
  }

  setUserOffline() async {
    await widget._usersCollectionReference
        .document(widget.userName)
        .updateData({
      'user_status': 'offline',
    });
  }

  moveCamToUserPosition(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19.0)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checkPer();
    isLocationServiceEnabled();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    streamSubscription.cancel();
    print('offfffffffff');
    setUserOffline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Tracer'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('AlertDialog Title'),
                        content: SingleChildScrollView(
                          child: Container(
                            height: 300,
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: getUsersGroup(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Center(
                                    child: ListView.builder(
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                            onTap: () async{
                                              if(( await widget._usersCollectionReference.document(widget.userName).get()).data['user_type'] == 'admin') {
                                                GeoPoint p = snapshot
                                                    .data[index]
                                                ['user_location'];
                                                moveCamToUserPosition(Position(
                                                    latitude: p.latitude,
                                                    longitude: p.longitude));
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: ListTile(
                                              title: Text(snapshot.data[index]
                                                  ['user_name']),
                                              subtitle: Text(snapshot.data[index]
                                                  ['user_status']),
                                              trailing: Icon(
                                                Icons.person,
                                                color: Colors.lightBlue,
                                              ),
                                            ));
                                      },
                                      itemCount: snapshot.data.length,
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.lightBlue,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              }),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () async {
//              SharedPreferences sharedPreferences =
//                  await SharedPreferences.getInstance();
//              sharedPreferences.setString('user_name', '');
//              sharedPreferences.setString('group_name', '');
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: FutureBuilder<Position>(
          future: getCurrentPos(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                          snapshot.data.latitude, snapshot.data.longitude),
                      zoom: 19.0),
                  mapType: MapType.satellite,
                  trafficEnabled: true,
                  buildingsEnabled: true,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: true,
                  markers: Set<Marker>.of(markers.values),
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                    print('dd');
                  },
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
