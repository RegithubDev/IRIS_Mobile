class MswWteCollectRequestModel {
  String? sbuCode;
  String? date;
  String? siteId;
  String? createdBy;
  String? quantity;
  String? comments;
  String? rdfReceipt;
  String? rdfCombusted;
  String? streamGeneration;
  String? powerGeneration;
  String? powerExport;
  String? auxillaryConsumption;
  String? powerGenerationCapacity;
  String? plantLoadFactor;
  String? bottomAsh;
  String? flyAsh;
  String? totalAsh;

  MswWteCollectRequestModel(
      {this.sbuCode,
        this.date,
        this.siteId,
        this.createdBy,
        this.quantity,
        this.comments,
      this.rdfReceipt,
      this.rdfCombusted,
      this.streamGeneration,
      this.plantLoadFactor,
      this.auxillaryConsumption,
      this.powerGenerationCapacity,
      this.powerExport,
      this.powerGeneration,
      this.bottomAsh,
      this.flyAsh,
      this.totalAsh});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "sbu_code": "MSW",
      "date": date,
      "site": siteId,
      "created_by": createdBy,
      "comments": comments,
      "plant_load_factor": plantLoadFactor,
      "plant_generation_capacity": powerGeneration,
      "bottom_ash": bottomAsh,
      "fly_ash": flyAsh,
      "rdf_receipt": rdfReceipt,
      "rdf_combusted": rdfCombusted,
      "ash_generated": totalAsh,
      "steam_generation": streamGeneration,
      "power_produced": powerGeneration,
      "power_export": powerExport,
      "auxiliary_consumption": auxillaryConsumption,
      "quantity_measure_rdf_receipt": "MT",
      "quantity_measure_rdf_combusted": "MT",
      "quantity_measure_ash_generated": "MT",
      "quantity_measure_steam_generation": "TPD",
      "quantity_measure_power_produced": "MW",
      "quantity_measure_power_export": "MW",
      "quantity_measure_auxiliary_consumption": "MW"
    };
    return map;
  }
}