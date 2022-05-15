import 'dart:io';
import 'package:face_mask_detect/screens/home/live_detector_view.dart';
import 'package:face_mask_detect/shared/constants.dart';
import 'package:face_mask_detect/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _loading = true;
  File? _image;

  List _recognitions = [];

  final ImagePicker _picker = ImagePicker();

  _loadImage({required bool isCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (image == null) {
        return null;
      }
      _image = File(image.path);
      _detectImage(_image!);
    } catch (e) {
      checkPermissions(context);
    }
  }

  _detectImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _recognitions = recognitions!;
      print(_recognitions[0]);
    });
  }

  _reset() {
    setState(() {
      _loading = true;
      _image = null;
    });
  }

  loadModel() async {
    Tflite.close();
    await Tflite.loadModel(
      model: "assets/model/model.tflite",
      labels: "assets/model/labels.txt",
    );
  }

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f5f6),
      appBar: AppBar(
        title: const Text("Face Mask Detector"),
        actions: [
          if (!_loading)
            IconButton(
              onPressed: () => _reset(),
              icon: const FaIcon(FontAwesomeIcons.trash),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppButton(
              color: Colors.white,
              width: kWidth,
              height: kHeight * 0.08,
              backgroundColor: Colors.blueAccent,
              text: "Open camera",
              onTap: () {
                _loadImage(isCamera: true);
              },
            ),
            AppButton(
              color: Colors.white,
              width: kWidth,
              height: kHeight * 0.08,
              backgroundColor: Colors.blueAccent,
              text: "Open gallery",
              onTap: () {
                _loadImage(isCamera: false);
              },
            ),
            AppButton(
              color: Colors.white,
              width: kWidth,
              height: kHeight * 0.08,
              backgroundColor: Colors.blueAccent,
              text: "Live Detection",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LiveDetectorView()),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: kHeight * 0.4,
              width: kWidth,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  !_loading ? const SizedBox(height: 10) : const Spacer(),
                  SizedBox(
                    height: kHeight * 0.2,
                    child: _loading && _image == null
                        ? Image.asset(noImage)
                        : Image.file(_image!),
                  ),
                  const Spacer(),
                  !_loading
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(kHeight * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xff1e847f),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            recognitionResult(_recognitions[0]),
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(
                                      fontSize: 20,
                                      color: Colors.yellowAccent,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Text(
                          "Detect your Image Now.",
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
                                    color: Colors.blueAccent,
                                  ),
                        ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
