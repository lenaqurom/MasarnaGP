import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masarna/trip/drawer/makememories/imageview.dart';
import 'package:masarna/trip/drawer/makememories/album.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(MaterialApp(home: MakeMemoriesPage()));
}

class MakeMemoriesPage extends StatefulWidget {
  @override
  _MakeMemoriesPageState createState() => _MakeMemoriesPageState();
}

class _MakeMemoriesPageState extends State<MakeMemoriesPage> {
  List<FileItem> files = [];
  List<String> imagePaths = [];
  List<String> videoPaths = [];
  int downloadProgress = 0;
  bool downloadFinish = false;
  bool downloadStart = false;
  bool videoMergingCompleted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var file in files) {
      file.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Make Memories',
          style: TextStyle(
            color: Color.fromARGB(255, 39, 26, 99),
            fontFamily: 'Dosis',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          files.isNotEmpty
              ? Container(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      double spacing = 8.0;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          double itemWidth = constraints.maxHeight;

                          if (files[index].isVideo) {
                            double videoAspectRatio = files[index]
                                .videoController!
                                .videoPlayerController
                                .value
                                .aspectRatio;
                            double videoHeight = itemWidth / videoAspectRatio;

                            if (videoHeight > constraints.maxHeight) {
                              itemWidth =
                                  constraints.maxHeight * videoAspectRatio;
                            }
                          }

                          return GestureDetector(
                            onTap: () {
                              _showImageDialog(files[index].imageFile!, index);
                            },
                            child: Container(
                              width: itemWidth,
                              height: constraints.maxHeight,
                              margin: EdgeInsets.only(right: spacing),
                              child: Hero(
                                tag: 'imageHero${index}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: files[index].isVideo
                                      ? Chewie(
                                          controller:
                                              files[index].videoController!,
                                        )
                                      : Image.file(
                                          files[index].imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              : Container(
                  height: 230,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the radius as needed
                    child: Image.asset(
                      'images/mem3.png', // Replace with the actual path to your image
                      height: 200,
                      width: 395,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
    //       if (files.length > 2)
    //         GestureDetector(
    //           onTap: () {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => RemainingMediaPage(
    //       remainingFiles: files,
    //       onDelete: _deleteImage,
    //     ),
    //   ),
    // );
    //           },
              
    //           child: Container(
    //             width: 50,
    //             height: 50,
    //             child: Text(
    //               "View All",
    //               style: TextStyle(fontFamily: 'Dosis', fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
    //             ),
                
    //           ),
    //         ),
          SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Let's Make Memories..!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DancingScript',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Upload your images and videos now!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Dosis',
                  ),
                ),

                SizedBox(height: 70), // Add some spacing between the buttons
                ElevatedButton(
                  onPressed: () async {
                    _showDownloadDialog(); // Show the download dialog
                    setState(() {
                      downloadStart = true;
                    });

                    await VideoMerger();
                    setState(() {
                      downloadProgress = 0;
                      downloadFinish = true;
                      downloadStart = false;
                      if(imagePaths.isEmpty){
                        downloadFinish = false;

                      }
                    });

                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 39, 26, 99), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: downloadStart,
                          child: Column(
                            children: [
                              CircularPercentIndicator(
                                radius: 20.0,
                                animation: true,
                                animationDuration: 1200,
                                lineWidth: 3.0,
                                percent: downloadProgress / 100,
                                circularStrokeCap: CircularStrokeCap.butt,
                                backgroundColor: Color.fromARGB(213, 226, 224, 243),
                                progressColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: !downloadStart,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AntDesign.download,
                                color:
                                    downloadFinish ? Colors.green : Color.fromARGB(213, 226, 224, 243),
                              ),
                              SizedBox(
                                  width:
                                      8), // Add spacing between the icon and text
                              Text(
                                downloadFinish ? "Your Reel Downloded" : "Download Your Reel",
                                // 'Download Your Reel',
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Dosis'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet();
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
        backgroundColor: Color.fromARGB(255, 39, 26, 99), // Customize the color as needed
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white,
        notchMargin: 8.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 40,width: 40,)
          ],
        ),
      ),
    );
  }

  void _deleteImage(int index) {
  setState(() {
    files.removeAt(index);
    if (index < imagePaths.length) {
      imagePaths.removeAt(index);
    }
    if (index < videoPaths.length) {
      videoPaths.removeAt(index);
    }
  });
  }

  void _showDownloadDialog() {
    // Check if there are images in the imagePaths list
    if (imagePaths.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.BOTTOMSLIDE,
        title: 'No Images',
        desc: 'Please add images to make a reel.',
        btnCancelOnPress: () {
        },
        btnCancelText: 'OK',
        btnCancelIcon: Icons.info,
        btnCancelColor: Color.fromARGB(255, 39, 26, 99),
      )..show();
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.image, color: Color.fromARGB(255, 39, 26, 99),),
                  title: Text('Add Image', style: TextStyle(fontFamily: 'Dosis',color: Color.fromARGB(255, 39, 26, 99)),),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam,color: Color.fromARGB(255, 39, 26, 99)),
                  title: Text('Add Video', style: TextStyle(fontFamily: 'Dosis',color: Color.fromARGB(255, 39, 26, 99))),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_album_outlined,color: Color.fromARGB(255, 39, 26, 99)),
                  title: Text('View Album',style: TextStyle(fontFamily: 'Dosis',color: Color.fromARGB(255, 39, 26, 99))),
                  onTap: () {
                    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumPage(
          remainingFiles: files,
          onDelete: _deleteImage,
        ),
      ),
    );
                  },
                ),

                // Add more options as needed
              ],
            ),
          ),
        );
      },
    );
  }

