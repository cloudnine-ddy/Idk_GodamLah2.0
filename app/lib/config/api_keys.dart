/// API Keys Configuration
/// 
/// IMPORTANT: This file contains sensitive API keys and should NOT be committed to git.
/// Add this file to .gitignore to keep your keys secure.
/// 
/// To get your Gemini API key:
/// 1. Go to https://aistudio.google.com/app/apikey
/// 2. Sign in with your Google account
/// 3. Click "Create API Key"
/// 4. Copy the key and paste it below
/// 
/// Note: The app uses gemini-1.5-flash (fast) or gemini-1.5-pro (better quality)
/// 
/// For production, consider using environment variables or secure storage.

class ApiKeys {
  // Replace 'YOUR_GEMINI_API_KEY_HERE' with your actual API key from Google AI Studio
  static const String geminiApiKey = 'AIzaSyALDxls4H7ilYj-yY8shpa3pr3-9ATJEkg';
  
  // Check if Gemini API key is configured
  static bool get isConfigured => geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && geminiApiKey.isNotEmpty;
}

