class User {
  String? id;
  String email;
  String name;
  int phoneno;
  String password;
  String address;
  List? vehicleList;
  String user_img;
  String nid_img;
  String drivingLicense_img;
  String? deviceToken;
  String docId;

  User({
    this.id,
    this.email = '',
    required this.name,
    required this.phoneno,
    this.password='',
    this.address = '',
    this.vehicleList,
    this.user_img = '',
    this.nid_img = '',
    this.drivingLicense_img = '',
    this.deviceToken,
    this.docId=""
  });


  Map<String, dynamic> toJsonRider() =>
      {'email': email, 
      'name': name, 
      'phoneno': phoneno, 
      'password': password,
      'token':deviceToken,
      'user_img':user_img
      };

 Map<String, dynamic> toJsonTrip() =>
      {'name': name, 
      'phoneno': phoneno,
      'user_img': user_img
      };

  Map<String, dynamic> toJsonDriver() =>
      {'email': email, 
      'name': name, 
      'phoneno': phoneno, 
      'password': password,
      'address': address,
      'vehicleList':vehicleList,
      'user_img':user_img,
      'nid_img':nid_img,
      'drivingLicense_img':drivingLicense_img,
      'token': deviceToken
      };

  static User fromJson(Map<String, dynamic> json) => User(
      name: json['name'],
      phoneno: json['phoneno'],
      user_img: json["user_img"],
      vehicleList: json['vehicleList']
      );

  static User fromJsonDriverInfo(Map<String, dynamic> json) => User(
      name: json['name'],
      phoneno: json['phoneno'],
      user_img: json["user_img"]
      );

  static User fromJsonRiderInfo(Map<String, dynamic> json) => User(
      name: json['name'],
      phoneno: json['phoneno']
      );
}
