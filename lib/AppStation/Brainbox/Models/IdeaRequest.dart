
class IdeaRequest {
  String title;
  String theme;
  String description;
  String sbu_code;
  String project_code;
  String department_code;
  String is_anonymous;
  List<String> image_list;
  List<String> m_file_name_list;
  String approver_code;
  String approver_type;
  String email;
  String email_id;
  String created_by;
  String user_name;
  String device_type;
  String device_type_no;

  IdeaRequest(
      this.title,
      this.theme,
      this.description,
      this.sbu_code,
      this.project_code,
      this.department_code,
      this.is_anonymous,
      this.image_list,
      this.m_file_name_list,
      this.approver_code,
      this.approver_type,
      this.email,
      this.email_id,
      this.created_by,
      this.user_name,
      this.device_type,
      this.device_type_no,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    "title": title,
    "theme": theme,
    "description": description,
    "sbu_code": sbu_code,
    "project_code": project_code,
    "department_code": department_code,
    "is_anonymous": is_anonymous,
    "image_list": image_list,
    "filenameAndExtList": m_file_name_list,
    "approver_code": approver_code,
    "approver_type": approver_type,
    "email": email,
    "email_id": email_id,
    "created_by": created_by,
    "user_name": user_name,
    "device_type": device_type,
    "device_type_no": device_type_no,


  };
}
