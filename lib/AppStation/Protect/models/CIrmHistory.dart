import 'dart:convert';

List<CIrmHistory> modelUserFromJson(String str) => List<CIrmHistory>.from(
    json.decode(str).map((x) => CIrmHistory.fromJson(x)));

String modelUserToJson(List<CIrmHistory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CIrmHistory {
  String status;
  String approver_type;
  String user_name;
  String assigned_on;
  String action_taken;
  String sb_notes;
  String document_code;

  CIrmHistory(
      {required this.status,
      required this.approver_type,
      required this.user_name,
      required this.assigned_on,
      required this.action_taken,
      required this.sb_notes,
      required this.document_code});

  factory CIrmHistory.fromJson(Map<dynamic, dynamic> json) => CIrmHistory(
        status: json["status"],
        approver_type: json["approver_type"],
        user_name: json["user_name"],
        assigned_on: json["assigned_on"],
        action_taken: json["action_taken"],
        sb_notes: json["sb_notes"],
        document_code: json["document_code"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "approver_type": approver_type,
        "user_name": user_name,
        "assigned_on": assigned_on,
        "action_taken": action_taken,
        "sb_notes": sb_notes,
        "document_code": document_code,
      };
}
