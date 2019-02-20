import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class VisionResult {
  List<Label> labels;
  String formatedLabels;

  VisionResult(this.labels, this.formatedLabels);
}

class VisionService {
  static final VisionService instance = VisionService();
  final FirebaseVision _firebaseVision = FirebaseVision.instance;

  _buildLabelText(List<Label> labels) {
    String s = '';
    for (final label in labels) {
      var confidence = (label.confidence * 100).toStringAsFixed(2);
      s += "${label.label}: ${confidence}% \n";
      print(label.entityId);
    }
    return s;
  }

  Future<VisionResult> detectGeneralLabels(File file) async {
    final visionImage = FirebaseVisionImage.fromFile(file);
    var labels =
        await _firebaseVision.cloudLabelDetector().detectInImage(visionImage);
    return VisionResult(labels, _buildLabelText(labels));
  }

  detectFaces(File file) async {
    final visionImage = FirebaseVisionImage.fromFile(file);
    var faces = await _firebaseVision.faceDetector().detectInImage(visionImage);

    String s = '';
    for (Face f in faces.toList()) {
      s += f.smilingProbability.toString() + "\n";
    }
    return s;
  }
}
