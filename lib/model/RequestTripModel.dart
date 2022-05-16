import 'package:ridetripper/model/TripModel.dart';
import 'package:ridetripper/model/Vehicle.dart';

class RequestTripModel{
  TripModel? tripModel;
  List<String>? vehicleList;
  String? requesterId;

  RequestTripModel({
    this.tripModel,
    this.vehicleList,
    this.requesterId
  });
}