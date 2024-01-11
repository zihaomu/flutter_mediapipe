import 'dart:io';
import 'package:dart_application_1/dart_application_1.dart' as dart_application_1;
import 'dart:ffi';
import 'dart:io' show Directory, Platform;
import './pose_landmark.dart';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

// void main(List<String> arguments) {
//   print('Hello world: ${dart_application_1.calculate()}!');
// }

// Example of handling a simple C struct
final class Coordinate extends Struct {
  @Double()
  external double latitude;

  @Double()
  external double longitude;
}

// Example of a complex struct (contains a string and a nested struct)
final class Place extends Struct {
  external Pointer<Utf8> name;

  external Coordinate coordinate;
}

// C function: char *hello_world();
// There's no need for two typedefs here, as both the
// C and Dart functions have the same signature
typedef HelloWorld = Pointer<Utf8> Function();

// C function: char *reverse(char *str, int length)
typedef ReverseNative = Pointer<Utf8> Function(Pointer<Utf8> str, Int32 length);
typedef Reverse = Pointer<Utf8> Function(Pointer<Utf8> str, int length);

// C function: void free_string(char *str)
typedef FreeStringNative = Void Function(Pointer<Utf8> str);
typedef FreeString = void Function(Pointer<Utf8> str);

// C function: struct Coordinate create_coordinate(double latitude, double longitude)
typedef CreateCoordinateNative = Coordinate Function(
    Double latitude, Double longitude);
typedef CreateCoordinate = Coordinate Function(
    double latitude, double longitude);

// C function: struct Place create_place(char *name, double latitude, double longitude)
typedef CreatePlaceNative = Place Function(
    Pointer<Utf8> name, Double latitude, Double longitude);
typedef CreatePlace = Place Function(
    Pointer<Utf8> name, double latitude, double longitude);

typedef DistanceNative = Double Function(Pointer<Coordinate> p1, Pointer<Coordinate> p2);
typedef Distance = double Function(Pointer<Coordinate> p1, Pointer<Coordinate> p2);

void main() {
  print("hello!");

  // test_image_funct();
  pose_landmark_api_test();
  // Open the dynamic library
  // var libraryPath =
  //     path.join(Directory.current.path, 'structs_library/build', 'libstructs.so');
  // if (Platform.isMacOS) {
  //   libraryPath = path.join(
  //       Directory.current.path, 'bin/structs_library/build', 'libstructs.dylib');
  // }
  // if (Platform.isWindows) {
  //   libraryPath = path.join(
  //       Directory.current.path, 'structs_library', 'Debug', 'structs.dll');
  // }
  // final dylib = DynamicLibrary.open(libraryPath);

  // final helloWorld =
  //     dylib.lookupFunction<HelloWorld, HelloWorld>('hello_world');
  // final message = helloWorld().toDartString();
  // print(message);

  // final reverse = dylib.lookupFunction<ReverseNative, Reverse>('reverse');
  // final backwards = 'backwards';
  // final backwardsUtf8 = backwards.toNativeUtf8();
  // final reversedMessageUtf8 = reverse(backwardsUtf8, backwards.length);
  // final reversedMessage = reversedMessageUtf8.toDartString();
  // calloc.free(backwardsUtf8);
  // print('$backwards reversed is $reversedMessage');

  // final freeString =
  //     dylib.lookupFunction<FreeStringNative, FreeString>('free_string');
  // freeString(reversedMessageUtf8);

  // final createCoordinate =
  //     dylib.lookupFunction<CreateCoordinateNative, CreateCoordinate>(
  //         'create_coordinate');
  // final coordinate = createCoordinate(3.5, 4.6);
  // print(
  //     'Coordinate is lat ${coordinate.latitude}, long ${coordinate.longitude}');

  // final myHomeUtf8 = 'My Home'.toNativeUtf8();
  // final createPlace =
  //     dylib.lookupFunction<CreatePlaceNative, CreatePlace>('create_place');
  // final place = createPlace(myHomeUtf8, 42.0, 24.0);
  // final name = place.name.toDartString();
  // calloc.free(myHomeUtf8);
  // final coord = place.coordinate;
  // print(
  //     'The name of my place is $name at ${coord.latitude}, ${coord.longitude}');
  // final distance = dylib.lookupFunction<DistanceNative, Distance>('distance');

  // final coordinate0 = createCoordinate(2.0, 2.0);
  // final coordinate1 = createCoordinate(5.0, 6.0);

  // // Allocate memory for the struct and copy the Dart struct's data to the allocated memory
  // final Pointer<Coordinate> coordinate0Ptr = calloc<Coordinate>();
  // coordinate0Ptr.ref
  // ..latitude = coordinate0.latitude
  // ..longitude = coordinate0.longitude;

  // final Pointer<Coordinate> coordinate1Ptr = calloc<Coordinate>();
  // coordinate1Ptr.ref
  // ..latitude = coordinate1.latitude
  // ..longitude = coordinate1.longitude;
  
  
  // final dist = distance(coordinate1Ptr, coordinate1Ptr);
  // print("distance between (2,2) and (5,6) = $dist");
}