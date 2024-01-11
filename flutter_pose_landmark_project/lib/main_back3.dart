import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import './livecamera.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import './detection_page.dart';
import 'package:path_provider/path_provider.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of available cameras.
  List<CameraDescription> cameras = await availableCameras();

  // Select a camera (for simplicity, using the first available camera).
  CameraController cameraController = CameraController(cameras[0], ResolutionPreset.medium);

  // Initialize the camera.
  await cameraController.initialize();

  runApp(MyApp(cameraController: cameraController));
}

Uint8List convertCameraImageToRGB(CameraImage cameraImage) {
  final CameraImage image = cameraImage;
  final planes = image.planes;

  // ByteData buffers for image data from all Y, U and V planes
  final Uint8List bytesY = planes[0].bytes;
  final Uint8List bytesU = planes[1].bytes;
  final Uint8List bytesV = planes[2].bytes;

  // Width and height of the frame
  final int width = image.width;
  final int height = image.height;

  // Prepare a buffer to hold the image data
  final Uint8List imageData = Uint8List(width * height * 3);

  // Fill the image buffer with the appropriate data
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int uvIndex = x ~/ 2 * 2 + y ~/ 2 * width ~/ 2 * 2;
      int index = y * width + x;

      int yValue = bytesY[index];
      int uValue = bytesU[uvIndex];
      int vValue = bytesV[uvIndex];

      // Convert YUV to RGB
      int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
      int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round().clamp(0, 255);
      int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

      // Set RGB values in the image buffer
      imageData[index * 3] = r;
      imageData[index * 3 + 1] = g;
      imageData[index * 3 + 2] = b;
    }
  }

  return imageData;
}

Future<String> getExternalStoragePath() async {
  Directory? directory = await getExternalStorageDirectory();
  if (directory != null) {
    return directory.path;
  } else {
    throw Exception("External storage directory not found");
  }
}

Future<Int32List> loadFileAsBinary(String path) async {
  // final String path = 'assets/sample.txt'; // Replace with your file path
  final ByteData data = await rootBundle.load(path);
  final Int32List bytes = data.buffer.asInt32List();
  return bytes;
}

Future<String?> loadFileAsString(String txtPath) async {
  try {
    // final String path = 'assets/sample.txt'; // Replace with your text file path
    return await rootBundle.loadString(txtPath);
  } catch (e) {
    print('Error loading text file: $e');
    return null;
  }
}

const platform = MethodChannel('your_channel_name');

Future<int> loadAssetFile() async {
  try {
    String assetPath = 'assets/data/transformer.bin'; // Replace with your asset file path
    String result = await platform.invokeMethod('loadAssetFile', {'assetPath': assetPath});
    print('Received result from C++: $result');
    return 1;
  } catch (e) {
    print('Error: $e');
    return 0;
  }
}

void runGaussian(final ImagePicker _picker) async {
  final dylib = DynamicLibrary.open("libOpenCV_ffi.so");
  final imageFile =
  await _picker.pickImage(source: ImageSource.gallery);
  final imagePath =
      imageFile?.path.toNativeUtf8() ?? "none".toNativeUtf8();
  final gaussian = dylib.lookupFunction<
      Void Function(Pointer<Utf8>),
      void Function(Pointer<Utf8>)>('Gaussian');
  gaussian(imagePath);

  logger.i("MOO Log img path = " + imagePath.toDartString());
  // return Image.file(File(imagePath.toDartString()));
}


class MyApp extends StatefulWidget {
  final CameraController cameraController;

  const MyApp({Key? key, required this.cameraController}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> cameraStream;

  late CameraController _cameraController;
  Image? processedImage; // Store processed image
  Uint8List? imageUint8List;
  int _lastRun = 0;
  final ImagePicker _picker = ImagePicker();
  CameraImage? imgCamere;
  final dylib = DynamicLibrary.open("libOpenCV_ffi.so");

  @override
  void initState() {
    super.initState();
    _cameraController = widget.cameraController;
    // Start streaming the camera frames.
    cameraStream = _cameraController.startImageStream(processCameraImage);
  }

  @override
  void dispose() {
    _cameraController.dispose(); // Dispose the camera controller when done
    super.dispose();
  }

  void processCameraImage(CameraImage cameraImage) {

    if (!mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 1000) {
      return;
    }

    imgCamere = cameraImage;

    _lastRun = DateTime.now().millisecondsSinceEpoch;
    // if ()
    // Process the camera image here according to your requirements
    // For example, convert the image to a format that can be displayed
    // and update the UI with the processed image

    // Example: Convert CameraImage to Image widget
    logger.i("CameraImage is not null,Image size = ${cameraImage.width}x${cameraImage.height}, format: ${cameraImage.format.group}");

    // processedImage = convertCameraImageToImage(cameraImage);
    // // imageUint8List = convertYUV420toRGBA(cameraImage);
    // imageUint8List = cameraImage.planes[0].bytes;
    // Update the UI with the processed image (for example, set the state with the image)
    setState(() {
      logger.i("Update Image");
      // Update UI with processedImage
      // For example, use processedImage in a widget like Image or Container
      // processedImage = processedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Camera Stream Processing'),
        ),
        body: Center(
          // Display the processed image or the container/widget where the image will be displayed
          // Use the processedImage or a placeholder while processing
          // child: imgCamere,
          child: returnFunction(),
        ),
      ),
    );
  }

