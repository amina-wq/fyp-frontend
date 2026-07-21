// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Access and refresh token data model.
// First Written on: Wednesday, 03-Jun-2026
// Edited on: Sunday, 12-Jul-2026
class TokenModel {
  final String accessToken;
  final String refreshToken;

  const TokenModel({required this.accessToken, required this.refreshToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
