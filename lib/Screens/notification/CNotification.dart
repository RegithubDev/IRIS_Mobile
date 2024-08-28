import 'dart:convert';

List<CNotification> modelUserFromJson(String str) => List<CNotification>.from(
    json.decode(str).map((x) => CNotification.fromJson(x)));

String modelUserToJson(List<CNotification> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CNotification {
  String user_id;
  String module_type;
  String message;
  String create_date;
  int session_count;
  int time_period;

  CNotification({
    required this.user_id,
    required this.module_type,
    required this.message,
    required this.create_date,
    required this.session_count,
    required this.time_period,
  });

  factory CNotification.fromJson(Map<dynamic, dynamic> json) => CNotification(
        user_id: json["user_id"],
        module_type: json["module_type"],
        message: json["message"],
        create_date: json["create_date"],
        session_count: json["session_count"],
        time_period: json["time_period"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "module_type": module_type,
        "message": message,
        "create_date": create_date,
        "session_count": session_count,
        "time_period": time_period,
      };
}
