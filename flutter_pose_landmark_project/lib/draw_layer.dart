import 'dart:ffi' as ffi;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'detection_page.dart';
import 'main.dart';

class DarwPoseLayer extends StatelessWidget
{
  const DarwPoseLayer({Key? key,
    required this.pose_result,
    required this.imgW,
    required this.imgH
  }) : super(key: key);
  final int imgW;
  final int imgH;
  final PoseLandmarkResult pose_result;

  @override
  Widget build(BuildContext context)
  {
    return CustomPaint(
      painter: LandmarkPainter(
        pose_result: pose_result,
        imgW: imgW,
        imgH: imgH
      ),
    );
  }
}

class LandmarkPainter extends CustomPainter {
  LandmarkPainter({
    required this.pose_result,
    required this.imgW,
    required this.imgH
  });

  final int imgW;
  final int imgH;
  final Paint _paint = Paint()
    ..color = Colors.blue
    // ..strokeCap = StrokeCap.round
    // ..isAntiAlias = true
    // ..style = PaintingStyle.fill
    ..strokeWidth = 4.0;

  final PoseLandmarkResult pose_result;
  final int POSE_LANDMARK_NUM = 33;

  @override
  void paint(Canvas canvas, Size size)
  {
    if (pose_result.poseNum == 0) { // check if we detect person.
        return;
      }

    List<Offset> points = [];

    for (int i = 0; i < POSE_LANDMARK_NUM; i++) {
      final double x = pose_result.points[i * 2] * imgW;
      final double y = pose_result.points[i * 2 + 1] * imgH;
      // logger.i("MOO log point_${i} , h w = [${imgH}, ${imgW}], xy = [${x}, ${y}]!");
      points.add(Offset(x, y));

      }
    canvas.drawPoints(PointMode.points, points, _paint);

  }

  @override
  bool shouldRepaint(LandmarkPainter oldDelegate)
  {
    return true;
  }
}