  void loadImageAsUint8List(String imagePath) async {
    String externalStoragePath = await getExternalStoragePath();
    logger.i('MOO External Storage Path: $externalStoragePath');

    ByteData data = await rootBundle.load(imagePath);
    imageUint8List = data.buffer.asUint8List();

    if (imageUint8List == null)
      logger.i('MOO External imageUint8List is null~!');
    else
      logger.i('MOO External imageUint8List is not null~!');
  }

  Widget returnFunction()
  {
    Image _img2 = Image.asset('assets/imgs/pikachu.jpeg');
    //
    // // Pointer<Uint8> p = malloc.allocate(_img2.);

    loadImageAsUint8List("assets/imgs/pikachu.jpeg");

    final imageffi = dylib.lookupFunction<
        Void Function(Pointer<Uint8>, Pointer<Uint32>),
        void Function(
            Pointer<Uint8>, Pointer<Uint32>)>('image_ffi');

    Pointer<Uint32> s = malloc.allocate(2);

    final String txtPath = "assets/data/ModelStructureLog.txt";
    final String binPath = "assets/data/transformer.bin";

    Future<String?> returnTxt = loadFileAsString(txtPath);
    returnTxt.then(
            (value) {
              logger.i("Moo Log from txt file ${value!}!");
            }
    ).catchError((onError) {
      logger.e("Moo Log from txt file error ${onError}!");
    });

    Future<Int32List> returnInt32 = loadFileAsBinary(binPath);

    returnInt32.then(
            (value) {
              logger.i("Moo Log from Bin file, begine print value:");

              for (int i = 0; i < 10 && i < value.length; i++) {
                print('Element $i: ${value[i]}');
              }
        }
    ).catchError((onError) {
      logger.e("Moo Log from Bin file error ${onError}!");
    });


    // Future<int> re = loadAssetFile();
    //
    // re.then(
    //     (value)
    //         {
    //           logger.i("Moo Log success to run loadAssetFile()");
    //         }
    // );

    // if (imageUint8List != null)
    //   {
    //     processedImage = Image.memory(
    //       imageUint8List!,
    //       // width: 480,
    //       // height: 720,
    //       // fit: BoxFit.,
    //     );
    //     logger.i("Moo Code in imageUint8List create Image!");
    //     return processedImage!;
    //   }

    // if (imageUint8List != null) {
    //   s[0] = imageUint8List!.length;
    //   Pointer<Uint8> p = malloc.allocate(s[0]); // Taking extra space for buffer
    //   p
    //       .asTypedList(s[0])
    //       .setRange(0, s[0], imageUint8List!.toList());
    //
    //   imageffi(p, s);
    //   processedImage = Image.memory(p.asTypedList(s[0]));
    //
    //   malloc.free(p);
    //   malloc.free(s);
    //
    //   return processedImage!;
    // }

    final bool tryGallyer = false;

    // if (tryGallyer) {
    //   logger.i("Moo code in Gallery !");
    //   runGaussian(_picker);
    // }

    // Pointer<Uint8> allocatePointer() {
    //   final blob = calloc<Uint8>(s[0]);
    //   final blobBytes = blob.asTypedList(s[0]);
    //   blobBytes.setAll(0, this);
    //   return blob;
    // }

    // Pointer<Uint8> pointerUint8 = imageUint8List?.buffer.asUint8List().cast<Uint8>().cast();

    // final Uint8List imageData = Uint8List(720 * 480 * 3);
    //
    // Pointer<Uint32> s = malloc.allocate(2);
    // s[0] = 720 * 480 * 4;
    Image _img = Image.asset('assets/imgs/pikachu.jpeg');
    // logger.i("Image is not null,Image size = ${_img.width}x${_img.height}, format: ${_img.colorBlendMode}");

    // Image _img2 = Image.memory(p.asTypedList(s[0]));
    //
    // malloc.free(p);
    // malloc.free(s);
    // _img2.image

    // if (imageUint8List == null) {
    //
    //   logger.i("Moo log imageUint8List is null");
    //   return Container();
    //   }
    // processedImage = Image.memory(
    //   imageUint8List!,
    //   // width: 480,
    //   // height: 720,
    //   fit: BoxFit.fitHeight,
    // );

    // Future<ui.Image> f = decodeImageFromList(imageUint8List!);
    // ui.Image user = await f;
    // List<ui.Image> lstUser = [user];//add in list

    return _img;
    // if (_img2 == null) {
    //   logger.i('MOO External processedImage is null~!');
    //   return _img;
    // }
    // else {
    //   return _img2;
    // }

    return processedImage!;
    return _img;
    // _img.image.loadImage(key, (buffer, {getTargetSize}) => null),
    // final int width = 480;
    // final int height = 720;
    //
    // return Image.memory(
    //
    //   width: width.toDouble(),
    //   height: height.toDouble(),
    //   fit: BoxFit.cover, // Adjust the fit according to your UI requirements
    // );

    return processedImage != null ? processedImage! : Text('No image available');
    // // Image _img = Image.asset('assets/imgs/pikachu.jpeg');
    // // return _img;
    // if (processedImage != null) {
    //   // double w = processedImage.width;
    //   logger.i("Image is not null,Image size = ${processedImage.width}x${processedImage.height}");
    //   return processedImage;
    // }
    // else {
    //   logger.i("Image is null");
    //   return Container();
    // }
    // // return processedImage != null ? processedImage :
  }
}


// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context)
//   {
//     return const MaterialApp(
//       title: "OpenCV lite demo",
//       home: HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Center(
//         child: ElevatedButton(
//           child: const Text("camera"),
//           onPressed: () {
//             Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
//               return const DetectionPage();
//             }));
//           },
//         ),
//       ),
//     );
//   }
// }