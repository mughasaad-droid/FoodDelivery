import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  String _currentAddress = 'Choose your location';

  String get currentAddress => _currentAddress;

  void setAddress(String address) {
    _currentAddress = address;
    notifyListeners();
  }
}
