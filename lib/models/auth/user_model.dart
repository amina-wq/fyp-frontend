// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: User profile data model.
// First Written on: Wednesday, 03-Jun-2026
// Edited on: Sunday, 12-Jul-2026
class UserModel {
  final String userId;
  final String name;
  final String email;
  final bool isActive;
  final String role;
  final String? fcmToken;
  final List<int> notificationDaysBefore;
  final bool expiryNotificationsEnabled;
  final String themeMode;
  final String accountType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.isActive,
    required this.role,
    this.fcmToken,
    required this.notificationDaysBefore,
    required this.expiryNotificationsEnabled,
    required this.themeMode,
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
      role: json['role'] as String? ?? 'user',
      fcmToken: json['fcm_token'] as String?,
      notificationDaysBefore: List<int>.from(
        json['notification_days_before'] as List? ?? const [5, 1, 0],
      ),
      expiryNotificationsEnabled:
          json['expiry_notifications_enabled'] as bool? ?? true,
      themeMode: json['theme_mode'] as String? ?? 'system',
      accountType: json['account_type'] as String? ?? 'personal',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'is_active': isActive,
      'role': role,
      'fcm_token': fcmToken,
      'notification_days_before': notificationDaysBefore,
      'expiry_notifications_enabled': expiryNotificationsEnabled,
      'theme_mode': themeMode,
      'account_type': accountType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
