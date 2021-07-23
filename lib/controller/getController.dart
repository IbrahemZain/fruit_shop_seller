import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeControllers extends GetxController {
  List<dynamic> allProducts = [];
  List<dynamic> allOrders = [];
  String classifiedImageName = 'None';
  String freshOrRotten;
  bool isLoading = false;

  String probabilityOfFruit;

  int pageCount = 1;
  int numberPageCount;

  Future logInAuth(String phoneOrEmail, String password) async {
    try {
      final String uri = "https://gradubanana.herokuapp.com/seller/login";
      var body =
          json.encode({"emailOrPhone": phoneOrEmail, "password": password});
      var response = await http.post(
        Uri.parse(uri),
        body: body,
        headers: {
          "Content-Type": "application/json",
        },
      );

      var message = jsonDecode(response.body);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      // print("###################$message");

      if (message['state'] == 1) {
        sharedPreferences.setString('token', message['data']['token']);
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      print(e);
    }
  }

  Future signUpAuth({
    String email,
    String name,
    String mobile,
    String password,
    String comfirmPassword,
    String code,
    String sex,
    String city,
  }) async {
    String message = 'Check net connection';
    String uri = 'https://gradubanana.herokuapp.com/seller/signup';
    var request = http.MultipartRequest('put', Uri.parse(uri));

    request.fields['email'] = email;
    request.fields['name'] = name;
    request.fields['mobile'] = mobile;
    request.fields['password'] = password;
    request.fields['comfirmPassword'] = comfirmPassword;
    request.fields['code'] = code;
    request.fields['sex'] = sex;
    request.fields['city'] = city;

    var res = await request.send();
    final respStr = await res.stream.bytesToString();
    Map<String, dynamic> jResponse = jsonDecode(respStr);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // print("##############################$jResponse");
    if (jResponse['state'] == 1) {
      sharedPreferences.setString('token', jResponse['data']['token']);
      // sharedPreferences.setString('name', jResponse['data']['sellerName']);
      // sharedPreferences.setString('mobile', jResponse['data']['sellerMobile']);
      // sharedPreferences.setString('photo', jResponse['data']['sellerImage']);
      // sharedPreferences.setString('field', jResponse['data']['sellerEmail']);
      return "Authentication succeeded";
    } else {
      message = jResponse['message'];
      return message;
    }
  }

  Future getProduct() async {
    try {
      if (pageCount == 0) {
        pageCount = 1;
        update();
      }
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final String uri =
          "https://gradubanana.herokuapp.com/seller/shop/products?page=$pageCount";
      var response = await http.get(Uri.parse(uri), headers: {
        "Authorization": "hh ${sharedPreferences.getString("token")}",
      });
      var message = jsonDecode(response.body);

      // print(sharedPreferences.getString("token"));
      // print("###################3333333333333333$message");

      if (message['state'] == 1) {
        numberPageCount = (message['total'] / 10).floor().toInt();
        if (pageCount == 1) {
          allProducts = message['products'];
          pageCount++;
          update();
        }

        if (pageCount <= numberPageCount) {
          allProducts.addAll(message['products']);
          pageCount++;
          update();
        }
        return "success";
      } else {

        return response.body.toString();
      }
    } catch (e) {
      print(e);
    }
  }

  Future classifyImage(image) async {
    try {
      var uri = 'https://graduationproject29.herokuapp.com/classify/all/image';
      var request = http.MultipartRequest('post', Uri.parse(uri));
      if (image != "") {
        request.files.add(
          await http.MultipartFile.fromPath(
            'img',
            image,
          ),
        );
      }
      var res = await request.send();
      final respStr = await res.stream.bytesToString();
      var jResponse = jsonDecode(respStr);
      // print("@@@@@@@###@@@@@@@@####@${jResponse}");

      if (res.statusCode == 200) {
        classifiedImageName = jResponse['result']['prdiction'];
        update();

        if (classifiedImageName == "apples" ||
            classifiedImageName == "oranges" ||
            classifiedImageName == "bananas") {
          //call rotten function
          checkFresh(image);
        }
        return res.statusCode;
      } else {
        return res.statusCode;
      }
    } catch (e) {
      print(e);
    }
  }

  Future checkFresh(image) async {
    try {
      var uri = 'https://graduationproject29.herokuapp.com/classify/image';
      var request = http.MultipartRequest('post', Uri.parse(uri));
      if (image != "") {
        request.files.add(
          await http.MultipartFile.fromPath(
            'img',
            image,
          ),
        );
      }
      var res = await request.send();
      final respStr = await res.stream.bytesToString();
      var jResponse = jsonDecode(respStr);
      print("@@@@@@@###@@@@@@@@####@$jResponse");

      if (res.statusCode == 200) {
        freshOrRotten = jResponse['result'][0]['className'];
        probabilityOfFruit = jResponse['result'][0]['probability'];
        update();
        return res.statusCode;
      } else {
        return res.statusCode;
      }
    } catch (e) {
      print(e);
    }
  }

  Future addProduct({
    String image,
    String type,
    String name,
    String price,
    String quantity,
    String fresh,
  }) async {
    String message = 'Check net connection';
    String uri = 'https://gradubanana.herokuapp.com/seller/shop/addProduct';
    var request = http.MultipartRequest('post', Uri.parse(uri));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    request.files.add(
      await http.MultipartFile.fromPath(
        'img',
        image,
      ),
    );
    request.fields['name'] = name;
    request.fields['productType'] = type;
    request.fields['fresh'] = fresh;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity;

    request.headers.addAll(
        {"Authorization": "hh ${sharedPreferences.getString("token")}"});
    var res = await request.send();
    final respStr = await res.stream.bytesToString();
    Map<String, dynamic> jResponse = jsonDecode(respStr);

    // print("##############################$jResponse");
    if (jResponse['state'] == 1) {
      pageCount = 1;
      getProduct();
      update();
      return "Add Done";
    } else {
      message = jResponse['message'];
      return message;
    }
  }

  Future editProduct({
    bool selectedImage,
    String image,
    String type,
    String name,
    String price,
    String quantity,
    String fresh,
    String productId,
  }) async {
    String message = 'Check net connection';
    String uri = 'https://gradubanana.herokuapp.com/seller/shop/editProduct';
    var request = http.MultipartRequest('post', Uri.parse(uri));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    selectedImage == true ? request.files.add(
      await http.MultipartFile.fromPath(
        'img',
        image,
      ),
    ) : request.fields['img'] = image;
    request.fields['name'] = name;
    request.fields['productType'] = type;
    request.fields['fresh'] = fresh;
    request.fields['price'] = price;
    request.fields['quantity'] = quantity;
    request.fields['id'] = productId;

    //eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiIwMTE5NTY5MDU1NTIiLCJ1c2VySWQiOiI2MGQ5ZWUyMzZlMzExNzQyZWUwNGFmODAiLCJ1cGRhdGVkIjoiMTYyNDg5NTAxMTM1OSIsImlhdCI6MTYyNDg5NTAxMX0.g6Qu4uvB8zvDyrzozJnqmbs_LPQaCL0qdUFrFOAnyIc
    //${sharedPreferences.getString("token")
    request.headers.addAll(
        {"Authorization": "hh ${sharedPreferences.getString("token")}"});
    var res = await request.send();
    final respStr = await res.stream.bytesToString();
    Map<String, dynamic> jResponse = jsonDecode(respStr);

    print("##############################$jResponse");
    if (jResponse['state'] == 1) {
      return "Edit Done";
    } else {
      message = jResponse['message'];
      return message;
    }
  }

  Future getOrder({String status}) async {
    try {
      isLoading = true;
      update();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final String uri =
          "https://gradubanana.herokuapp.com/seller/shop/getOrders?status=${status == null? '' : status}";

      var response = await http.get(
        Uri.parse(uri),
        headers: {
          HttpHeaders.authorizationHeader:
              "Bearer ${sharedPreferences.getString("token")}"
        },
      );

      var message = jsonDecode(response.body);

      print("###############################$message");

      if (response.statusCode == 200) {
        allOrders = message['sloldItems']['sloldItems'];
        print("###############################$allOrders");
        isLoading = false;
        update();
        return "success";
      } else {
        isLoading = false;
        update();
        return response.body.toString();
      }
    } catch (e) {
      print(e);
    }
  }
}
