class MswPNDRequestModel {
  String? sbu_code;
  String? date;
  String? site;
  String? created_by;
  String? comments;
  String? rdf;
  String? compost;
  String? recyclables;
  String? inserts;
  String? vendor_name_rdf;
  String? vendor_name_compost;
  String? vendor_name_recyclables;
  String? vendor_name_inserts;
  String? total_waste;
  String? total_rdf;
  String? total_compost;
  String? total_inerts;
  String? total_recylables;

  MswPNDRequestModel(
      {
        this.sbu_code,
        this.date,
        this.site,
        this.created_by,
        this.comments,
        this.rdf,
        this.compost,
        this.recyclables,
        this.inserts,
        this.vendor_name_rdf,
        this.vendor_name_compost,
        this.vendor_name_recyclables,
        this.vendor_name_inserts,
        this.total_waste,
        this.total_rdf,
        this.total_compost,
        this.total_inerts,
        this.total_recylables
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": "MSW",
      "date": date,
      "site": site,
      "created_by": created_by,
      "comments": comments,
      "rdf": rdf,
      "compost": compost,
      "recyclables": recyclables,
      "inserts": inserts,
      "vendor_name_rdf": vendor_name_rdf,
      "vendor_name_compost": vendor_name_compost,
      "vendor_name_recyclables": vendor_name_recyclables,
      "vendor_name_inserts": vendor_name_inserts,
      "total_waste": total_waste,
      "total_rdf": total_rdf,
      "total_compost": total_compost,
      "total_inerts": total_inerts,
      "total_recylables": total_recylables,

    };
    return map;
  }
}