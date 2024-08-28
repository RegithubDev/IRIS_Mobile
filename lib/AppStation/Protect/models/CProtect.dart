import 'dart:convert';

List<CProtect> modelUserFromJson(String str) =>
    List<CProtect>.from(json.decode(str).map((x) => CProtect.fromJson(x)));

String modelUserToJson(List<CProtect> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CProtect {
  String document_code;
  String status;
  String incident_type;
  String project_name;
  String department_name;
  String approver_type;
  String approver_name;
  String user_name;
  String created_date;
  String email_id;
  String risk_type;
  String incident_category;
  String description;
  String action_taken;

  CProtect({
    required this.document_code,
    required this.status,
    required this.incident_type,
    required this.project_name,
    required this.department_name,
    required this.approver_type,
    required this.approver_name,
    required this.user_name,
    required this.created_date,
    required this.email_id,
    required this.risk_type,
    required this.incident_category,
    required this.description,
    required this.action_taken,
  });

  factory CProtect.fromJson(Map<dynamic, dynamic> json) => CProtect(
        document_code: json["document_code"],
        status: json["status"],
        incident_type: json["incident_type"],
        project_name: json["project_name"],
        department_name: json["department_name"],
        approver_type: json["approver_type"],
        approver_name: json["approver_name"],
        user_name: json["user_name"],
        created_date: json["created_date"],
        email_id: json["email_id"],
        risk_type: json["risk_type"],
        incident_category: json["incident_category"],
        description: json["description"],
        action_taken: json["action_taken"],
      );

  Map<String, dynamic> toJson() => {
        "document_code": document_code,
        "status": status,
        "incident_type": incident_type,
        "project_name": project_name,
        "department_name": department_name,
        "approver_type": approver_type,
        "approver_name": approver_name,
        "user_name": user_name,
        "created_date": created_date,
        "email_id": email_id,
        "risk_type": risk_type,
        "incident_category": incident_category,
        "description": description,
        "action_taken": action_taken,
      };
}
