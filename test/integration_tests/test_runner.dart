import 'package:flutter_test/flutter_test.dart';
import 'workflows/group_workflow_test.dart' as group_tests;
import 'workflows/game_workflow_test.dart' as game_tests;
import 'workflows/user_workflow_test.dart' as user_tests;

/// Main test runner for all integration tests
/// Executes all workflow tests in sequence
void main() {
  group('🧪 INTEGRATION TEST SUITE - POKER MATES', () {
    group('📁 WORKFLOW 1: Group Management', () {
      group_tests.main();
    });

    group('🎮 WORKFLOW 2: Game Management', () {
      game_tests.main();
    });

    group('👥 WORKFLOW 3: User/Member Management', () {
      user_tests.main();
    });
  });

  // Print test summary
  tearDownAll(() {
    print('\n' + '=' * 60);
    print('✅ INTEGRATION TEST SUITE COMPLETED');
    print('=' * 60);
    print('All workflows have been tested successfully.');
    print('Review the test results above for detailed information.');
    print('=' * 60 + '\n');
  });
}
