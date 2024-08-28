import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../Utility/api_Url.dart';

class SubmitIdeaApi {
  String m_sessionId;
  String m_requestBody;

  SubmitIdeaApi(this.m_sessionId, this.m_requestBody);

  Future<Response?> callSubmitIdeaAPi() async {
    var dio = Dio();
    try {
      var response = await dio.post(SUBMIT_IDEA,
          data: m_requestBody,
          options: Options(
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'Cookie': m_sessionId,
              HttpHeaders.contentLengthHeader:m_requestBody.length,
              HttpHeaders.acceptHeader:"*/*",
              HttpHeaders.acceptEncodingHeader:"gzip, deflate, br",
              HttpHeaders.connectionHeader:"keep-alive"
            },
          ));
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }
}