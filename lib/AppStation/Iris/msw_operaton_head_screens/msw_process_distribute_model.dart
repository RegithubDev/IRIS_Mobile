class MswProcessDistributeModel {
  String totalWaste;
  String totalCompost;
  String totalRDF;
  String totalRecyclable;
  String totalInerts;
  String vendorNameCompost;
  String vendorNameRDF;
  String vendorNameRecyclable;
  String vendorNameInerts;
  String compost;
  String rdf;
  String rdfToWte;
  String recyclable;
  String recyclableToRecycleUnit;
  String inerts;
  String location;
  String siteName;
  String selectedDate;
  String comments;

  MswProcessDistributeModel(
      {
        required this.totalWaste,
        required this.totalCompost,
        required this.totalRDF,
        required this.vendorNameCompost,
        required this.totalRecyclable,
        required this.totalInerts,
        required this.vendorNameRDF,
        required this.vendorNameRecyclable,
        required this.vendorNameInerts,
        required this.compost,
      required this.rdf,
      required this.rdfToWte,
      required this.recyclable,
      required this.recyclableToRecycleUnit,
      required this.inerts,
      required this.location,
      required this.siteName,
      required this.selectedDate,
      required this.comments});
}
