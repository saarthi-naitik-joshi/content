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

  @override
  void initState() {
    super.initState();
    _isIOS = Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    return _isIOS ? const IosBottomSheet() : const AndroidBottomSheet();
  }
}

class AndroidBottomSheet extends StatefulWidget {
  const AndroidBottomSheet({Key? key}) : super(key: key);

  @override
  State<AndroidBottomSheet> createState() => _AndroidBottomSheetState();
}

class _AndroidBottomSheetState extends State<AndroidBottomSheet> {
  List<File>? files;
  XFile? xFile;
  List<XFile>? xFiles;
  String _filesPosted = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> postFiles(List<String> filePaths, BuildContext context) async {
    try {
      List<MultipartFile> fileList = [];
      filePaths.forEach((element) async {
        MultipartFile result = await MultipartFile.fromFile(element);
        fileList.add(result);
      });
      print('BASE_URL $BASE_URL');
      var dio = Dio();
      var formData = FormData.fromMap({'files': fileList});
      var response = await dio.post('$BASE_URL/uploadfiles',
          data: formData,
          options: Options(headers: {'Content-Type': 'multipart/form-data'}));
      if (response.statusCode == 200) {
        _filesPosted = 'Success:' + fileList.length.toString() + ' files added';
        print(_filesPosted);
        setState(() {});
      } else {
        _filesPosted = 'Error';
        print('post failed: ${response.statusMessage}');
      }
      Navigator.of(context).pop;
    } catch (e) {
      print('post failed: ${e.toString()}');
      _filesPosted = 'Error';
    }
  }

  Future<void> postXFiles(ImageSource imageOption, BuildContext context) async {
    try {
      List<String> filePaths = [];
      if (imageOption == ImageSource.camera) {
        xFile = null;
        xFile = await _picker.pickImage(source: ImageSource.camera);
        if (xFile != null) {
          filePaths.add(xFile?.path ?? '');
          postFiles(filePaths, context);
        }
      } else {
        xFiles = [];
        xFiles = await _picker.pickMultiImage();

        if (xFiles?.isNotEmpty ?? true) {
          xFiles?.forEach((xfile) {
            filePaths.add(xfile.path);
          });
          postFiles(filePaths, context);
        }
      }

      setState(() {});
    } catch (e) {
      print('error: ${e.toString()}');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(title: const Text('Material Scaffold')),
        body: Container(
          color: const Color(0xffc8c8c8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
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
                                          'Upload File',
                                          style: textStyle,
                                        ))),
                                    onTap: () async {
                                      var result = await FilePicker.platform
                                          .pickFiles(
                                              allowMultiple: true,
                                              type: FileType.custom,
                                              dialogTitle: 'Choose Files',
                                              allowedExtensions: ['pdf']);

                                      if (result != null) {
                                        print('inthey');
                                        files = [];
                                        files = result.paths
                                            .map((path) => File(path ?? ''))
                                            .toList();

                                        if (files!.isNotEmpty) {
                                          List<String> filePathList = [];
                                          files!.forEach((file) {
                                            filePathList.add(file.path);
                                          });
                                          await postFiles(
                                              filePathList, context);
                                        }
                                      } else {
                                        print('console: No files ');
                                      }
                                      setState(() {});
                                      Navigator.of(context).pop;
                                    },
                                  ),
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
                                    onTap: () => postXFiles(
                                        ImageSource.gallery, context),
                                  ),
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
                                    onTap: () =>
                                        postXFiles(ImageSource.camera, context),
                                  ),
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

class IosBottomSheet extends StatefulWidget {
  const IosBottomSheet({Key? key}) : super(key: key);

  @override
  State<IosBottomSheet> createState() => _IosBottomSheetState();
}

class _IosBottomSheetState extends State<IosBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton(
          onPressed: () {
            showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                title: const Text(
                  'Upload',
                ),
                message: const Text('Select File to upload '),
                actions: <CupertinoActionSheetAction>[
                  CupertinoActionSheetAction(
                    child: const Text('Upload File'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('Choose from gallery'),
                    onPressed: () {
                      //imageFile = UploadHelper();
                    },
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('Take a photo'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          },
          child: const Text('Cupertino Action Sheet'),
        ),
      ),
    ));
  }
}
