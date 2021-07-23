import 'dart:io';
import 'package:get/get.dart';
import 'package:graduation_project_seller/controller/getController.dart';

import '../size.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  final selectedImage;

  AddProductScreen(this.selectedImage);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final HomeControllers getController = Get.put(HomeControllers());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String fruitTypeEntered = '';
  String fruitNameEntered;
  String probabilityFruit = '';
  String fruitPrice;
  String fruitQuantity;
  String fruitTypeClassify;

  @override
  void initState() {
    super.initState();
    classifyImages();
  }

  Widget buildText({String textInfo}) {
    return Align(
        alignment: Alignment(-1, -1),
        child: Row(children: <Widget>[
          Text(textInfo,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                inherit: false,
              ))
        ]));
  }

  classifyImages() async {
    var statusCode = await getController.classifyImage(widget.selectedImage);
    if (statusCode == 200) {
      print("#######@2222222DOne $fruitTypeClassify");
      setState(() {
        fruitTypeClassify = getController.classifiedImageName;
      });
    } else {
      print("The statusCode of classify Image is : $statusCode");
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    var message = await getController.addProduct(
      image: widget.selectedImage,
      name: fruitNameEntered,
      price: fruitPrice,
      quantity: fruitQuantity,
      fresh: probabilityFruit,
      type: fruitTypeEntered.isEmpty ? fruitTypeClassify : fruitTypeEntered,
    );
    if (message == "Add Done") {
      return Get.back(result: "success");
    }else{
      print(message);
    }
  }

  bool checkFruit(){
    if (getController.classifiedImageName == "apples" ||
        getController.classifiedImageName == "oranges" ||
        getController.classifiedImageName == "bananas") {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // final double deviceWidth = widthSize(context);
    final double deviceHeight = heightSize(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Add Product"),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              Container(
                height: deviceHeight*.25,
                child: Image(
                  image: FileImage(File(widget.selectedImage)),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: deviceHeight * .01),
              fruitTypeClassify != null
                  ? Column(
                children: [
                  GetBuilder<HomeControllers>(
                    builder: (_) => buildText(
                        textInfo:
                        "The Name fruit is: ${getController.classifiedImageName}"),
                  ),
                  checkFruit() ?
                  GetBuilder<HomeControllers>(builder: (_) {
                    return buildText(
                        textInfo:
                        "The Fruit is: ${getController.freshOrRotten == null ? "Not Defined" : getController.freshOrRotten}");
                  }) : SizedBox(),
                  checkFruit() ?
                  GetBuilder<HomeControllers>(builder: (_) {
                    probabilityFruit =
                        getController.probabilityOfFruit;
                    return buildText(
                        textInfo:
                        "The probability is: ${getController.probabilityOfFruit == null ? "Not Defined" : getController.probabilityOfFruit + "%"}");
                  }): SizedBox(),
                  Divider(
                    color: Colors.black45,
                  )
                ],
              )
                  : Center(child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("Image is Proccessing...")
                    ],
                  )),
              buildText(textInfo: "Type Of Fruit:"),
              TextFormField(
                textDirection: TextDirection.rtl,
                maxLength: 15,
                autovalidateMode: AutovalidateMode.always,
                textAlign: TextAlign.left,
                cursorColor: Colors.grey,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    hintText:
                    'Enter Type of Fruit if the Type is incorrect',
                    hintStyle: TextStyle(color: Colors.black12)),
                onSaved: (value) {
                  fruitTypeEntered = value;
                },
              ),
              SizedBox(height: deviceHeight*.01,),
              buildText(textInfo: "Name: "),
              TextFormField(
                textDirection: TextDirection.rtl,
                maxLength: 15,
                autovalidateMode: AutovalidateMode.always,
                textAlign: TextAlign.left,
                cursorColor: Colors.grey,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    hintText: 'Enter Name of Fruit',
                    hintStyle: TextStyle(color: Colors.black12)),
                onSaved: (value) {
                  fruitNameEntered = value;
                },
                validator: (String value) {
                  if (value.isEmpty || value.length < 4) {
                    return "Please Enter Valid Name ";
                  }
                  return null;
                },
              ),
              SizedBox(height: deviceHeight*.01,),
              buildText(textInfo: "Price :"),
              TextFormField(
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                autovalidateMode: AutovalidateMode.always,
                textAlign: TextAlign.left,
                cursorColor: Colors.grey,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    hintText: 'Enter Price of 1 Kg',
                    hintStyle: TextStyle(color: Colors.black12)),
                onSaved: (value) {
                  fruitPrice = value;
                },
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Please Enter price ";
                  }
                  return null;
                },
              ),
              SizedBox(height: deviceHeight*.01,),
              buildText(textInfo: "Quantity :"),
              TextFormField(
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                autovalidateMode: AutovalidateMode.always,
                textAlign: TextAlign.left,
                cursorColor: Colors.grey,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    hintText: 'Enter Quantity of Fruit',
                    hintStyle: TextStyle(color: Colors.black12)),
                onSaved: (value) {
                  fruitQuantity = value;
                },
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Please Enter Quantity ";
                  }
                  return null;
                },
              ),
              SizedBox(height: deviceHeight*.02,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: (){
                  _submitForm();
                },
                child: Text(
                  'Add Product',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
