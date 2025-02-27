// import 'package:geocoding/geocoding.dart';
// import 'package:location/location.dart' as loc;

// class LocationService {
//   final loc.Location _location = loc.Location();

//   Future<Map<String, dynamic>?> getLocationAndAddress() async {
//     bool serviceEnabled;
//     loc.PermissionStatus permissionGranted;

//     serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) return null;
//     }

//     permissionGranted = await _location.hasPermission();
//     if (permissionGranted == loc.PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != loc.PermissionStatus.granted) return null;
//     }

//     final locationData = await _location.getLocation();

//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       locationData.latitude!,
//       locationData.longitude!,
//     );

//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks[0];

//       return {
//         'latitude': locationData.latitude!,
//         'longitude': locationData.longitude!,
//         'formattedAddress': place.name ?? place.street ?? '',
//         'streetNumber': place.thoroughfare ?? '',
//         'route': place.subLocality ?? '',
//         'locality': place.locality ?? '',
//         'administrative_area_level_1': place.subAdministrativeArea ?? '',
//         'administrative_area_level_2': place.administrativeArea ?? '',
//         'country': place.country ?? '',
//         'postal_code': place.postalCode ?? '',
//       };
//     }
//     // city, state, pin code
//     return null;
//   }
// }

import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  final loc.Location _location = loc.Location();

  Future<Map<String, dynamic>?> getLocationAndAddress() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled)
        return null; // Return null if service is still disabled
    }

    // Check if permission is granted
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return null; // Return null if permission is not granted
      }
    }

    // Get the current location
    final locationData = await _location.getLocation();
    print(locationData);
    // Get address using geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(
      locationData.latitude!,
      locationData.longitude!,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];

      return {
        'latitude': locationData.latitude!,
        'longitude': locationData.longitude!,
        'formattedAddress': place.name ?? place.street ?? '',
        'streetNumber': place.thoroughfare ?? '',
        'route': place.subLocality ?? '',
        'locality': place.locality ?? '',
        'administrative_area_level_1': place.subAdministrativeArea ?? '',
        'administrative_area_level_2': place.administrativeArea ?? '',
        'country': place.country ?? '',
        'postal_code': place.postalCode ?? '',
      };
    }
    // Return null if no placemarks were found
    return null;
  }
}
