import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationController extends GetxController {
  static LocationController get() {
    return Get.find<LocationController>();
  }
  var street = ''.obs;
  var ward = ''.obs;
  var district = ''.obs;
  var city = ''.obs;
  var province = ''.obs;
  var country = ''.obs;
  var isLoading = false.obs;
  var hamlet = ''.obs; // Thôn
  var commune = ''.obs; // Xã
  var selectedAddress = ''.obs;

  Future<void> fetchLocation() async {
    try {
      isLoading.value = true;
      Position pos = await _determinePosition();

      await setLocaleIdentifier('vi_VN');

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.first;

      // Cập nhật các giá trị địa chỉ
      street.value = place.street ?? '';
      ward.value = place.subLocality ?? '';
      district.value = place.subAdministrativeArea ?? '';
      city.value = place.locality ?? '';
      province.value = place.administrativeArea ?? '';
      country.value = place.country ?? '';

      // Xây dựng địa chỉ theo thứ tự ưu tiên
      String address = '';
      
      // Thêm số nhà và tên đường nếu có
      if (street.value.isNotEmpty) {
        address += street.value;
      }
      
      // Thêm phường/xã nếu có
      if (ward.value.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += ward.value;
      }
      
      // Thêm quận/huyện nếu có
      if (district.value.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += district.value;
      }
      
      // Thêm thành phố nếu có
      if (city.value.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += city.value;
      }
      
      // Thêm tỉnh/thành phố nếu có
      if (province.value.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += province.value;
      }

      // Nếu không có địa chỉ nào, hiển thị tọa độ
      if (address.isEmpty) {
        address = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      }

      selectedAddress.value = address;
      
      // Ưu tiên tách thôn và xã từ street
      _extractHamletAndCommuneFromStreet(street.value);

    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _extractHamletAndCommuneFromStreet(String fullStreet) {
    final parts = fullStreet.split(RegExp(r'\s+'));
    if (parts.length >= 4) {
      hamlet.value = parts[0]; // VD: "158"
      commune.value = parts.sublist(1).join(" ");
    } else {
      hamlet.value = '';
      commune.value = '';
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ định vị đang tắt.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Quyền truy cập vị trí bị từ chối vĩnh viễn, không thể yêu cầu lại.');
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }
}

class BindingsLocation extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<LocationController>(() => LocationController());
  }
}
