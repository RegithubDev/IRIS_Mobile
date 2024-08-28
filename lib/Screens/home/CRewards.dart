import 'dart:convert';

List<CRewards> modelUserFromJson(String str) =>
    List<CRewards>.from(json.decode(str).map((x) => CRewards.fromJson(x)));

String modelUserToJson(List<CRewards> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CRewards {
  String reward_points;
  String user_name;

  CRewards({required this.reward_points, required this.user_name});

  factory CRewards.fromJson(Map<dynamic, dynamic> json) => CRewards(
        reward_points: json["reward_points"],
        user_name: json["user_name"],
      );

  Map<String, dynamic> toJson() => {
        "reward_points": reward_points,
        "user_name": user_name,
      };
}