// Inside the _showImageDialog method
  void _showImageDialog(File imageFile, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewScreen(
          imageFile: imageFile,
          onDelete: () {
            _deleteImage(index);
          },
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (pickedFiles != null && pickedFiles.files.isNotEmpty) {
      setState(() {
        files.addAll(
          pickedFiles.files.asMap().entries.map((entry) {
            int index = entry.key;
            PlatformFile platformFile = entry.value;
            File file = File(platformFile.path!);
            FileItem item = FileItem(imageFile: file, isVideo: false);
            imagePaths.add(getNewImagePath(file.path!, index));
            return item;
          }),
        );
      });

      // Print paths after each image upload
      print('Image Paths:');
      for (int i = 0; i < imagePaths.length; i++) {
        print('- $i: ${imagePaths[i]}');
      }
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        VideoPlayerController videoController =
            VideoPlayerController.file(File(pickedFile.path));
        ChewieController chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: true,
          looping: true,
        );
        files.add(FileItem(
          videoController: chewieController,
          isVideo: true,
        ));
        String videoPath = getNewVideoPath(pickedFile.path!, files.length - 1);
        videoPaths.add(videoPath);

        // Print all video paths
        print('Video Paths:');
        for (int i = 0; i < videoPaths.length; i++) {
          print('- $i: ${videoPaths[i]}');
        }
      });
    }
  }

  Future<void> VideoMerger() async {
    File f = File('mylist.txt');
    const String BASE_PATH = '/storage/emulated/0/Download/';
    const String AUDIO_PATH = BASE_PATH + 'audio4.mp3';
    const String OUTPUT_PATH = BASE_PATH + 'output.mp4';

    String imageInputs = imagePaths.map((path) => 'file \'$path\'').join('\n');
    String concatFilePath = BASE_PATH +
        'concat.txt'; // Specify the path where the concat file will be created
    File(concatFilePath).writeAsStringSync(imageInputs);
    await Future.delayed(Duration(milliseconds: 500)); // Initial delay
    downloadProgress = 0;
    downloadFinish = false;
    downloadStart = true;

    setState(() {
      downloadProgress = 70;
    });

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    if (await Permission.storage.request().isGranted) {
      String commandToExecute =
          '-loglevel debug -f concat -safe 0 -i $concatFilePath -i $AUDIO_PATH -framerate 1/2 ' +
              '-filter_complex "[0:v]setpts=100*PTS[v];[1:a]anull[a]" -map "[v]" -map "[a]" -y $OUTPUT_PATH';

      print('content of list' + imageInputs);
      int rc = await _flutterFFmpeg.execute(commandToExecute);

// String commandToExecute =
//     '-loglevel debug -i ${AUDIO_PATH} -framerate 1/2 -i ${BASE_PATH}%03d.jpg -filter_complex "[1:v]setpts=2*PTS[v];[0:a]anull[a]" -map "[v]" -map "[a]" -y ${OUTPUT_PATH}';
      _flutterFFmpeg
          .execute(commandToExecute)
          .then((rc) => print('ffmpeg process exited with rc: $rc'));
    } else if (await Permission.storage.isPermanentlyDenied) {
      openAppSettings();
      return;
    }
  }
}

String getNewImagePath(String imagePath, int index) {
  String imageName = imagePath.split('/file_picker/').last;

  String newPath = '/storage/emulated/0/Download/$imageName';

  return newPath;
}

String getNewVideoPath(String videoPath, int index) {
  // Split the existing path and take the part after '/cache/'
  String videoName = videoPath.split('/cache/').last;

  // Remove the dynamic part of the path
  videoName = videoName.split('/').last;

  // Concatenate with the new path
  String newPath = '/storage/emulated/0/Download/$videoName';

  return newPath;
}

class FileItem {
  File? imageFile;
  ChewieController? videoController;
  bool isVideo;

  FileItem({this.imageFile, this.videoController, required this.isVideo});

  void dispose() {
    videoController?.dispose();
  }
}


