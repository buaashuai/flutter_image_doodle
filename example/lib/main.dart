import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';

void main() => runApp(App());

const kCanvasSize = 200.0;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ImageGenerator(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageGenerator extends StatefulWidget {
  final Random rd;
  final int numColors;

  ImageGenerator()
      : rd = Random(),
        numColors = Colors.primaries.length;

  @override
  _ImageGeneratorState createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  ByteData imgBytes;
  String saveImagePath = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Container(
          color: Colors.pink[50],
          child: imgBytes != null
              ? Center(
                  child: Image.memory(
                  Uint8List.view(imgBytes.buffer),
                  width: kCanvasSize,
                  height: kCanvasSize,
                ))
              : Container(),
        )),
        Container(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            saveImagePath ?? '',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
        Container(
          width: double.infinity,
          height: 100.0,
          color: Colors.amberAccent,
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              RaisedButton(child: Text('生成图片'), onPressed: generateImage),
              SizedBox(
                width: 10.0,
              ),
              RaisedButton(child: Text('保存图片'), onPressed: saveImage),
            ],
          ),
        ),
      ],
    );
  }

  void saveImage() async {
    PermissionGroup permission1 = PermissionGroup.storage;
    final List<PermissionGroup> permissions = <PermissionGroup>[permission1];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult = await PermissionHandler().requestPermissions(permissions);
    PermissionStatus _permissionStatus = permissionRequestResult[permission1];
    if (_permissionStatus == PermissionStatus.granted) {
      Directory baseDirectory;
      if (Platform.isAndroid) {
        baseDirectory = await getExternalStorageDirectory();
      } else {
        baseDirectory = await getApplicationDocumentsDirectory();
      }
      String basePath = join(baseDirectory.path, '${DateTime.now().millisecondsSinceEpoch}.png');
      try {
        File(basePath).writeAsBytesSync(imgBytes.buffer.asInt8List());
        setState(() {
          saveImagePath = '图片保存成功：$basePath';
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void generateImage() async {
    final color = Colors.primaries[widget.rd.nextInt(widget.numColors)];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(kCanvasSize, kCanvasSize)));

    final stroke = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, kCanvasSize, kCanvasSize), stroke);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(
          widget.rd.nextDouble() * kCanvasSize,
          widget.rd.nextDouble() * kCanvasSize,
        ),
        20.0,
        paint);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image img = await picture.toImage(200, 200);
    final ByteData pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      imgBytes = pngBytes;
    });
  }
}
