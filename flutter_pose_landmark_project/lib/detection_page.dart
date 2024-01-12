import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:test_flutter/main.dart';
import './detection_page.dart';

class DetectionPage extends StatefulWidget { // 这个为啥要状态Widget
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}


// the following is my c function: int initPoseLandmarker();
typedef InitPoseNative = Int32 Function();
typedef InitPose = int Function();

// the following is my c function: int testStruct(PoseLandmarkResult *result);
typedef TestStructNative = Int32 Function(Pointer<PoseLandmarkResult> result);
typedef TestStruct = int Function(Pointer<PoseLandmarkResult> result);

typedef LoadModelNative = Int32 Function(Pointer<Uint8> buffer, Int64 buffer_size);
typedef LoadModel = int Function(Pointer<Uint8> buffer, int buffer_size);

typedef RunPoseLandmarkNative = Int32 Function(Pointer<Uint8> data, Int32 width, Int32 height, Int32 stride,Int32 flip, Int32 rotate, Int32 img_type, Pointer<PoseLandmarkResult> result);
typedef RunPoseLandmark = int Function(Pointer<Uint8> data, int width, int height, int stride, int flip, int rotate, int img_type, Pointer<PoseLandmarkResult> result);

typedef ReleasePoseLandmarkNative = Int32 Function();
typedef ReleasePoseLandmark = int Function();


// The output of model
final class PoseLandmarkResult extends Struct {
  @Int32()
  external int poseNum;

  @Array(4)
  external Array<Int32> rect;

  @Float()
  external double score;

  @Array(2 * 33)
  external Array<Float> points;
}

// Save File to SD Card.
Future<void> saveFileToSDCard( Uint8List data, String directoryName, // Directory path in SD card where you want to save the file
                              String fileName) async
{
  try {
    // Create the directory if it doesn't exist
    // Get the external storage directory
    Directory? sdCardDir = await getExternalStorageDirectory();

    if (sdCardDir != null) {
        logger.i("Moo Log, got sdCardDir = ${sdCardDir}");
        // Create a directory inside the SD card directory
        String dirPath = '${sdCardDir.path}/$directoryName';
        Directory dir = Directory(dirPath);

        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

      // Create a File instance with the specified path
      String filePath = '$dirPath/$fileName';
      File file = File(filePath);

      // Write the data to the file
      await file.writeAsBytes(data);

      print('File saved to SD card at: $filePath');
    } else {
      print('External storage directory not available');
    }
  }
  catch (e) {
    print('Error saving file: $e');
  }
}

Future<Uint8List> loadFileAsBinary(String path) async {
  // final String path = 'assets/sample.txt'; // Replace with your file path
  final ByteData data = await rootBundle.load(path);
  final Uint8List bytes = data.buffer.asUint8List();

  logger.i("Load file, the length is ${bytes.length}");
  return bytes;
}

class _DetectionPageState extends State<DetectionPage> with WidgetsBindingObserver {
  CameraController? _camController;
  bool modelLoadState = false;
  // late ArucoDetectorAsync _arucoDetector;
  int _camFrameRotation = 0;
  double _camFrameToScreenScale = 0;
  int _lastRun = 0;
  bool _detectionInProgress = false;
  late DynamicLibrary nativeAddLib;
  final Pointer<PoseLandmarkResult> resultP = calloc<PoseLandmarkResult>();
  late PoseLandmarkResult result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    nativeAddLib = DynamicLibrary.open("libvision_pose_landmarker.so");

    final initFunc = nativeAddLib.lookupFunction<InitPoseNative, InitPose>("initPoseLandmarker");

    // Init function
    initFunc();

    result = resultP.ref;
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = _camController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      await initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // _arucoDetector.destroy();
    _camController?.dispose();
    final releaseFunc = nativeAddLib.lookupFunction<ReleasePoseLandmarkNative, ReleasePoseLandmark>("releasePoseLandmark");
    releaseFunc();
    malloc.free(resultP);
    super.dispose();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    var idx = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    if (idx < 0) {
      log("No Back camera found - weird");
      return;
    }

    final String modelDetectPath = 'assets/model/pose_detection.mnn';

    final String modelLandmarkPath = 'assets/model/pose_landmark_full_sim.mnn';

    if (!modelLoadState) {
      // Read model to buffer
      final loadModelFunc_Detect = nativeAddLib.lookupFunction<LoadModelNative, LoadModel>("loadModelPoseDetect");
      final loadModelFunc_Land = nativeAddLib.lookupFunction<LoadModelNative, LoadModel>("loadModelPoseLandmark");

      final Uint8List modelBufferDetect = await loadFileAsBinary(modelDetectPath);
      Pointer<Uint8> modelBufferDetectP = malloc.allocate(modelBufferDetect.length);
      modelBufferDetectP.asTypedList(modelBufferDetect.length).setRange(0, modelBufferDetect.length, modelBufferDetect);
      var rd = loadModelFunc_Detect(modelBufferDetectP, modelBufferDetect.length);

      final Uint8List modelBufferLandmark = await loadFileAsBinary(modelLandmarkPath);
      Pointer<Uint8> modelBufferLandmarkP = malloc.allocate(modelBufferLandmark.length);
      modelBufferLandmarkP.asTypedList(modelBufferLandmark.length).setRange(0, modelBufferLandmark.length, modelBufferLandmark);
      var rl = loadModelFunc_Land(modelBufferLandmarkP, modelBufferLandmark.length);

      logger.i("Load model status = rd = ${rd}, rl = ${rl}!");
      malloc.free(modelBufferLandmarkP);
      malloc.free(modelBufferDetectP);
      modelLoadState = true;
    }

