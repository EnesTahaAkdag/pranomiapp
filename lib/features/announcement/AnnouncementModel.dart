// lib/features/announcement/AnnouncementModel.dart

class AnnouncementModel {
  final int id;
  final DateTime createdAt;
  final String viewType;
  final String announcementType;
  final String title;
  final String description;

  AnnouncementModel({
    required this.id,
    required this.createdAt,
    required this.viewType,
    required this.announcementType,
    required this.title,
    required this.description,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['Id'] as int,
      // Parse ISO8601 string to DateTime
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      viewType: json['ViewType'] as String,
      announcementType: json['AnnouncementType'] as String,      title: json['Title'] as String,
      description: json['Description'] as String,
    );
  }

  // Optional: Add a toJson method if you need to send this model to an API
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CreatedAt': createdAt.toIso8601String(),
      'ViewType': viewType,
      'AnnouncementType': announcementType,
      'Title': title,
      'Description': description,
    };
  }
}
