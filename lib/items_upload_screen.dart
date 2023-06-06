import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

import 'api_consumer.dart';
import 'home_screen.dart';

class ItemsUploadScreen extends StatefulWidget {
  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen> {
  Uint8List? imageFileUint8List;

  TextEditingController sellerNameTextEditingController =
      TextEditingController();
  TextEditingController sellerPhoneTextEditingController =
      TextEditingController();
  TextEditingController itemNameTextEditingController = TextEditingController();
  TextEditingController itemDescriptionTextEditingController =
      TextEditingController();
  TextEditingController itemPriceTextEditingController =
      TextEditingController();

  bool isUploading = false;
  String downloadUrlOfUploadedImage = "";

  //upload form screen
  Widget uploadFormScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          isUploading
              ? const LinearProgressIndicator(
                  color: Colors.purpleAccent,
                )
              : const SizedBox(),

          //image
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width:2 )
              ),
              height: 230,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                child: imageFileUint8List != null
                    ? Image.memory(imageFileUint8List!)
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(50.0),
            child: MaterialButton(
              color: Colors.blue,
              onPressed: () {
                //validate upload form fields
                if (isUploading != true) //false
                {
                  validateUploadFormAndUploadItemInfo();
                }
              },
              child:isUploading?
              const Padding(
                padding:  EdgeInsets.symmetric(vertical: 3.0),
                child:  CircularProgressIndicator(color: Colors.white, ),
              ):
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Upload",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  validateUploadFormAndUploadItemInfo() async {
    if (imageFileUint8List != null) {
      setState(() {
        isUploading = true;
      });

      //1.upload image to firebase storage
      String imageUniqueName = DateTime.now().millisecondsSinceEpoch.toString();

      fStorage.Reference firebaseStorageRef = fStorage.FirebaseStorage.instance
          .ref()
          .child("Items Images")
          .child(imageUniqueName);

      fStorage.UploadTask uploadTaskImageFile =
          firebaseStorageRef.putData(imageFileUint8List!);

      fStorage.TaskSnapshot taskSnapshot =
          await uploadTaskImageFile.whenComplete(() {});

      await taskSnapshot.ref.getDownloadURL().then((imageDownloadUrl) {
        downloadUrlOfUploadedImage = imageDownloadUrl;
      });

      //2.save item info to firestore database
      saveItemInfoToFirestore();
    } else {
      Fluttertoast.showToast(msg: "Please select image file.");
    }
  }

  saveItemInfoToFirestore() {
    String itemUniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance.collection("Users").doc(itemUniqueId).set({
      "itemID": itemUniqueId,
      "itemName": itemNameTextEditingController.text,
      "itemDescription": "",
      "itemImage": downloadUrlOfUploadedImage,
      "sellerName": "",
      "sellerPhone": "",
      "itemPrice": "",
      "publishedDate": DateTime.now(),
      "status": "available",
    });

    Fluttertoast.showToast(msg: "your new Item uploaded successfully.");

    setState(() {
      isUploading = false;
      imageFileUint8List = null;
    });

    Navigator.push(
        context, MaterialPageRoute(builder: (c) => const HomeScreen()));
  }

  //default screen
  Widget defaultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: 200,
            ),
            ElevatedButton(
              onPressed: () {
                showDialogBox();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              child: const Text(
                "Add New Item",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDialogBox() {
    return showDialog(
        context: context,
        builder: (c) {
          return SimpleDialog(
            backgroundColor: Colors.black,
            title: const Text(
              "Item Image",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  captureImageWithPhoneCamera();
                },
                child: const Text(
                  "Capture image with Camera",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  chooseImageFromPhoneGallery();
                },
                child: const Text(
                  "Choose image from Gallery",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        });
  }

  captureImageWithPhoneCamera() async {
    Navigator.pop(context);

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUint8List = await pickedImage.readAsBytes();

        //remove background from image
        //make image transparent
        imageFileUint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUint8List;
        });
      }
    } catch (errorMsg) {
      print(errorMsg.toString());

      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  chooseImageFromPhoneGallery() async {
    Navigator.pop(context);

    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUint8List = await pickedImage.readAsBytes();

        //remove background from image
        //make image transparent
        imageFileUint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUint8List;
        });
      }
    } catch (errorMsg) {
      print(errorMsg.toString());

      setState(() {
        imageFileUint8List = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageFileUint8List == null ? defaultScreen() : uploadFormScreen();
  }
}
