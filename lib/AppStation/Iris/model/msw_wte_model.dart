class MswWteModel {

  String rdfReceipt;
  String rdfCombusted;
  String streamGeneration;
  String powerGeneration;
  String powerExport;
  String auxillaryConsumption;
  String powerGenerationCapacity;
  String plantLoadFactor;
  String bottomAsh;
  String flyAsh;
  String totalAsh;
  String selectedDate;
  String location;
  String siteName;
  String comments;

  MswWteModel(
      {required this.rdfReceipt, required this.rdfCombusted, required this.streamGeneration, required this.powerGeneration, required this.powerExport, required this.auxillaryConsumption, required this.powerGenerationCapacity, required this.plantLoadFactor, required this.bottomAsh, required this.flyAsh, required this.totalAsh, required this.siteName, required this.location, required this.selectedDate, required this.comments });
}