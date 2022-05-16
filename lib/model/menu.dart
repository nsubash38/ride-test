import 'package:flutter/cupertino.dart';

class MenuModel{
  late String menuName;
  late IconData menuIcon;
  late Widget goToPage;

  MenuModel({required this.menuIcon,required this.menuName,required this.goToPage});
}