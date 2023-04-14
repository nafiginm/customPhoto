import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  double opacityImage = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildBlurredImage(),
          const SizedBox(height: 32),
          Slider(
            value: opacityImage,
            min: 0.0,
            onChanged: (value) => setState(() => opacityImage = value),
          ),
        ],
      ),
    );
  }

  Widget buildBlurredImage() => Positioned.fill(
        child: Opacity(
          opacity: opacityImage,
          child: Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
          ),
        ),
      );
}

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   static const String title = 'Blur Widgets';

//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: title,
//         theme: ThemeData(primarySwatch: Colors.deepOrange),
//         home: const MainPage(title: title),
//       );
// }

// class MainPage extends StatefulWidget {
//   final String title;

//   const MainPage({
//     super.key,
//     required this.title,
//   });

//   @override
//   _MainPageState createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   double blurImage = 1.0;

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: ListView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           children: [
//             buildBlurredImage(),
//             const SizedBox(height: 32),
//             Slider(
//               value: blurImage,
//               min: 0.0,
//               onChanged: (value) => setState(() => blurImage = value),
//             ),
//             const SizedBox(height: 32),
//           ],
//         ),
//       );

//   Widget buildBlurredImage() => Positioned.fill(
//         child: Opacity(
//           opacity: blurImage,
//           child: Image.network(
//             'https://images.unsplash.com/photo-1606569371439-56b1e393a06b?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2134&q=80',
//             fit: BoxFit.cover,
//           ),
//         ),
//       );
// }
