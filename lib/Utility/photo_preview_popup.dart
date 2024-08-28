import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';

import '../AppStation/Protect/Incident_report/MyPdfViewer.dart';
import '../AppStation/Protect/Incident_report/submit_incident.dart';

class PhotoPreviewDialogPopUp extends StatefulWidget {
  List<FileDetails> fileList = <FileDetails>[];

  PhotoPreviewDialogPopUp({required this.fileList});

  @override
  _PhotoPreviewDialogPopUpState createState() =>
      _PhotoPreviewDialogPopUpState(fileList);
}

class _PhotoPreviewDialogPopUpState extends State<PhotoPreviewDialogPopUp> {
  bool isPdf = false;

  List<FileDetails> m_fileList;

  _PhotoPreviewDialogPopUpState(this.m_fileList);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  )),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, right: 24, bottom: 10),
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: kReSustainabilityRed),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, m_fileList);
                },
                child: const Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15.0,
                  ),
                ),
              ),
            ),
          ]),
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          Container(
            width: 500.0,
            height: 330.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: m_fileList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: Center(
                        child: Column(
                      children: [
                        if (m_fileList[index].fileName.contains(".pdf")) ...[
                          Expanded(
                            flex: 8,
                            child: Center(
                              child: ElevatedButton(
                                child: const Text(
                                  'Open PDF file',
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyPdfViewer(
                                          pdfPath: m_fileList[index].filePath),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            flex: 8,
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                child: Image.memory(
                                    const Base64Codec()
                                        .decode(m_fileList[index].base64),
                                    gaplessPlayback: true)),
                          ),
                        ],
                        Expanded(
                            flex: 1,
                            child: IconButton(
                              iconSize: 25,
                              icon: const Icon(
                                Icons.delete,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    m_fileList.removeAt(index);
                                    if (m_fileList.isEmpty) {
                                      Navigator.pop(context, m_fileList);
                                    }
                                  },
                                );
                              },
                            )),
                      ],
                    )),
                  );
                }),
          ),
          Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                " Photo Count : ${m_fileList.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }
}
