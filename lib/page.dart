import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = true;
  late File _image;
  late List _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  detectimage(File image) async {
    try {
      var prediction = await Tflite.runModelOnImage(
          path: image.path,
          numResults: 56,
          threshold: 0.3,
          imageMean: 256,
          imageStd: 256);

      setState(() {
        _output = prediction!;
        loading = false;
      });
    } catch (e) {
      print("Error : ${e}");
    }
  }

  loadmodel() async {
    try {
      await Tflite.loadModel(
          model: 'assets/best.tflite', labels: 'assets/best.txt');
    } catch (e) {
      print("Error:");
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickimage_camera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }

    try {
      detectimage(_image);
    } catch (e) {
      print("Error : ");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Detection de masque ML',
        ),
      ),
      body: Container(
        height: h,
        width: w,
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: 150,
              padding: EdgeInsets.all(10),
              //color: Colors.green,
              child: Icon(Icons.abc),
            ),
            Container(
                child: Text('Detection de masque',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 70,
              //padding: EdgeInsets.all(10)
            ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  //foregroundColor: Colors.black87,
                  backgroundColor: Colors.teal,
                  //minimumSize: Size(88, 36),
                  // padding: EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  animationDuration: Duration(milliseconds: 300),
                  elevation: 1.0,
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                pickimage_camera();
              },
              child: Text('Camera'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  //foregroundColor: Colors.black87,
                  backgroundColor: Colors.teal,
                  //minimumSize: Size(88, 36),
                  // padding: EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  animationDuration: Duration(milliseconds: 300),
                  elevation: 1.0,
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                try {
                  pickimage_gallery();
                } catch (e) {
                  print("Error : ");
                  print(e);
                }
              },
              child: Text('Gallerie'),
            ),
            loading != true
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          // width: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Image.file(_image),
                        ),
                        _output.isNotEmpty
                            ? Text(
                                (_output[0]['label']).toString().substring(2),
                                style: GoogleFonts.roboto(fontSize: 18))
                            : Text(''),
                        _output.isNotEmpty
                            ? Text(
                                'Confidence: ' +
                                    (_output[0]['confidence']).toString(),
                                style: GoogleFonts.roboto(fontSize: 18))
                            : Text('')
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
