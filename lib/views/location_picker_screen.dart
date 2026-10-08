import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(31.5204, 74.3587); // Default Lahore
  String _address = "Fetching address...";
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey = "AIzaSyAtmRBlLOVvRZ1l3zlSGZ1v-ZW8lfbpK6A";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    });
    _fetchAddress(_currentPosition);
  }

  // Common method to fetch address based on platform
  Future<void> _fetchAddress(LatLng position) async {
    if (kIsWeb) {
      await _getAddressFromGoogleAPI(position);
    } else {
      await _getAddressFromNativeGeocoding(position);
    }
  }

  // Native Geocoding (Android/iOS)
  Future<void> _getAddressFromNativeGeocoding(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = "${place.street}, ${place.subLocality}, ${place.locality}";
          _searchController.text = _address;
        });
      }
    } catch (e) {
      debugPrint("Native Geocoding Error: $e");
    }
  }

  // Web Geocoding (Using Google HTTP API)
  Future<void> _getAddressFromGoogleAPI(LatLng position) async {
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          setState(() {
            _address = data['results'][0]['formatted_address'];
            _searchController.text = _address;
          });
        }
      }
    } catch (e) {
      debugPrint("Web Geocoding Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Part: Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) {
                    _currentPosition = position.target;
                  },
                  onCameraIdle: () {
                    _fetchAddress(_currentPosition);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // Center Marker (Fixed)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 35),
                    child: Icon(Icons.location_on, color: Color(0xFFf06626), size: 45),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 50,
                  left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf06626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Part: Controls (Address & Button)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Set your location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                // Search Bar / Address Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search address...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFFf06626)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.orange.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Set Location Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _address);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf06626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Set Location',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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
