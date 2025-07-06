class ProfilModel {
  final int id;
  final String businessType;
  final String businessName;
  final String? stripeAccountId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Champs utilisateur (owner)
  final String ownerId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final bool emailVerified;
  final List<String> phoneNumbers;
  final int createdTimestamp;
  final bool enabled;
  final bool totp;
  final List<String> disableableCredentialTypes;
  final List<String> requiredActions;
  final int notBefore;

  ProfilModel({
    required this.id,
    required this.businessType,
    required this.businessName,
    this.stripeAccountId,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailVerified,
    required this.phoneNumbers,
    required this.createdTimestamp,
    required this.enabled,
    required this.totp,
    required this.disableableCredentialTypes,
    required this.requiredActions,
    required this.notBefore,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'];
    return ProfilModel(
      id: json['id'],
      businessType: json['business_type'],
      businessName: json['business_name'],
      stripeAccountId: json['stripe_account_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      ownerId: owner['id'],
      username: owner['username'],
      firstName: owner['firstName'],
      lastName: owner['lastName'],
      email: owner['email'],
      emailVerified: owner['emailVerified'],
      phoneNumbers: List<String>.from(owner['attributes']['phoneNumber']),
      createdTimestamp: owner['createdTimestamp'],
      enabled: owner['enabled'],
      totp: owner['totp'],
      disableableCredentialTypes:
          List<String>.from(owner['disableableCredentialTypes']),
      requiredActions: List<String>.from(owner['requiredActions']),
      notBefore: owner['notBefore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_type': businessType,
      'business_name': businessName,
      'stripe_account_id': stripeAccountId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'owner': {
        'id': ownerId,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'emailVerified': emailVerified,
        'attributes': {
          'phoneNumber': phoneNumbers,
        },
        'createdTimestamp': createdTimestamp,
        'enabled': enabled,
        'totp': totp,
        'disableableCredentialTypes': disableableCredentialTypes,
        'requiredActions': requiredActions,
        'notBefore': notBefore,
      },
    };
  }
}
