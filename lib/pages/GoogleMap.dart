// ignore_for_file: unused_field, unnecessary_new

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:geolocator/geolocator.dart' as geoLoc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  geoLoc.Position? _currentLocation;
  SearchInfo selectedPlace = SearchInfo();
  TextEditingController _searchController = TextEditingController();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.3652, 88.5956),
    zoom: 14.4746,
  );
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List<SearchInfo> _list = [];
  bool isVisible = true;
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    _getUserLocation();
    super.initState();
  }

  Future<geoLoc.Position> _getLocationPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error("Service Disabled");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error("Permission Denied");
      }
    }

    _locationData = await location.getLocation();

    return geoLoc.Geolocator.getCurrentPosition(
        desiredAccuracy: geoLoc.LocationAccuracy.high);
  }

  _userLocation() async {
    return await _getLocationPermission();
  }

  _getUserLocation() async {
    _currentLocation = await _getLocationPermission();
    List<geoCoding.Placemark> newPlace = await geoCoding.placemarkFromCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);
    
    geoCoding.Placemark place = newPlace[0];
    Address currentAddress = Address(
      postcode: place.postalCode,
      street: place.street,
      city: place.locality,
      name: place.name,
      state: place.administrativeArea,
      country: place.country 
    );
    print(currentAddress.toString()+"Address");
    var currentLocationInfo = SearchInfo(
        address: currentAddress,
          point: GeoPoint(
              latitude: _currentLocation!.latitude,
              longitude: _currentLocation!.longitude));
    setState(() {
          selectedPlace = currentLocationInfo;
          //print(selectedPlace.address);
    });

    _goToCurrentPosition(
        LatLng(_currentLocation!.latitude, _currentLocation!.longitude));
  }

  Future<void> _goToCurrentPosition(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    final marker = Marker(
      markerId: MarkerId('place_name'),
      position: LatLng(latLng.latitude, latLng.longitude),
      // icon: BitmapDescriptor.,
      infoWindow: InfoWindow(
        title: 'title',
        snippet: 'address',
      ),
    );

    setState(() {
      markers[MarkerId('place_name')] = marker;
    });
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(latLng.latitude, latLng.longitude),
        zoom: 19.151926040649414)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              onChanged: (value) async {
                setState(() {
                  isVisible = true;
                });
                List<SearchInfo> suggestions = await addressSuggestion(value);
                if (mounted) {
                  setState(() {
                    _list = suggestions;
                  });
                }
              },
              controller: _searchController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blueAccent,
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: markers.values.toSet(),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: 0,
                    right: 0,
                    height: 300,
                    child: Visibility(
                      visible: isVisible,
                      child: ListView.builder(
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          return placeContainer(context, _list[index]);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                      top: MediaQuery.of(context).size.height - 200,
                      left: 15,
                      right: 15,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          print(selectedPlace.address.toString()+"newAddress");
                          Navigator.of(context).pop(selectedPlace);
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(fontSize: 20),
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget placeContainer(BuildContext context, SearchInfo place) {
    return GestureDetector(
      onTap: () {
        _searchController.text = place.address.toString();
        setState(() {
          selectedPlace = place;
          isVisible = false;
        });
        _goToCurrentPosition(
            LatLng(place.point!.latitude, place.point!.longitude));
      },
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade300,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_pin,
                  size: 35,
                ),
                Container(
                  width: 295,
                  child: Text(
                    place.address.toString(),
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 6,
          )
        ],
      ),
    );
  }
}
