import 'dart:io';
import 'package:bite_box/utils/Hexcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class UploadFood extends StatefulWidget {
  const UploadFood({super.key});

  @override
  State<UploadFood> createState() => _UploadFoodState();
}

class _UploadFoodState extends State<UploadFood> {
  List<XFile>? images = [];
  List<String> items = [];
  String? itemtype;
  String? useremail = FirebaseAuth.instance.currentUser?.email;
  TextEditingController search = TextEditingController();
  TextEditingController _itemname = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _consistsof = TextEditingController();
  TextEditingController _itemdescription = TextEditingController();
  String dropdownValue = 'Veg';

  late List<String> downloadurls;
  String condition = 'Excellent';
  String backhoeSize = 'Standard';
  bool _isUploading = false;
  @override
  void initState() {
    super.initState();
    create_list();
  }

  @override
  void dispose() {
    search.dispose();
    _itemname.dispose();
    _price.dispose();
    _consistsof.dispose();
    _itemdescription.dispose();
    super.dispose();
  }

  void _showDocumentIdPopup(String documentId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(documentId),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _showDocumentIdPopup2(String documentId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(documentId),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> uploadImages(List<XFile> images) async {
    final storageRef = FirebaseStorage.instance.ref();
    final urls = <String>[]; // Create a list to store the download URLs

    try {
      for (var image in images) {
        final imageRef = storageRef
            .child('images/${DateTime.now()}.${image.name.split('.').last}');
        final uploadTask = imageRef.putFile(File(image.path));

        final snapshot = await uploadTask;
        final downloadURL = await snapshot.ref.getDownloadURL();
        urls.add(downloadURL); // Add the download URL to the list
      }

      return urls; // Return the list of download URLs
    } catch (error) {
      print('Error uploading images: $error');
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  void create_list() {
    FirebaseFirestore.instance
        .collection('Categories')
        .doc('Categories')
        .get()
        .then((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic> fields =
            docSnapshot.data() as Map<String, dynamic>;
        List<String> values =
            fields.values.cast<String>().toList(); // Cast to strings
        items.addAll(values);
      }
    }).catchError((error) {
      // Handle errors here
      print('Error fetching Categories document: $error');
    });

    FirebaseFirestore.instance
        .collection('Categories')
        .doc('Tiffin Categories')
        .get()
        .then((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        Map<String, dynamic> fields =
            docSnapshot.data() as Map<String, dynamic>;
        List<String> values =
            fields.values.cast<String>().toList(); // Cast to strings
        items.addAll(values);
      }

      // Update the state after fetching data from both documents
      setState(() {});
    }).catchError((error) {
      // Handle errors here
      print('Error fetching Tiffin Categories document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -5,
        title: Text("Upload Food",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              fontSize: 20,
            )),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              setState(() {
                _isUploading =
                    true; // Start the upload and show progress indicator
              });
              try {
                downloadurls = await uploadImages(images!);
                await FirebaseFirestore.instance
                    .collection('Menu')
                    .doc(_itemname.text)
                    .set({
                  'Item Name': _itemname.text,
                  'Item Category': itemtype,
                  'Price': _price.text,
                  'Consists Of': _consistsof.text,
                  'Item Description': _itemdescription.text,
                  'Type': dropdownValue,
                  'Images': downloadurls,
                  'User Email': useremail,
                }).then((value) {
                  _showDocumentIdPopup2(
                      "Item Added Successfully", 'Upload Successful');
                });
              } catch (e) {
                print(e); // Handle or log error
              } finally {
                setState(() {
                  _isUploading =
                      false; // Hide progress indicator once upload is complete
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: width * 0.06),
              child: Container(
                height: width * 0.08,
                width: width * 0.2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HexColor('#2A2828'),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text("Upload",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: width * 0.04,
                    )),
              ),
            ),
          )
        ],
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.white,
      body: _isUploading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  images!.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.04,
                            top: width * 0.02,
                            right: width * 0.04,
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 249, 222),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              height: width * 0.78,
                              child: Stack(
                                children: [
                                  Positioned(
                                      child: Container(
                                    decoration: BoxDecoration(
                                      color: HexColor('#2A2828'),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                    ),
                                    height: width * 0.10,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            top: width * 0.02,
                                            left: width * 0.03,
                                            child: Text(
                                                "Food Photos (${images!.length}/4)",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        Positioned(
                                            right: width * 0.03,
                                            top: width * 0.02,
                                            child: GestureDetector(
                                              onTap: () {
                                                pickImages();
                                              },
                                              child: Text("Edit",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            )),
                                      ],
                                    ),
                                  )),
                                  Positioned(
                                      top: width * 0.35,
                                      left: width * 0.33,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              pickImages();
                                            },
                                            child: Image.asset(
                                              'assets/images/Addphoto2.png',
                                              width: width * 0.13,
                                              height: width * 0.13,
                                            ),
                                          ),
                                          Text(
                                            "Click to Add Photo",
                                            style: TextStyle(
                                              fontSize: width * 0.03,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ],
                                      )),
                                  Positioned(
                                      bottom: width * 0.02,
                                      left: width * 0.02,
                                      child: GestureDetector(
                                          onTap: () {
                                            _pickImageFromCamera();
                                          },
                                          child: FaIcon(FontAwesomeIcons.camera,
                                              size: width * 0.06)))
                                ],
                              )),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                            left: width * 0.04,
                            top: width * 0.02,
                            right: width * 0.04,
                          ),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 249, 222),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              height: width * 0.78,
                              child: Stack(
                                children: [
                                  Positioned(
                                      child: Container(
                                    decoration: BoxDecoration(
                                      color: HexColor('#2A2828'),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                    ),
                                    height: width * 0.10,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                            top: width * 0.02,
                                            left: width * 0.03,
                                            child: Text(
                                                "Food Photos (${images!.length}/4)",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Roboto',
                                                    fontWeight:
                                                        FontWeight.w600))),
                                        Positioned(
                                            right: width * 0.03,
                                            top: width * 0.02,
                                            child: GestureDetector(
                                              onTap: () {
                                                pickImages();
                                              },
                                              child: Text("Edit",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            )),
                                      ],
                                    ),
                                  )),
                                  Padding(
                                    padding: EdgeInsets.only(top: width * 0.1),
                                    child: Container(
                                      child: Center(
                                          child: PageView.builder(
                                              itemCount: images!.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                    child: Image.file(File(
                                                        images![index].path)));
                                              })),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: width * 0.02,
                                      left: width * 0.02,
                                      child: GestureDetector(
                                          onTap: () {
                                            _pickImageFromCamera();
                                          },
                                          child: FaIcon(FontAwesomeIcons.camera,
                                              size: width * 0.06)))
                                ],
                              )),
                        ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Item name",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: width * 0.04, left: width * 0.04),
                        child: TextField(
                          controller: _itemname,
                          decoration: InputDecoration(
                            hintText: 'Enter the Item Name',
                            hintStyle: TextStyle(fontSize: 14.0),
                            contentPadding: const EdgeInsets.only(
                              left: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Item Category",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.03,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: items
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: itemtype,
                          onChanged: (value) {
                            setState(() {
                              itemtype = value;
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 200,
                          ),
                          dropdownStyleData: const DropdownStyleData(
                            maxHeight: 200,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: search,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: search,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  hintText: 'Search for an item...',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              return item.value
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase());
                            },
                          ),
                          //This to clear the search value when you close the menu
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {
                              search.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Price",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: width * 0.04, left: width * 0.04),
                        child: TextField(
                          controller: _price,
                          decoration: InputDecoration(
                            hintText: 'Enter The Price Of The Item',
                            hintStyle: TextStyle(fontSize: 14.0),
                            contentPadding: const EdgeInsets.only(
                              left: 5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Type",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.07,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        dropdownColor: Colors.white,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>['Veg', 'Non-Veg']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Consists of",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: width * 0.04,
                          left: width * 0.04,
                        ),
                        child: Container(
                          width: width,
                          height: 100,
                          child: TextFormField(
                            controller: _consistsof,
                            decoration: InputDecoration(
                              hintText: 'Enter What This Items Consists Of',
                              hintStyle: TextStyle(fontSize: 14.0),
                              contentPadding: const EdgeInsets.only(
                                left: 5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            maxLines: null,
                            expands: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      top: width * 0.024,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Item Description",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: width * 0.04,
                            left: width * 0.04,
                            bottom: width * 0.02),
                        child: Container(
                          width: width,
                          height: 100,
                          child: TextFormField(
                            controller: _itemdescription,
                            decoration: InputDecoration(
                              hintText: 'Enter The Item Description',
                              hintStyle: TextStyle(fontSize: 14.0),
                              contentPadding: const EdgeInsets.only(
                                left: 5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            maxLines: null,
                            expands: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

//multiple image picker function from gallery
  Future<void> pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    final limitedImages = pickedImages.take(4).toList();
    setState(() {
      if (images!.length < 4 && (images!.length + limitedImages.length) <= 4) {
        images = [...?images, ...limitedImages];
      } else {
        images = [...limitedImages];
      }
    });
  }

//multiple image picker function from camera
  Future _pickImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        if (images!.length < 4) {
          images = [...?images, pickedImage];
        } else {
          images = [pickedImage];
        }
      });
    }
  }
}
