import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

class MainScreen extends StatefulWidget {
  final CameraDescription camera;
  final double delay;
  const MainScreen({Key? key, required this.camera, required this.delay})
      : super(key: key);
  static const routeName = 'main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var cameras;
  XFile? chosen_image;
  XFile? image;
  File? fileImage;

  void takePicture() async {
    try {
      await _initializeControllerFuture;
      image = await _controller.takePicture();
      final Directory directory =
          // ignore: await_only_futures
          await syspaths.getApplicationDocumentsDirectory();

      fileImage = File(image!.path);

      final imageName = basename(fileImage!.path);
      await File(image!.path).copy('${directory.path}/$imageName');
      GallerySaver.saveImage(image!.path, albumName: 'KUBUS');
    } catch (err) {
      print(err);
      setState(() {});
    }
  }

  void pickPicture() async {
    // using your method of getting an image
    try {
      await ImagePicker()
          .pickImage(source: ImageSource.gallery)
          .then((value) async {
        image = value;
        final Directory pathDirectory =
            await syspaths.getApplicationDocumentsDirectory();
        final String cachePath = pathDirectory.path;
        File(value!.path).copy('$cachePath/image');
        setState(() {
          fileImage = File(value.path);
        });
        return null;
      });
    } catch (err) {}
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (availableCameras().then((val) => cameras = val)),
      builder: (ctx, snapshot) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xff252525),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                if (image != null)
                  Expanded(
                    child: GestureDetector(
                        onTap: () async {
                          await Future.delayed(
                              Duration(seconds: widget.delay.round()));
                          takePicture();
                        },
                        child: Image.file(File(image!.path))),
                  ),
                if (image == null)
                  Center(
                      child: ElevatedButton(
                    onPressed: () async {
                      pickPicture();
                      //takePicture();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        minimumSize: const Size(60, 90)),
                    child: SizedBox(
                        width: 60,
                        height: 90,
                        child: Image.asset(
                          './assets/kubus.jpg',
                          fit: BoxFit.cover,
                        )),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }
}
