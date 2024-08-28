class IncidentRequest {
  String project_code;
  String department_code;
  String incident_type;
  String incident_category;
  String description;
  String approver_code;
  String email_id;
  String email;
  String approver_type;
  List<String> m_image_list;
  List<String> m_file_name_list;
  String person_location;
  String project_name;
  String incident_name;
  String created_by;

  IncidentRequest(
      this.project_code,
      this.department_code,
      this.incident_type,
      this.incident_category,
      this.description,
      this.approver_code,
      this.email_id,
      this.email,
      this.approver_type,
      this.m_image_list,
      this.m_file_name_list,
      this.person_location,
      this.project_name,
      this.incident_name,
      this.created_by
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        "project_code": project_code,
        "department_code": department_code,
        "incident_type": incident_type,
        "incident_category": incident_category,
        "description": description,
        "approver_code": approver_code,
        "email_id": email_id,
        "email": email,
        "approver_type": approver_type,
        "image_list": m_image_list,
        "filenameAndExtList": m_file_name_list,
        "person_location": person_location,
        "project_name": project_name,
        "incident_name": incident_name,
        "created_by": created_by
      };
}
