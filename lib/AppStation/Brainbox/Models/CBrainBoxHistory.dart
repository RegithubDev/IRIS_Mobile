import 'dart:convert';

List<CBrainBoxHistory> modelUserFromJson(String str) => List<CBrainBoxHistory>.from(
    json.decode(str).map((x) => CBrainBoxHistory.fromJson(x)));

String modelUserToJson(List<CBrainBoxHistory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CBrainBoxHistory {
  String status;
  String approver_type;
  String user_name;
  String assigned_on;
  String action_taken;
  String sb_notes;
  String id;

  CBrainBoxHistory(
      {required this.status,
        required this.approver_type,
        required this.user_name,
        required this.assigned_on,
        required this.action_taken,
        required this.sb_notes,
        required this.id});

  factory CBrainBoxHistory.fromJson(Map<dynamic, dynamic> json) => CBrainBoxHistory(
    status: json["status"],
    approver_type: json["approver_type"],
    user_name: json["user_name"],
    assigned_on: json["assigned_on"],
    action_taken: json["action_taken"],
    sb_notes: json["sb_notes"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "approver_type": approver_type,
    "user_name": user_name,
    "assigned_on": assigned_on,
    "action_taken": action_taken,
    "sb_notes": sb_notes,
    "id": id,
  };
}
