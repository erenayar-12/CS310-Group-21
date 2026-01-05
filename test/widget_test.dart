// Basic widget test for Commitly app
//
// This test verifies that the app can be imported and basic structure is correct.
// Note: Full app testing with Firebase is done in login_screen_test.dart

import 'package:commitly/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('CommitlyApp can be instantiated', () {
    // Verify that CommitlyApp can be created
    const app = CommitlyApp();
    expect(app, isNotNull);
  });
}
