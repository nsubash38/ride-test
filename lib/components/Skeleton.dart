import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return TripContainer();
              })
        );
  }


  Widget TripContainer() {
    return Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        height: 316,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShimmerEffect(150,35),
                          SizedBox(height: 5,),
                          ShimmerEffect(150,35),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: ShimmerEffect(150, 35)
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Container(
                                height: 40,
                                child: ShimmerEffect(200, 10),
                                ),
                            SizedBox(height: 5,),
                            ShimmerEffect(35, 35),
                            SizedBox(height: 5,),
                            Container(
                              height: 40,
                              child: ShimmerEffect(200, 10),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Expanded(
              flex: 4,
              child: UserDetails(),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerEffect(100, 40),
                  ShimmerEffect(70, 40)
                ],
              ),
            )
          ],
        ));
  }

  Widget UserDetails() {
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          ShimmerEffect(70, 15),
                          SizedBox(height: 5,),
                          ShimmerEffect(70, 35),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      ShimmerEffect(70, 15),
                                      SizedBox(height: 5,),
                                      ShimmerEffect(70, 35),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      ShimmerEffect(70, 15),
                                      SizedBox(height: 5,),
                                      ShimmerEffect(70, 35),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }

}


Widget ShimmerEffect(double sEffectWidth,double sEffectHeight){
    return Container(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: sEffectWidth,
              height: sEffectHeight,
              color: Colors.white,
            )
          ),
        );
  }
class Skeleton2 extends StatefulWidget {
  const Skeleton2({ Key? key }) : super(key: key);

  @override
  State<Skeleton2> createState() => _Skeleton2State();
}

class _Skeleton2State extends State<Skeleton2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return TripContainer();
              })
        );
  }

  

  Widget TripContainer() {
    return Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        height: 316,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShimmerEffect(150,35),
                          SizedBox(height: 5,),
                          ShimmerEffect(150,35),
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: ShimmerEffect(150, 35)
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Container(
                                height: 40,
                                child: ShimmerEffect(200, 10),
                                ),
                            SizedBox(height: 5,),
                            ShimmerEffect(35, 35),
                            SizedBox(height: 5,),
                            Container(
                              height: 40,
                              child: ShimmerEffect(200, 10),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 15),
              child: DataTable(
                columnSpacing: 0,
                dividerThickness: 5,
                dataRowHeight: 60,
                columns: [
                  DataColumn(
                    label: ShimmerEffect(140, 40)
                  ),
                  DataColumn(
                      label: ShimmerEffect(140, 40)),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Center(
                        child: ShimmerEffect(140, 40))),
                    DataCell(Center(
                        child: ShimmerEffect(140, 40)))
                  ])
                ],
              )),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerEffect(100, 40),
                  ShimmerEffect(100, 40)
                ],
              ),
            )
          ],
        ));
  }
}


class Skeleton3 extends StatelessWidget {
  const Skeleton3({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ContactContainer();
              })
        );
  }

  Widget ContactContainer(){
    return ListTile(
      title: ShimmerEffect(70, 40),
      subtitle: ShimmerEffect(70, 20),
      leading: ShimmerEffect(50,50 ),
    );
  }
}