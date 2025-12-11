class UserProfile {
  final String name;
  final String languageCode; // 'en', 'ms', 'zh'
  final bool needsBigText;
  final bool highContrast;
  final Map<String, String> mockData;
  final String? notificationMsg; // Proactive notification message

  UserProfile({
    required this.name,
    required this.languageCode,
    this.needsBigText = false,
    this.highContrast = false,
    required this.mockData,
    this.notificationMsg,
  });

  // Static Mock Profiles
  static final List<UserProfile> mockProfiles = [
    // Profile 1: Uncle Tan (Default)
    UserProfile(
      name: 'Uncle Tan',
      languageCode: 'en',
      needsBigText: false,
      highContrast: false,
      notificationMsg: 'Driving License expiring in 5 days!',
      mockData: {
        'fullName': 'Tan Ah Meng',
        'icNumber': '800101-10-5678',
        'phoneNumber': '+60 12-345 6789',
        'bankAccount': 'Maybank - 1234567890',
        'aidType': 'STR (Sumbangan Tunai Rahmah)',
        'strStatus': 'Eligible',
        'amount': 'RM500',
        'address': '123, Jalan Pudu, KL',
      },
    ),

    // Profile 2: Grandma Lin (The Demo Star - Chinese, Big Text)
    UserProfile(
      name: 'Grandma Lin',
      languageCode: 'zh',
      needsBigText: true,
      highContrast: false,
      notificationMsg: '您的身份证即将过期，请更新！',
      mockData: {
        'fullName': 'Lin Mei Hua',
        'icNumber': '650515-08-1234',
        'phoneNumber': '+60 16-789 0123',
        'bankAccount': 'CIMB Bank - 9876543210',
        'aidType': 'STR (Sumbangan Tunai Rahmah)',
        'strStatus': 'Approved',
        'amount': 'RM800',
        'address': '456, Jalan Imbi, KL',
      },
    ),

    // Profile 3: Uncle Muthu (Visual Aid - High Contrast)
    UserProfile(
      name: 'Uncle Muthu',
      languageCode: 'en',
      needsBigText: false,
      highContrast: true,
      notificationMsg: null, // No notifications
      mockData: {
        'fullName': 'Muthu Kumar',
        'icNumber': '720820-14-3456',
        'phoneNumber': '+60 19-234 5678',
        'bankAccount': 'RHB Bank - 5555666677',
        'aidType': 'STR (Sumbangan Tunai Rahmah)',
        'strStatus': 'Pending',
        'amount': 'RM600',
        'address': '789, Jalan Sentul, KL',
      },
    ),

    // Profile 4: Ali (Guardian - Son)
    UserProfile(
      name: 'Ali',
      languageCode: 'en',
      needsBigText: false,
      highContrast: false,
      notificationMsg: null,
      mockData: {
        'fullName': 'Ali bin Abdullah',
        'icNumber': '900315-10-1234',
        'phoneNumber': '+60 12-987 6543',
        'bankAccount': 'Public Bank - 1122334455',
        'aidType': 'STR (Sumbangan Tunai Rahmah)',
        'strStatus': 'Eligible',
        'amount': 'RM400',
        'address': '321, Jalan Raja Laut, KL',
      },
    ),
  ];

  // Helper getters for quick access
  String get fullName => mockData['fullName'] ?? '';
  String get icNumber => mockData['icNumber'] ?? '';
  String get phoneNumber => mockData['phoneNumber'] ?? '';
  String get bankAccount => mockData['bankAccount'] ?? '';
  String get aidType => mockData['aidType'] ?? '';
  String get strStatus => mockData['strStatus'] ?? '';
  String get amount => mockData['amount'] ?? '';
  String get address => mockData['address'] ?? '';
}

