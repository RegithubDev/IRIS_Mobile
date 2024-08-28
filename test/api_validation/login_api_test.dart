import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  /*group('getLoginAPICall', () {
    test('return error message when http response is unsuccessful', () async {
      final mockHTTPClient = MockClient((request) async {
        final response = {};
        return Response(jsonEncode(response), 404);
      });

      LoginApiCall sng = LoginApiCall("pcabhijith2@gmail.com","pixel 3A","1");
      expect(await sng.unitTestCallLoginAPi(), '200');
    });

    test('Testing data saving into shared preference', () async {

      LoginApiCall sng = LoginApiCall("pcabhijith2@gmail.com","pixel 3A","1");
      expect(await sng.userLogin("pcabhijith2@gmail.com","pixel 3A","1"), '54321');
    });

  });*/
}
