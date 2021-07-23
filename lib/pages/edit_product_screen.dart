import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_seller/controller/getController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../size.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final String fruitName;
  final String fruitType;
  final String fruitPrice;
  final String fruitQuantity;
  final String image;

  EditProductScreen(
      {this.productId,
      this.fruitPrice,
      this.fruitQuantity,
      this.fruitName,
      this.fruitType,
      this.image});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final HomeControllers getController = Get.put(HomeControllers());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedImage = '';
  String fruitTypeEntered = '';
  String fruitNameEntered ;
  String probabilityFruit = '';
  String fruitPrice;
  String fruitQuantity;
  String fruitTypeClassify;
  var _image;

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
    var statusCode = await getController.classifyImage(_image);
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
    var message = await getController.editProduct(
      selectedImage: selectedImage.isEmpty ? false : true,
      image: selectedImage.isEmpty ? _image : selectedImage,
      name: fruitNameEntered,
      price: fruitPrice,
      quantity: fruitQuantity,
      fresh: probabilityFruit,
      productId: widget.productId,
      type: fruitTypeEntered.isEmpty ? fruitTypeClassify : fruitTypeEntered,
    );
    if (message == "Edit Done") {
      return Get.back(result: "success");
    }else{
      print(message);
    }
  }
  chooseFromCamera() async {
    Get.back();
    // ignore: invalid_use_of_visible_for_testing_member
    final imageFile = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      // _image = imageFile.path;
      selectedImage = imageFile.path;
    });
  }
  chooseFromGallery() async {
    Get.back();
    // ignore: invalid_use_of_visible_for_testing_member
    final imageFile = await ImagePicker.platform.pickImage(
      imageQuality: 0,
      source: ImageSource.gallery,
    );
    setState(() {
      // _image = imageFile.path;
      selectedImage = imageFile.path;
    });
    classifyImages();
  }
  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Select Image"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Take Photo from camera"),
                onPressed: chooseFromCamera,
              ),
              SimpleDialogOption(
                child: Text("open Gallery"),
                onPressed: chooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Close"),
                onPressed: () => Get.back(),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    fruitNameEntered = widget.fruitName;
    fruitTypeClassify = widget.fruitType;
    _image = widget.image;
    fruitPrice = widget.fruitPrice;
    fruitQuantity = widget.fruitQuantity;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // final double deviceWidth = widthSize(context);
    final double deviceHeight = heightSize(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Product"),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(15),
            children: [
              Container(
                height: deviceHeight*.25,
                child: selectedImage.isEmpty? Image.network(
                  _image,
                  fit: BoxFit.fill,
                ): Image(
                  image: FileImage(File(selectedImage)),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: deviceHeight*.01),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  selectImage(context);
                },
                child: Text(
                  'Select Image',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: deviceHeight*.01),
              getController.freshOrRotten != null
                  ? Column(
                children: [
                  GetBuilder<HomeControllers>(
                    builder: (_) => buildText(
                        textInfo:
                        "The Name fruit is: ${getController.classifiedImageName}"),
                  ),
                  GetBuilder<HomeControllers>(builder: (_) {
                    return buildText(
                        textInfo:
                        "The Fruit is: ${getController.freshOrRotten == null ? "Not Defined" : getController.freshOrRotten}");
                  }),
                  GetBuilder<HomeControllers>(builder: (_) {
                    probabilityFruit =
                        getController.probabilityOfFruit;
                    return buildText(
                        textInfo:
                        "The probability is: ${getController.probabilityOfFruit == null ? "Not Defined" : getController.probabilityOfFruit + "%"}");
                  }),
                ],
              )
                  : Center(child: Text("Select Image to get classify")),
              SizedBox(height: deviceHeight*.01),
              buildText(textInfo: "Type Of Fruit:"),
              TextFormField(
                initialValue: fruitTypeClassify,
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
              SizedBox(height: deviceHeight*.01),
              buildText(textInfo: "Name: "),
              TextFormField(
                initialValue: fruitNameEntered,
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
              SizedBox(height: deviceHeight*.01),
              buildText(textInfo: "Price :"),
              TextFormField(
                initialValue: fruitPrice,
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
              SizedBox(height: deviceHeight*.01),
              buildText(textInfo: "Quantity :"),
              TextFormField(
                initialValue: fruitQuantity,
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
              SizedBox(height: deviceHeight*.02),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _submitForm,
                child: Text(
                  'Edit Product',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        )
    );
  }
}
