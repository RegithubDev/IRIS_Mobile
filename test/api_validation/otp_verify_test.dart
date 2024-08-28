import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/Screens/otp_verification/OTPVerifyApiCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  group('For testing OTP verification API', () {
    test('returns otp response string when http response is successful',
            () async {

              final mockHTTPClient = MockClient((request) async {
            final response = {"OTP Sent Succesfully."};

            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          OTPVerifyApiCall sng = OTPVerifyApiCall(
              "JSESSIONID=80019B916CFB2688E39718D4F45B8EDE",
            "pcabhijith2@gmail.com",
          "1234");
          expect(await sng.callOTPVerifyAPi(), isA<String>());
        });


  });
}
