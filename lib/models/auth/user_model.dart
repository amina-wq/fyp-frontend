class UserModel {
  final String userId;
  final String name;
  final String email;
  final bool isActive;
  final String? fcmToken;
  final List<int> notificationDaysBefore;
  final String accountType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.isActive,
    this.fcmToken,
    required this.notificationDaysBefore,
    required this.accountType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      fcmToken: json['fcm_token'] as String?,
      notificationDaysBefore: List<int>.from(
        json['notification_days_before'] as List,
      ),
      accountType: json['account_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'is_active': isActive,
      'fcm_token': fcmToken,
      'notification_days_before': notificationDaysBefore,
      'account_type': accountType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
