import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:masarna/trip/drawer/makememories/imageview.dart';
import 'package:masarna/trip/drawer/makememories/makememories.dart';

class AlbumPage extends StatelessWidget {
  final List<FileItem> remainingFiles;
  final Function(int) onDelete;

  AlbumPage({required this.remainingFiles, required this.onDelete});

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
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Your Album",
          style: TextStyle(
            color: Color.fromARGB(255, 39, 26, 99),
            fontFamily: 'Dosis',
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              itemCount: remainingFiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
  if (remainingFiles.isNotEmpty && !remainingFiles[index].isVideo) {
                      // Navigate to ImageView only for images
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewScreen(
                            imageFile: remainingFiles[index].imageFile!,
                            onDelete: () {
                              onDelete(index);
                              Navigator.pop(context); // Close ImageViewScreen
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: remainingFiles[index].isVideo
                          ? Chewie(
                              controller: remainingFiles[index].videoController!,
                            )
                          : Image.file(
                              remainingFiles[index].imageFile!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${countFilesByType(remainingFiles, isVideo: true)} Videos, ${countFilesByType(remainingFiles, isVideo: false)} Images',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 39, 26, 99),
                fontFamily: 'Dosis',
              ),
            ),
          ),
        ],
      ),
    );
  }

  int countFilesByType(List<FileItem> files, {required bool isVideo}) {
    return files.where((file) => file.isVideo == isVideo).length;
  }
}
