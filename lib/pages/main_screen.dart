import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graduation_project_seller/controller/getController.dart';
import 'add_product_screen.dart';
import 'order_screen.dart';
import 'home_screen.dart';
import 'package:image_picker/image_picker.dart';

String stateOrder = "";

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final HomeControllers getController = Get.put(HomeControllers());
  int _currentIndex = 0;
  var _imageFile;

  final List<Widget> _children = [
    HomeScreen(),
    OrderScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  chooseFromCamera() async {
    Get.back();
    // ignore: invalid_use_of_visible_for_testing_member
    final imageFile = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      _imageFile = imageFile.path;
    });
    Get.to(AddProductScreen(_imageFile)).then((value) {
      if (value == "success") {
        return Get.snackbar(
          "Add Product",
          "Success",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          colorText: Theme.of(context).accentColor,
        );
      }
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
      _imageFile = imageFile.path;
    });
    Get.to(AddProductScreen(_imageFile)).then(
      (value) {
        if (value == "success") {
          return Get.snackbar(
            "Add Product",
            "Success",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey,
            colorText: Theme.of(context).accentColor,
          );
        }
      },
    );
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
  _buildDrawer(){
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child:  Center(child: Text("Setting",style: TextStyle(fontSize:25,fontWeight: FontWeight.normal),)),
          ),
          ListTile(
            title: Text('Edit Personal Info'),
            onTap: () {
              // Edit info
            },
          ),
          ListTile(
            title: Text('Connect Us'),
            onTap: () {
              // Edit info
            },
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 10,
            ),
            onPressed: () {},
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: _currentIndex == 0 ? Text('Home Screen') : Text("Card Screen"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: _currentIndex == 1 ? [
          PopupMenuButton<String>(
            onSelected: (value) {
              print(value);
              if(value == "Started"){
                getController.getOrder(status: "started");
                setState(() {
                  stateOrder="started";
                });
              }else if (value == "Ended"){
                getController.getOrder(status: "ended");
                setState(() {
                  stateOrder="ended";
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Started'),
                  value: 'Started',
                ),
                PopupMenuItem(
                  child: Text('Ended'),
                  value: 'Ended',
                ),
              ];
            },
          ),
        ] : null ,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).accentColor,
        //Colors.red,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Theme.of(context).accentColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            label: 'Order',
          ),
        ],
      ),
      body: _children[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              elevation: 0.0,
              child: new Icon(Icons.add),
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () {
                selectImage(context);
              },
            )
          : null,
    );
  }
}
