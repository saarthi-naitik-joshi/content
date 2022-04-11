import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

const textStyle = TextStyle(color: Colors.blue, fontSize: 20);
const menuBackgroundColor = Color(0xffeeeeee);

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
  File? selectedFile;
  XFile? image;
  Widget? imageWidget;
  String selectedFileName = '';
  PDFViewController? _controller;

  getPicture(ImageSource imageOption, BuildContext context) async {
    try {
      image = await UploadHelper().uploadFile(imageOption);
      selectedFileName = image?.name ?? 'NA';
      if (image != null) {
        selectedFile = null;
        imageWidget = Image.file(File(image?.path ?? ''));
      } else {
        imageWidget = const SizedBox();
      }
      setState(() {});
    } catch (e) {
      print('error: ${e.toString()}');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (image == null && selectedFile == null) {
      selectedFileName = '';
    } else if (image == null && selectedFile != null) {
      selectedFileName = selectedFile?.path ?? '';
    } else if (image != null && selectedFile == null) {
      selectedFileName = image?.name ?? '';
    } else if (image != null && selectedFile != null) {
      // Exception case: using image to over-ride selected file
      selectedFileName = image?.name ?? '';
    }
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
                            margin: const EdgeInsets.all(10),
                            height: 250,
                            width: double.infinity,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  InkWell(
                                    child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: const Center(
                                            child: Text(
                                          'Upload File',
                                          style: textStyle,
                                        ))),
                                    onTap: () async {
                                      print('inthey');

                                      var result = await FilePicker.platform
                                          .pickFiles(
                                              type: FileType.custom,
                                              dialogTitle: 'Choose File',
                                              allowedExtensions: ['pdf']);

                                      if (result != null) {
                                        imageWidget = const SizedBox();
                                        setState(() {});
                                        selectedFile = File(
                                            (result.files.first).path ?? '');
                                        _controller?.setPage(1);
                                        image = null;
                                        imageWidget = PDFView(
                                          filePath: selectedFile?.path,
                                          enableSwipe: false,
                                          swipeHorizontal: false,
                                          autoSpacing: false,
                                          pageFling: false,
                                          onRender: (_pages) {
                                            setState(() {});
                                          },
                                          onError: (error) {
                                            print(error.toString());
                                          },
                                          onPageError: (page, error) {
                                            print('$page: ${error.toString()}');
                                          },
                                          onViewCreated: (PDFViewController
                                              pdfViewController) {
                                            _controller
                                                ?.setPage(1)
                                                .whenComplete(
                                                    () => pdfViewController);
                                          },
                                        );
                                      } else {
                                        imageWidget = const SizedBox();
                                      }
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0xFFCFCFCF), // .grey[700],
                                  ),
                                  InkWell(
                                    child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: const Center(
                                            child: Text(
                                          'Picture from gallery',
                                          style: textStyle,
                                        ))),
                                    onTap: () => getPicture(
                                        ImageSource.gallery, context),
                                  ),
                                  const Divider(
                                    thickness: 1,
                                    color: Color(0xFFCFCFCF), // .grey[700],
                                  ),
                                  InkWell(
                                    child: Container(
                                        padding: const EdgeInsets.all(20),
                                        child: const Center(
                                            child: Text(
                                          'Picture from camera',
                                          style: textStyle,
                                        ))),
                                    onTap: () =>
                                        getPicture(ImageSource.camera, context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                const SizedBox(height: 50),
                SizedBox(height: 200, width: 200, child: imageWidget),
                const SizedBox(height: 20),
                Text('Selected File: $selectedFileName')
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

class UploadHelper {
  dynamic file;
  final ImagePicker _picker = ImagePicker();

  Future<dynamic>? uploadFile(ImageSource fileType) async {
    XFile? file;
    switch (fileType) {
      case ImageSource.camera:
        file = await _picker.pickImage(source: ImageSource.camera);

        break;
      case ImageSource.gallery:
        file = await _picker.pickImage(source: ImageSource.gallery);
        break;
    }
    return file;
  }
}
