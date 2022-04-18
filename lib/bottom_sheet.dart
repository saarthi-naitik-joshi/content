import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

const textStyle = TextStyle(color: Colors.blue, fontSize: 16);
const menuBackgroundColor = Color(0xffeeeeee);
const BASE_URL = 'http://192.168.29.149:3001';

class BottomSheetImplementation extends StatefulWidget {
  const BottomSheetImplementation({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  State<BottomSheetImplementation> createState() =>
      _BottomSheetImplementationState();
}

class _BottomSheetImplementationState extends State<BottomSheetImplementation> {
  late bool _isIOS;
  List<File>? files;
  XFile? xFile;
  List<XFile>? xFiles;
  String _filesPosted = '';

  @override
  void initState() {
    super.initState();
    _isIOS = Platform.isIOS;
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> handleFilesUpload() async {
    var result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        dialogTitle: 'Choose Files',
        allowedExtensions: ['pdf', 'png', 'jpeg', 'jpg', 'svg']);

    if (result != null) {
      print('inthey');
      files = [];
      files = result.paths.map((path) => File(path ?? '')).toList();

      if (files!.isNotEmpty) {
        List<String> filePathList = [];
        files!.forEach((file) {
          filePathList.add(file.path);
        });
        await postFiles(filePathList);
      } else {
        _filesPosted = 'Fail: User Cancelled';
      }
    } else {
      _filesPosted = 'Fail: User Cancelled';
    }
    setState(() {});
  }

  Future<void> handleImageUpload(ImageSource imageOption) async {
    try {
      List<String> filePaths = [];
      if (imageOption == ImageSource.camera) {
        xFile = null;
        xFile = await _picker.pickImage(source: ImageSource.camera);
        if (xFile != null) {
          filePaths.add(xFile?.path ?? '');
          postFiles(filePaths);
        } else {
          _filesPosted = 'Fail: User Cancelled';
        }
      } else {
        xFiles = [];
        xFiles = await _picker.pickMultiImage();

        if (xFiles?.isNotEmpty ?? false) {
          xFiles?.forEach((xfile) {
            filePaths.add(xfile.path);
          });
          postFiles(filePaths);
        } else {
          _filesPosted = 'Fail: User Cancelled';
        }
      }

      setState(() {});
    } catch (e) {
      print('error: ${e.toString()}');
    }
  }

  Future<void> postFiles(List<String> filePaths) async {
    try {
      List<MultipartFile> fileList = [];
      for (var element in filePaths) {
        File fl = File(element);
        MultipartFile result = await MultipartFile.fromFile(element,
            filename: fl.path.split('/').last);
        fileList.add(result);
      }
      print('BASE_URL $BASE_URL');
      var dio = Dio();
      var formData = FormData.fromMap({'files': fileList});
      var response = await dio.post(
        '$BASE_URL/uploadfiles',
        data: formData,
      ); // options: Options(headers: {'Content-Type': 'multipart/form-data'})
      if (response.statusCode == 200) {
        _filesPosted = 'Success:' + fileList.length.toString() + ' files added';
        print(_filesPosted);
        setState(() {});
      } else {
        _filesPosted = 'Error';
        print('post failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('post failed: ${e.toString()}');
      _filesPosted = 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(title: const Text('Scaffold Title')),
        body: Container(
          color: const Color(0xffc8c8c8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isIOS
                    ? CupertinoButton(
                        onPressed: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (BuildContext context) =>
                                CupertinoActionSheet(
                              title: const Text(
                                'Cupertino Bottom Sheet',
                              ),
                              message: const Text('Upload Files & Images'),
                              actions: <CupertinoActionSheetAction>[
                                CupertinoActionSheetAction(
                                    child: const Text('Upload Files'),
                                    onPressed: () {
                                      handleFilesUpload();
                                      Navigator.of(context).pop();
                                    }),
                                CupertinoActionSheetAction(
                                    child: const Text('Pictures from gallery'),
                                    onPressed: () async {
                                      await handleImageUpload(
                                          ImageSource.gallery);
                                      Navigator.of(context).pop();
                                    }),
                                CupertinoActionSheetAction(
                                    child: const Text('Picture from camera'),
                                    onPressed: () {
                                      handleImageUpload(ImageSource.camera);
                                      Navigator.of(context).pop();
                                    })
                              ],
                            ),
                          );
                        },
                        child: const Text('Cupertino Action Sheet'),
                      )
                    : InkWell(
                        child: const Text(
                          'Open Material Bottom Sheet',
                          style: textStyle,
                        ),
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 200,
                                width: double.infinity,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      InkWell(
                                          child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: const Center(
                                                  child: Text(
                                                'Upload Files',
                                                style: textStyle,
                                              ))),
                                          onTap: () {
                                            handleFilesUpload();
                                            Navigator.of(context).pop();
                                          }),
                                      const Divider(
                                        thickness: 1,
                                        color: Color(0xFFCFCFCF), // .grey[700],
                                      ),
                                      InkWell(
                                          child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: const Center(
                                                  child: Text(
                                                'Pictures from gallery',
                                                style: textStyle,
                                              ))),
                                          onTap: () async {
                                            await handleImageUpload(
                                                ImageSource.gallery);
                                            Navigator.of(context).pop();
                                          }),
                                      const Divider(
                                        thickness: 1,
                                        color: Color(0xFFCFCFCF), // .grey[700],
                                      ),
                                      InkWell(
                                          child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: const Center(
                                                  child: Text(
                                                'Picture from camera',
                                                style: textStyle,
                                              ))),
                                          onTap: () {
                                            handleImageUpload(
                                                ImageSource.camera);
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                const SizedBox(height: 20),
                Text(_filesPosted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
