import 'package:camera/camera.dart';
import 'package:face_mask_detect/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tflite/tflite.dart';

class LiveDetectorView extends StatefulWidget {
  const LiveDetectorView({Key? key}) : super(key: key);

  @override
  State<LiveDetectorView> createState() => _LiveDetectorViewState();
}

class _LiveDetectorViewState extends State<LiveDetectorView> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String outPut = "";
  int selectedCamera = 0;

  _toggleCameras() async {
    setState(() {
      selectedCamera = selectedCamera == 1 ? 0 : 1;
    });
    _initCamera();
  }

  _initCamera() {
    cameraController =
        CameraController(cameras![selectedCamera], ResolutionPreset.max);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController!.startImageStream((imageStream) {
          cameraImage = imageStream;
          _runModelOnFrame();
        });
      });
    });
  }

  _runModelOnFrame() async {
    if (cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
      );
      for (var recognition in recognitions!) {
        outPut = recognitionResult(recognition);
        setState(() {});
      }
    }
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
    _initCamera();
    loadModel();
    super.initState();
  }

  @override
  void dispose() async {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Mask Live Detector"),
        actions: [
          IconButton(
            onPressed: () {
              _toggleCameras();
            },
            icon: const FaIcon(FontAwesomeIcons.cameraRotate),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: kHeight,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: cameraController!.value.isInitialized
              ? Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: cameraController!.value.aspectRatio,
                        child: CameraPreview(cameraController!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: kWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xff1e847f),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        outPut,
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontSize: 20,
                              color: Colors.yellowAccent,
                              overflow: TextOverflow.ellipsis,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }
}
