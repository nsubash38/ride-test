// ignore_for_file: file_names

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({Key? key}) : super(key: key);
  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const bannerImages = [
    "assets/images/share.jpg",
    "assets/images/carrental.jpg",
    "assets/images/bikerental.jpg",
    "assets/images/minibus.jpg"
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CarouselSlider.builder(
        itemCount: bannerImages.length,
        itemBuilder: (context, index, realIndex) {
          final imageUrl = bannerImages[index];
          return buildImage(imageUrl: imageUrl, index: index);
        },
        options: CarouselOptions(
          height: 200,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
          enableInfiniteScroll: false,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
        ),
      ),
    );
  }

  Widget buildImage({required String imageUrl, required int index}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.8),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(0, 10), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: 1000.0,
          ),
        ),
      ),
    );
  }
}
