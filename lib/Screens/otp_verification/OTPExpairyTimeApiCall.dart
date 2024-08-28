import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';

class OTPExpairyTimeApi {
  String mSessionId;
  String mEmailID;
  String mOTP;

  OTPExpairyTimeApi(this.mSessionId, this.mEmailID, this.mOTP);

  Future<String> callOTPExpairyTimeAPi() async {
    var headers = {'Content-Type': 'application/json', 'Cookie': mSessionId};
    var request = http.Request('POST', Uri.parse(VERIFY_OTP));
    request.body = json.encode({"email_id": mEmailID, "otp_code": mOTP});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.body;
  }
}
