import 'package:ridetripper/model/User.dart';

class RiderTrip{
  String id;
  String riderId;
  String pickup_point;
  int fare;
  int seats;
  User? rider;
  String? docId;

  RiderTrip({
    required this.id,
    required this.riderId,
    required this.pickup_point,
    required this.fare,
    required this.seats,
    this.rider,
    this.docId
  });

  Map<String, dynamic> toJsonTrip() =>
      {
      'id': id, 
      'riderId': riderId,
      'pickup_point':pickup_point,
      'fare':fare,
      'seats':seats 
      };

static RiderTrip fromJson(Map<String, dynamic> json) => RiderTrip(
      id: json['id'],
      riderId: json['riderId'],
      pickup_point: json["pickup_point"],
      fare: json['fare'],
      seats: json['seats']
      );

}