    var desc = cameras[idx];
    _camFrameRotation = Platform.isAndroid ? desc.sensorOrientation : 0;
    _camController = CameraController(
      desc,
      ResolutionPreset.high, // 720p
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _camController!.initialize();
      await _camController!.startImageStream((image) => _processCameraImage(image));
    } catch (e) {
      log("Error initializing camera, error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_detectionInProgress || !mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 30) {
      return;
    }

    // load run function
    final runFunc = nativeAddLib.lookupFunction<RunPoseLandmarkNative, RunPoseLandmark>("runPoseLandmark");

    // calc the scale factor to convert from camera frame coords to screen coords.
    // NOTE!!!! We assume camera frame takes the entire screen width, if that's not the case
    // (like if camera is landscape or the camera frame is limited to some area) then you will
    // have to find the correct scale factor somehow else
    if (_camFrameToScreenScale == 0) {
      var w = (_camFrameRotation == 0 || _camFrameRotation == 180) ? image.width : image.height;
      _camFrameToScreenScale = MediaQuery.of(context).size.width / w;
    }

    // Call the detector
    _detectionInProgress = true;

    // Uint8List list = image.planes.first.bytes;
    final sizeBuffer0 = image.planes[0].bytes.length;
    final sizeBuffer1 = image.planes[1].bytes.length;
    final sizeBuffer2 = image.planes[2].bytes.length;

    final pixR = image.planes[0].bytesPerRow;
    final pixS = image.planes[0].bytesPerPixel;

    // String directoryPath = 'MooDir'; // Replace this with your desired directory path
    // String fileName = 'example.txt';
    // await saveFileToSDCard(image.planes[0].bytes, directoryPath, 'data0.bin');
    // await saveFileToSDCard(image.planes[1].bytes, directoryPath, 'data1.bin');
    // await saveFileToSDCard(image.planes[2].bytes, directoryPath, 'data2.bin');

    // logger.i("MOO log img size = wxh = ${image.width} x ${image.height}, lenght1 = ${image.planes[0].bytes.length}, lenght2 = ${image.planes[1].bytes.length}, lenght3 = ${image.planes[2].bytes.length}");
    // logger.i("MOO log img pixR = ${pixR},  pixS = ${pixS}!");
    DateTime before = DateTime.now();
    Pointer<Uint8> imgBuffer = malloc.allocate(sizeBuffer0 + sizeBuffer1 + sizeBuffer2 + 1);
    Uint8List buffer = imgBuffer.asTypedList(sizeBuffer0 + sizeBuffer1 + sizeBuffer2);
    buffer.setAll(0, image.planes[0].bytes);
    buffer.setAll(sizeBuffer0, image.planes[1].bytes);
    buffer.setAll(sizeBuffer0 + sizeBuffer2, image.planes[2].bytes);
    DateTime after = DateTime.now();
    // imgBuffer.asTypedList(sizeBuffer0 + sizeBuffer1 + sizeBuffer2).setAll(0, image.planes[0].bytes);
    // logger.i("MOO log copy 0 v by0 = ${image.planes[0].bytes[0]}, bu0 = ${imgBuffer[0]}");
    // imgBuffer.asTypedList(sizeBuffer0 + sizeBuffer1 + sizeBuffer2).setAll(sizeBuffer0, image.planes[1].bytes);
    // logger.i("MOO log copy 1 v by0 = ${image.planes[1].bytes[0]}, bu0 = ${imgBuffer[sizeBuffer0]}");
    // imgBuffer.asTypedList(sizeBuffer0 + sizeBuffer1 + sizeBuffer2).setAll(sizeBuffer0 + sizeBuffer2, image.planes[2].bytes);
    // logger.i("MOO log copy 2 v by0 = ${image.planes[2].bytes[0]}, bu0 = ${imgBuffer[sizeBuffer0 + sizeBuffer1]}");

    var res = await runFunc(imgBuffer, image.width, image.height, image.width * 3, 0, 0, 4, resultP); // 运行的结果

    malloc.free(imgBuffer);
    _detectionInProgress = false;
    _lastRun = DateTime.now().millisecondsSinceEpoch;

    // Make sure we are still mounted, the background thread can return a response after we navigate away from this
    // screen but before bg thread is killed
    Duration difference = after.difference(before);
    logger.i("MOO log result person = ${res}, time cost = ${difference.inMilliseconds} ms!");

    if (resultP.ref.poseNum == 1) {
      print("Found person num = ${resultP.ref.poseNum}");
      // Darw key point and line on picture.
    }
    else
    {
      print("Not found person! v = ${resultP.ref.poseNum}!");
    }

    // TODO 增加没有人返回的情况
    if (!mounted || resultP.ref.poseNum == 0) {
      return;
    }

    // Check that the number of coords we got divides by 8 exactly, each aruco has 8 coords (4 corners x/y)
    // if ((res.length / 8) != (res.length ~/ 8)) {
    //   log('Got invalid response from ArucoDetector, number of coords is ${res.length} and does not represent complete arucos with 4 corners');
    //   return;
    // }

    // convert arucos from camera frame coords to screen coords
    // final arucos = res.map((x) => x * _camFrameToScreenScale).toList(growable: false);
    setState(() {
      result = resultP.ref;
      // _arucos = arucos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Center(
        child: Text('Loading...'),
      );
    }

    return CameraPreview(_camController!);
    // return Stack(
    //   children: [
    //     CameraPreview(_camController!),
    //     DetectionsLayer(
    //       arucos: _arucos,
    //     ),
    //   ],
    // );
  }
}
