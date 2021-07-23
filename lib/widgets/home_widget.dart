import 'package:flutter/material.dart';
import '../size.dart';
import 'package:get/get.dart';
import '../controller/getController.dart';
import '../pages/edit_product_screen.dart';

class HomeWidget extends StatefulWidget {
  final int index;
  final Map<String, dynamic> product;

  HomeWidget(this.index, this.product);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final HomeControllers getController = Get.put(HomeControllers());

  Widget buildText({String textInfo}) {
    return Text(
              textInfo,
              style: TextStyle(color: Colors.black, fontSize: 18.0, inherit: false,),
            );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = widthSize(context);
    final double deviceHeight = heightSize(context);

    return Container(
      width: deviceWidth * .31,
      height: MediaQuery.of(context).size.height >600 ? deviceHeight * .21 : deviceHeight * .3,   //deviceHeight * .21
      margin: EdgeInsets.symmetric(
        horizontal: deviceWidth * .01,
        vertical: deviceHeight * .01,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: -5,
            blurRadius: 5,
            offset: Offset(0, 13), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: deviceHeight * .005,
            right: deviceWidth * .62,
            left: deviceWidth * .02,
            bottom: deviceHeight * .005,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                  widget.product['imageUrl'].toString(),
                  fit: BoxFit.fill),
            ),
          ),
          Positioned(
            top: deviceHeight * .01,
            left: deviceWidth * .30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                    textInfo: "Name: ${widget.product['name'].toString()}"),
                SizedBox(height: deviceHeight*.01,),
                buildText(
                    textInfo:
                        "Product type: ${widget.product['productType'].toString()} Eg"),
                SizedBox(height: deviceHeight*.01,),
                buildText(
                    textInfo:
                        "Price: ${widget.product['price'].toString()} Eg"),
                SizedBox(height: deviceHeight*.01,),
                buildText(
                    textInfo: "Fresh: ${widget.product['fresh']..toString()}"),
                SizedBox(height: deviceHeight*.01,),
                buildText(
                    textInfo:
                        "Created at: ${widget.product['createdAt']..toString()}"),
                Container(
                  width: deviceWidth *.55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      print('Delete Product');
                    },
                    child: Text("Delete Product"),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: deviceHeight * .001,
              right: deviceWidth * .02,
              // left: deviceWidth*.3,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Get.to(EditProductScreen(
                    productId: widget.product['_id'].toString(),
                    image: widget.product['imageUrl'].toString(),
                    fruitName: widget.product['name'].toString(),
                    fruitPrice: widget.product['price'].toString(),
                    fruitQuantity: widget.product['quantity'].toString(),
                    fruitType: widget.product['productType'].toString(),
                  )).then(
                        (value) {
                      if (value == "success") {
                        return Get.snackbar(
                          "Edit Product",
                          "Success",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.grey,
                          colorText: Theme.of(context).accentColor,
                        );
                      }
                    },
                  );
                },
              )),
        ],
      ),
    );
  }
}
