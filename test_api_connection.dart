// Test file to verify FastAPI server connection
// Run this in your Flutter app to test the API connection

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> testAPIConnection() async {
  try {
    // Test basic connection to FastAPI server
    final response = await http.get(
      Uri.parse('http://192.168.100.5:8000/'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('API Connection Test:');
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 200) {
      print('✅ FastAPI server is running and accessible');
    } else {
      print('⚠️ FastAPI server responded with status: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Failed to connect to FastAPI server: $e');
    print('Make sure your FastAPI server is running on 192.168.100.5:8000');
  }
}

// Test the profile update endpoint specifically
Future<void> testProfileUpdateEndpoint() async {
  try {
    final testData = {
      'userId': 'test-user-id',
      'address': '123 Test Street',
      'idDocumentUrl': 'https://example.com/test-id.jpg',
      'role': 'Rep',
      'verificationStatus': 'pending',
    };
    
    final testUserId = 'test-user-id';
    final response = await http.patch(
      Uri.parse('http://192.168.100.5:8000/users/$testUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer test-token',
      },
      body: jsonEncode(testData),
    ).timeout(const Duration(seconds: 10));
    
    print('Profile Update Test:');
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Profile update endpoint is working');
    } else {
      print('⚠️ Profile update endpoint responded with status: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Failed to test profile update endpoint: $e');
  }
}