class UserModel {
  final String? displayName;
  final String? email;
  final bool isEmailVerified;
  final bool isAnonymous;
  final UserMetadataModel metadata;
  final String? phoneNumber;
  final String? photoURL;
  final List<UserInfoModel> providerData;
  final String? refreshToken;
  final String? tenantId;
  final String uid;

  UserModel({
    this.displayName,
    this.email,
    required this.isEmailVerified,
    required this.isAnonymous,
    required this.metadata,
    this.phoneNumber,
    this.photoURL,
    required this.providerData,
    this.refreshToken,
    this.tenantId,
    required this.uid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      displayName: json['displayName'],
      email: json['email'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      isAnonymous: json['isAnonymous'] ?? false,
      metadata: UserMetadataModel.fromJson(json['metadata']),
      phoneNumber: json['phoneNumber'],
      photoURL: json['photoURL'],
      providerData:
          (json['providerData'] as List<dynamic>)
              .map((e) => UserInfoModel.fromJson(e))
              .toList(),
      refreshToken: json['refreshToken'],
      tenantId: json['tenantId'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'isAnonymous': isAnonymous,
      'metadata': metadata.toJson(),
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'providerData': providerData.map((e) => e.toJson()).toList(),
      'refreshToken': refreshToken,
      'tenantId': tenantId,
      'uid': uid,
    };
  }
}

class UserMetadataModel {
  final String creationTime;
  final String lastSignInTime;

  UserMetadataModel({required this.creationTime, required this.lastSignInTime});

  factory UserMetadataModel.fromJson(Map<String, dynamic> json) {
    return UserMetadataModel(
      creationTime: json['creationTime'],
      lastSignInTime: json['lastSignInTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'creationTime': creationTime, 'lastSignInTime': lastSignInTime};
  }
}

class UserInfoModel {
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final String providerId;
  final String uid;

  UserInfoModel({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    required this.providerId,
    required this.uid,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      displayName: json['displayName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoURL: json['photoURL'],
      providerId: json['providerId'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'providerId': providerId,
      'uid': uid,
    };
  }
}
