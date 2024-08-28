import 'dart:convert';

List<CBrainBox> modelUserFromJson(String str) =>
    List<CBrainBox>.from(json.decode(str).map((x) => CBrainBox.fromJson(x)));

String modelUserToJson(List<CBrainBox> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CBrainBox {
  String id;
  String status;
  String theme_name;
  String project_name;
  String department_name;
  String approver_type;
  String approver_name;
  String user_name;
  String created_date;
  String email_id;
  String description;
  String action_taken;
  String title;
  String idea_no;
  String created_date_time;
  String action_taken_datetime;
  String is_anonymous;



  CBrainBox({
    required this.id,
    required this.status,
    required this.theme_name,
    required this.project_name,
    required this.department_name,
    required this.approver_type,
    required this.approver_name,
    required this.user_name,
    required this.created_date,
    required this.email_id,
    required this.description,
    required this.action_taken,
    required this.title,
    required this.idea_no,
    required this.created_date_time,
    required this.action_taken_datetime,
    required this.is_anonymous

  });

  factory CBrainBox.fromJson(Map<dynamic, dynamic> json) => CBrainBox(
    id: json["id"],
    status: json["status"],
    theme_name: json["theme_name"],
    project_name: json["project_name"],
    department_name: json["department_name"],
    approver_type: json["approver_type"],
    approver_name: json["approver_name"],
    user_name: json["user_name"],
    created_date: json["created_date"],
    email_id: json["email_id"],
    description: json["description"],
    action_taken: json["action_taken"],
    title: json["title"],
    idea_no: json["idea_no"],
    created_date_time: json["created_date_time"],
    action_taken_datetime: json["action_taken_datetime"],
    is_anonymous: json["is_anonymous"],


  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "theme_name": theme_name,
    "project_name": project_name,
    "department_name": department_name,
    "approver_type": approver_type,
    "approver_name": approver_name,
    "user_name": user_name,
    "created_date": created_date,
    "email_id": email_id,
    "description": description,
    "action_taken": action_taken,
    "title": title,
    "idea_no": idea_no,
    "created_date_time": created_date_time,
    "action_taken_datetime": action_taken_datetime,
    "is_anonymous": is_anonymous,


  };
}
