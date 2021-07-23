import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/getController.dart';
import '../widgets/home_widget.dart';
import '../size.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeControllers getController = Get.put(HomeControllers());
  ScrollController scrollController = ScrollController();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool check = true;
  List<dynamic> products;

  @override
  void initState() {
    getData();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getData();
      }
    });
    super.initState();
  }

  getData() {
    getController.getProduct();
  }
  Future<Null> _getAllDataRefresh() async {
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(Duration(seconds: 2));
    getController.pageCount = 1;
    getData();
  }
  bool checkDataNotExist() {
    check = getController.allProducts == null ? true : false;
    return check;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = widthSize(context);
    final double deviceHeight = heightSize(context);

    return checkDataNotExist()
        ? Center(child: Text('There is no Product in this Time',style: TextStyle(fontSize: 20),))
        : (getController.allProducts == null ? Center(child:CircularProgressIndicator()):RefreshIndicator(
      onRefresh: _getAllDataRefresh,
      displacement: 5,
      child: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(
                right: deviceWidth * .04,
                top: deviceHeight * .003,
                left: deviceWidth * .04,
                bottom: deviceHeight * .003),
            child: GetBuilder<HomeControllers>(builder: (_) {
              return ListView.builder(
                controller: scrollController,
                itemCount: getController.allProducts.length,
                shrinkWrap: true,
                itemBuilder: (context, int index) =>
                    HomeWidget(index, getController.allProducts[index]),
              );
            }),
          ),
        ],
      ),
    ));
  }
}

