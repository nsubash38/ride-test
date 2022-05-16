class Vehicle{
  String vehicle_type;
  String vehicle_number;
  String? vehicle_image;

  Vehicle({required this.vehicle_type,required this.vehicle_number,this.vehicle_image});

  Map<String, dynamic> toJson() =>
      {'vehicle_type': vehicle_type, 
      'vehicle_number': vehicle_number,
      'vehicle_image': vehicle_image
      };

  static Vehicle fromJson(Map<String, dynamic> json) => Vehicle(
      vehicle_type: json['vehicle_type'],
      vehicle_number: json['vehicle_number']
      );
}
