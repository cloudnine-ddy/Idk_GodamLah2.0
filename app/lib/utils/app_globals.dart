/// Global application state for demo purposes
class AppGlobals {
  /// Flag to indicate if there's a pending guardian authorization request
  static bool hasPendingAuth = false;
  
  /// The name of the selected guardian (for demo purposes)
  static String selectedGuardianName = '';
  
  /// The name of the person who sent the auth request (for receiver flow)
  static String pendingAuthName = '';
  
  /// Reset all global state
  static void reset() {
    hasPendingAuth = false;
    selectedGuardianName = '';
    pendingAuthName = '';
  }
}

