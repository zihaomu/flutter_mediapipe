import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:test_flutter/main.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

class TakePictureScreenState extends State<TakePictureScreen> {
  final dylib = Platform.isAndroid
      ? DynamicLibrary.open("libOpenCV_ffi.so")
      : DynamicLibrary.process();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isStreaming = false;
  Image _img = Image.asset('assets/imgs/pikachu.jpeg');
  Image _old = Image.asset('assets/imgs/pikachu.jpeg');

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg);

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    // _controller.stopImageStream();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isStreaming ? 'Live' : 'Start Camera')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
            // return Center(child: Stack(children: [_old, _img]));
            //CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async
        {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.

          logger.i("Moo log code here!");
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
            if (_isStreaming) {
              await _controller.stopImageStream();
              logger.i("Stopped");
              setState(() => _isStreaming = false);
            }
            else
            {
              setState(() => _isStreaming = true);
              logger.i("Starting");
              logger.i("Moo log code here2!");

              _controller.startImageStream((CameraImage availableImage)  // 这代码没有进去，为啥？
              {
                Pointer<Uint32> s = malloc.allocate(2);
                s[0] = availableImage.planes[0].bytes.length;

                logger.i("Moo log cod2e here！Image size = ${availableImage.height}x${availableImage.width}, byte = ${s[0]}");
                Pointer<Uint8> p = malloc.allocate(3 *
                    availableImage.height *
                    availableImage.width); // Taking extra space for buffer
                p
                    .asTypedList(s[0])
                    .setRange(0, s[0], availableImage.planes[0].bytes);

                final imageffi = dylib.lookupFunction<
                    Void Function(Pointer<Uint8>, Pointer<Uint32>),
                    void Function(
                        Pointer<Uint8>, Pointer<Uint32>)>('image_ffi');
                imageffi(p, s);

                if (mounted) {
                  setState(() {
                    _old = _img;
                    _img = Image.memory(p.asTypedList(s[0]));
                  });
                }

                malloc.free(p);
                malloc.free(s);
              });
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            logger.e(e);
            print(e);
          }
        },
        child: _isStreaming
            ? const Icon(Icons.visibility)
            : const Icon(Icons.camera_alt),
      ),
    );
  }
}
