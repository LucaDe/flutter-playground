import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../service/VisionService.dart';

class GeneralVision extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new GeneralVisionState();
}

class GeneralVisionState extends State<GeneralVision>
    with TickerProviderStateMixin {
  bool _loading = false;
  VisionResult _labelResult;
  File _currentImage;

  // Select (or capture) an image and detect labels
  onImageSelect(ImageSource source) async {
    var file = await ImagePicker.pickImage(
      source: source,
    );

    if (file == null) {
      return;
    }

    setState(() {
      _currentImage = file;
      _loading = true;
    });

    VisionResult labels =
        await VisionService.instance.detectGeneralLabels(file);
    setState(() {
      _labelResult = labels;
      _loading = false;
    });
  }

  Widget buildHighlighBox() {
    if (_loading) {
      return CircularProgressIndicator();
    }

    if (_currentImage == null) {
      return Text('Please select an image');
    }

    // Select most confident label
    if (_labelResult.labels.length > 0) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_labelResult.labels[0].label, style: TextStyle(fontSize: 22)),
            Text('Main Label'),
          ],
        ),
      );
    }
    return Text('Please select another image');
  }

  bool notNull(Object o) => o != null;

  Widget buildBody() {
    return Column(
      children: <Widget>[
        Container(
          height: 300,
          color: Colors.green,
          child: Stack(
            fit: StackFit.expand,
            overflow: Overflow.visible,
            children: <Widget>[
              _currentImage == null
                  ? null
                  : Image.file(_currentImage, fit: BoxFit.cover),
              Positioned(
                bottom: -42.5,
                left: 30,
                right: 30,
                child: Container(
                  height: 85,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(blurRadius: 5, color: Colors.black12),
                    ],
                  ),
                  child: Center(
                    child: buildHighlighBox(),
                  ),
                ),
              ),
            ].where(notNull).toList(),
          ),
        ),
        _labelResult != null
            ? Padding(
                padding: EdgeInsets.only(top: 75),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('All Labels',
                              style: TextStyle(fontSize: 20))),
                      Text(_labelResult.formatedLabels),
                    ],
                  ),
                ),
              )
            : null
      ].where(notNull).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          buildBody(),
          new AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15.0, 0),
            child: FloatingActionButton(
                heroTag: "btn1",
                isExtended: false,
                child: Icon(Icons.camera_alt),
                onPressed: () {
                  onImageSelect(ImageSource.camera);
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: FloatingActionButton(
                heroTag: "btn2",
                child: Icon(Icons.camera_enhance),
                onPressed: () {
                  onImageSelect(ImageSource.gallery);
                }),
          )
        ],
      ),
    );
  }
}
