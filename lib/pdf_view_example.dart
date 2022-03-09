import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFexample extends StatefulWidget {
  const PDFexample({Key? key}) : super(key: key);

  @override
  State<PDFexample> createState() => _PDFexampleState();
}

class _PDFexampleState extends State<PDFexample> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages;
  int? currentPage;
  bool isReady = false;
  String errorMessage = '';
  String pathPDF = "";
  String landscapePathPdf = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl();
  }

  Future createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    //  console .log("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = "http://www.pdf995.com/samples/pdf.pdf";
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    var f = await completer.future;
    setState(() {
      remotePDFpath = f.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('remotePDFpath: $remotePDFpath');

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF View'),
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () {
            try {
              Navigator.of(context).maybePop();
            } catch (e) {}
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: (remotePDFpath == '')
                ? Container(
                    child: Text('Loading ...', style: TextStyle(fontSize: 24)))
                : PDFView(
                    filePath: remotePDFpath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: true,
                    onRender: (_pages) {
                      setState(() {
                        pages = _pages;
                        currentPage = 0;
                        isReady = true;
                      });
                    },
                    onError: (error) {
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      print('$page: ${error.toString()}');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    onPageChanged: (int? page, int? total) {
                      print('page change: $page/$total');
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FutureBuilder<PDFViewController>(
                  future: _controller.future,
                  builder:
                      (context, AsyncSnapshot<PDFViewController> snapshot) {
                    if (snapshot.hasData) {
                      return FloatingActionButton.extended(
                        label: const Text('-', style: TextStyle(fontSize: 24)),
                        onPressed: () async {
                          if (currentPage != 0) {
                            currentPage = currentPage! - 1;
                            await snapshot.data!.setPage(currentPage!);
                            setState(() {});
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FutureBuilder<PDFViewController>(
                  future: _controller.future,
                  builder:
                      (context, AsyncSnapshot<PDFViewController> snapshot) {
                    if (snapshot.hasData) {
                      return FloatingActionButton.extended(
                        label: const Text('+', style: TextStyle(fontSize: 24)),
                        onPressed: () async {
                          if (pages != currentPage! + 1) {
                            currentPage = currentPage! + 1;
                            await snapshot.data!.setPage(currentPage!);
                            setState(() {});
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
