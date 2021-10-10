import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Classifier(),
    );
  }
}

class Classifier extends StatefulWidget {
  @override
  _ClassifierState createState() => _ClassifierState();
}

class _ClassifierState extends State<Classifier> {
  List? _outputs;
  File? _image;
  bool _loading = false;
  String? ip;
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loading = true;
    //ip = widget.imagepath;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/float16_optimised_model_Inceptionv3.tflite",
      labels: "assets/label.txt",
      numThreads: 4,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);

    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    final image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(File(image.path));
  }

  galleryImage() async {
    final image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'PREDICTOR',
          style: TextStyle(fontFamily: 'Comfortaa', fontSize: 30.0),
        ),
      ),
      body: Container(
        // color: Color(0xffF7DC6F),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _loading
                ? Container(
                    height: 300,
                    width: 300,
                  )
                : Container(
                    margin: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _image == null ? Container() : Image.file(_image!),
                        const SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container()
                            : _outputs != null
                                ? Text(
                                    _outputs?[0]["label"],
                                    style: const TextStyle(
                                        color: Color(0xff196F3D), fontSize: 20),
                                  )
                                : Container(child: Text(""))
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  tooltip: 'Pick Image',
                  onPressed: pickImage,
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                FloatingActionButton(
                  tooltip: 'Gallery Image',
                  onPressed: galleryImage,
                  child: const Icon(
                    Icons.folder_open,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
