import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
// import 'dart:io' show Directory, Platform;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

// The following is my C struct code.
// struct PoseLandmarkResult {
//     int poseNum; // 0 means no pose has been found, 1 means 1 pose has been found.
//     int rect[4]; // [x, y, w, h]
//     float score;
//     float points[MAX_POSE_LANDMARK_NUM * 2];
// };

// Example of handling a simple C struct
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

// the following is my c function: int initPoseLandmarker();
typedef InitPoseNative = Int32 Function();
typedef InitPose = int Function();

// the following is my c function: int testStruct(PoseLandmarkResult *result);
typedef TestStructNative = Int32 Function(Pointer<PoseLandmarkResult> result);
typedef TestStruct = int Function(Pointer<PoseLandmarkResult> result);

typedef LoadModelNative = Int32 Function(Pointer<Uint8> buffer, Int64 buffer_size);
typedef LoadModel = int Function(Pointer<Uint8> buffer, int buffer_size);

// the following is my c function:
// int loadModelPoseDetect(const char *buffer, const long buffer_size);
// int loadModelPoseLandmark(const char *buffer, const long buffer_size);
// int runPoseLandmark(const char *data, const int width, const int height, const int stride, const int img_type, PoseLandmarkResult *result);
// int releasePoseLandmark();

typedef RunPoseLandmarkNative = Int32 Function(Pointer<Uint8> data, Int32 width, Int32 height, Int32 stride, Int32 img_type, Pointer<PoseLandmarkResult> result);
typedef RunPoseLandmark = int Function(Pointer<Uint8> data, int width, int height, int stride, int img_type, Pointer<PoseLandmarkResult> result);

typedef ReleasePoseLandmarkNative = Int32 Function();
typedef ReleasePoseLandmark = int Function();

