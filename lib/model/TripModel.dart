import 'package:ridetripper/model/RiderTrip.dart';
import 'package:ridetripper/model/User.dart';

class TripModel {
  String id;
  DateTime date;
  String starting_point;
  String ending_point;
  String? vehicle_number;
  double starting_lat;
  double starting_lng;
  double ending_lat;
  double ending_lng;
  int? number_seats;
  String? vehicle_type;
  int? cost_seat;
  User? driver;
  List<RiderTrip>? riderList = [];
  String? docId;

  TripModel(
      {required this.id,
      required this.date,
      required this.starting_point,
      required this.ending_point,
      this.starting_lat = 0.0,
      this.starting_lng = 0.0,
      this.ending_lat = 0.0,
      this.ending_lng = 0.0,
      this.number_seats,
      this.vehicle_type,
      this.cost_seat,
      this.vehicle_number,
      this.driver,
      this.riderList,
      this.docId});

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'starting_point': starting_point,
        'ending_point': ending_point,
        'starting_lat': starting_lat,
        'starting_lng': starting_lng,
        'ending_lat': ending_lat,
        'ending_lng': ending_lng,
        'number_seats': number_seats,
        'vehicle_type': vehicle_type,
        'vehicle_number': vehicle_number,
        'cost_seat': cost_seat,
      };

  Map<String, dynamic> toJsonRequest() => {
        'id': id,
        'date': date,
        'starting_point': starting_point,
        'ending_point': ending_point,
        'starting_lat': starting_lat,
        'starting_lng': starting_lng,
        'ending_lat': ending_lat,
        'ending_lng': ending_lng,
        'number_seats': number_seats,
        'vehicle_type': vehicle_type,
        'cost_seat': cost_seat,
        'vehicle_number': vehicle_number,
        'requesterId': docId
      };

  static TripModel fromJson(Map<String, dynamic> json) => TripModel(
        id: json["id"],
        date: json["date"].toDate(),
        starting_point: json["starting_point"],
        ending_point: json["ending_point"],
        number_seats: json["number_seats"],
        vehicle_number: json["vehicle_number"],
        vehicle_type: json["vehicle_type"],
        cost_seat: json["cost_seat"],
      );

  static TripModel fromJsonRequestTrip(Map<String, dynamic> json) => TripModel(
        id: json["id"],
        date: json["date"].toDate(),
        starting_point: json["starting_point"],
        ending_point: json["ending_point"],
        starting_lat: json['starting_lat'],
        starting_lng: json['starting_lng'],
        ending_lat: json['ending_lat'],
        ending_lng: json['ending_lng'],
        vehicle_number: json["vehicle_number"],
        vehicle_type: json["vehicle_type"],
        number_seats: json["number_seats"],
        cost_seat: json["cost_seat"],
      );
}
