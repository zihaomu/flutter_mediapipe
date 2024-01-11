import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:test_flutter/main.dart';
import 'livecamera.dart';
import './livecamera.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import './detection_page.dart';

class DetectionPage extends StatefulWidget { // 这个为啥要状态Widget
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

// Concatenating planes to get image bytes
Uint8List concatenatePlanes(List<Plane> planes) {
  // Implement logic to concatenate planes according to your image format
  // This example assumes a simple concatenation of planes into a single Uint8List

  // Concatenate the planes into a single Uint8List
  int size = planes.fold(0, (prev, plane) => prev + plane.bytes.length);
  Uint8List concatenatedBytes = Uint8List(size);
  int offset = 0;
  for (Plane plane in planes) {
    concatenatedBytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
    offset += plane.bytes.length;
  }

  return concatenatedBytes;
}

// Function to convert CameraImage to Image widget
Image convertCameraImageToImage(CameraImage cameraImage) {
  // Convert YUV420 format to RGB format (for example)
  // Process the camera image data here according to your image format

  // For demonstration purposes, assuming a simple conversion
  Uint8List imageBytes = concatenatePlanes(cameraImage.planes);

  // Create an Image widget from the processed image bytes
  Image imageWidget = Image.memory(
    imageBytes,
    width: cameraImage.width.toDouble(),
    height: cameraImage.height.toDouble(),
    fit: BoxFit.cover, // Adjust the fit according to your UI requirements
  );

  return imageWidget;
}

class _DetectionPageState extends State<DetectionPage> with WidgetsBindingObserver
{
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _detectionInprogress = false;
  int _lastRun = 0; // 记录时间的flag

  Image? currImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initCamera();

    // // Next, initialize the controller. This returns a Future.
    // _initializeControllerFuture = _cameraController.initialize();
  }

  Future<void> initCamera() async {
    logger.i("Code in initCamera!");
    final cameras = await availableCameras();
    var idx = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);

    if (idx < 0) {
      logger.i("No back camera found - weird!");
    }

    var desc = cameras[idx];
    // _camFrameRotation = Platform.isAndroid ? desc.sensorOrientation : 0;
    _cameraController = CameraController(
      desc,
      ResolutionPreset.high, // 720p
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.startImageStream((image) => _processCameraImage(image));
    } catch (e) {
      logger.e("Error initializing camera, error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_detectionInprogress || !mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 30)
    {
      return; // 如果还在处理中，或者挂起，或者时间小于30 ms
    }

    currImage = convertCameraImageToImage(image);
    // convert the CameraImage to currentImage
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state)
  {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    }
    else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    if ( _cameraController == null) {
      return const Center(
        child: Text("Loading ...."),
      );
    }

    // Read image and return
    // Image _img = Image.asset('assets/imgs/pikachu.jpeg');
    // return _img;

    // CameraController data = _cameraController;
    if (currImage == null) {

      logger.i("Moo Log return CameraPreview");
      Image _img = Image.asset('assets/imgs/pikachu.jpeg');
      return _img;
      return CameraPreview(_cameraController!);
    }
    else {
      logger.i("Moo Log return currImage");
      return currImage!;
    }

    // return currImage == null? CameraPreview(_cameraController!) : currImage;

    // return Stack(
    //   children: [
    //     CameraPreview(_cameraController!),
    //     // D
    //   ],
    // );
  }

}