void pose_landmark_api_test() async
{
  // Create a pointer to the struct
  final Pointer<PoseLandmarkResult> result = calloc<PoseLandmarkResult>();
  var libraryPath = "/Users/mzh/work/my_project/mediapipe_cmake/cmake-build-release/libvision_pose_landmarker.dylib";
  // Open the dynamic library
  final DynamicLibrary nativeAddLib = DynamicLibrary.open(libraryPath);
  
  DynamicLibrary.process();
  
  final initFunc = nativeAddLib.lookupFunction<InitPoseNative, InitPose>("initPoseLandmarker");
  final loadModelFunc_Detect = nativeAddLib.lookupFunction<LoadModelNative, LoadModel>("loadModelPoseDetect");
  final loadModelFunc_Land = nativeAddLib.lookupFunction<LoadModelNative, LoadModel>("loadModelPoseLandmark");

  final releaseFunc = nativeAddLib.lookupFunction<ReleasePoseLandmarkNative, ReleasePoseLandmark>("releasePoseLandmark");

  // // Look up the C function 'testStruct'
  // final testStruct = nativeAddLib.lookupFunction<TestStructNative, TestStruct>("testStruct");
  // final ret = testStruct(result);

  // load model
  final String modelDetect = '/Users/mzh/work/my_project/mediapipe_cmake/mpp_vision/pose_detector/models/pose_detection.mnn';
  final String modelLandmark = '/Users/mzh/work/my_project/mediapipe_cmake/mpp_vision/pose_landmarker/models/pose_landmark_full_sim.mnn';

  // Read model to buffer
  final File modelFileDetect = File(modelDetect);
  final Uint8List modelBufferDetect = modelFileDetect.readAsBytesSync();
  Pointer<Uint8> modelBufferDetectP = malloc.allocate(modelBufferDetect.length);
  modelBufferDetectP.asTypedList(modelBufferDetect.length).setRange(0, modelBufferDetect.length, modelBufferDetect);

  final File modelFileLandmark = File(modelLandmark);
  final Uint8List modelBufferLandmark = modelFileLandmark.readAsBytesSync();
  Pointer<Uint8> modelBufferLandmarkP = malloc.allocate(modelBufferLandmark.length);
  modelBufferLandmarkP.asTypedList(modelBufferLandmark.length).setRange(0, modelBufferLandmark.length, modelBufferLandmark);



      //   Pointer<Uint8> imgBuffer = malloc.allocate(2);
      // // final int width = value.width;
      // // for (int y = 0; y < value.height; y++) {
      // //   for (int x = 0; x < value.width; x++) {
      // //     final pixel = value.getPixel(x, y);
        
      // //     final r = pixel.r;
      // //     final g = pixel.g;
      // //     final b = pixel.b;
      // //     imgBuffer[y * width * 3 + x * 3 + 0] = r.toInt();
      // //     imgBuffer[y * width * 3 + x * 3 + 1] = g.toInt();
      // //     imgBuffer[y * width * 3 + x * 3 + 2] = b.toInt();
      // //   }
      // // }

      // runFunc(imgBuffer, 1, 1, 1, 0, result);
  // load image
  final String imgPath = '/Users/mzh/work/my_project/mediapipe_cmake/data/body_image/test.jpeg';
  
  if (false) {
      initFunc();
  final rd = loadModelFunc_Detect(modelBufferDetectP, modelBufferDetect.length);
  final rl = loadModelFunc_Land(modelBufferLandmarkP, modelBufferLandmark.length);

  print("Load model status: detect = ${rd}, landmark = ${rl}");
    final runFunc = nativeAddLib.lookupFunction<RunPoseLandmarkNative, RunPoseLandmark>("runPoseLandmark");
    img.Image? image = await img.decodeJpgFile(imgPath);
    print("Load image success! image width = ${image?.width}, height = ${image?.height}");
    final sizeBuffer = image!.height * image.width * 3;
    
    Pointer<Uint8> imgBuffer = malloc.allocate(sizeBuffer);
    final int width = image.width;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
      
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        imgBuffer[y * width * 3 + x * 3 + 0] = r.toInt();
        imgBuffer[y * width * 3 + x * 3 + 1] = g.toInt();
        imgBuffer[y * width * 3 + x * 3 + 2] = b.toInt();
      }
    }

    runFunc(imgBuffer, image.width, image.height, image.width * 3, 0, result);

    if (result.ref.poseNum == 1) {
      print("Found person num = ${result.ref.poseNum}");
    }
    else
    {
      print("Not found person! v = ${result.ref.poseNum}!");
    }
  } else {
    initFunc();
    final rd = loadModelFunc_Detect(modelBufferDetectP, modelBufferDetect.length);
    final rl = loadModelFunc_Land(modelBufferLandmarkP, modelBufferLandmark.length);
    
    Future<img.Image?> image2 = img.decodeJpgFile(imgPath);
      image2.then(
        (value) { // processing image here.
          print("Load image success! image width = ${value?.width}, height = ${value?.height}");
          final sizeBuffer = value!.height * value.width * 3;
          
          Pointer<Uint8> imgBuffer = malloc.allocate(sizeBuffer);
          final int width = value.width;
          for (int y = 0; y < value.height; y++) {
            for (int x = 0; x < value.width; x++) {
              final pixel = value.getPixel(x, y);
            
              final r = pixel.r;
              final g = pixel.g;
              final b = pixel.b;
              imgBuffer[y * width * 3 + x * 3 + 0] = r.toInt();
              imgBuffer[y * width * 3 + x * 3 + 1] = g.toInt();
              imgBuffer[y * width * 3 + x * 3 + 2] = b.toInt();
            }
          }
          
          print("Load model status: detect = ${rd}, landmark = ${rl}");
          final runFunc = nativeAddLib.lookupFunction<RunPoseLandmarkNative, RunPoseLandmark>("runPoseLandmark");
          runFunc(imgBuffer, value.width, value.height, value.width * 3, 0, result);

          if (result.ref.poseNum == 1) {
            print("Found person num = ${result.ref.poseNum}");
          }
          else
          {
            print("Not found person! v = ${result.ref.poseNum}!");
          }


          // convert image to uint8 list
        }
      ).catchError((onError) {
        print("load image fail! ${onError}");
      });
  }
  
  

  print("Result of lib: pose Num = ${result.ref.poseNum}");

  // final releaseStatu = releaseFunc();

  // print("Finish pose landmark, release status = ${releaseStatu}!");
}

void test_image_funct()
{
  final String imgPath = '/Users/mzh/work/my_project/mediapipe_cmake/data/body_image/test.jpeg';
  Future<img.Image?> image = img.decodeJpgFile(imgPath);

  image.then(
    (value) { // processing image here.
      print("Load image success! image width = ${value?.width}, height = ${value?.height}");
      img.Image modifiedImage = img.flipHorizontal(value!);
      File outputFile = File('/Users/mzh/work/my_project/flutter_pro/flutter_lab/dart_ffi_test/dart_application_1/bin/png.png');

      // Encode the modified image to PNG format
      Uint8List pngBytes = img.encodePng(modifiedImage);

      // Write the encoded bytes to the output file
      outputFile.writeAsBytesSync(pngBytes);

      // print("image width = ${value?.width}, height = ${value?.height}");
    }
  ).catchError((onError) {
    print("load image fail! ${onError}");
  });


}