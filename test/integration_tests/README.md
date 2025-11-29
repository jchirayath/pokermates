# Integration Tests - Poker Mates

This directory contains comprehensive integration tests for the Poker Mates application workflows.

## 📋 Test Coverage

### Workflow 1: Group Management
- ✅ Create Group
- ✅ Modify Group (name, description)
- ✅ Delete Group
- ✅ Validation (missing fields, invalid data)
- ✅ Cascade deletion of members

**Test File**: `workflows/group_workflow_test.dart`

### Workflow 2: Game Management
- ✅ Create Game within Group
- ✅ Modify Game (schedule, buyin, status)
- ✅ Delete Game
- ✅ Status transitions (scheduled → in_progress → completed)
- ✅ Game notes management
- ✅ Cascade deletion of participants

**Test File**: `workflows/game_workflow_test.dart`

### Workflow 3: User/Member Management
- ✅ Add User to Group
- ✅ Modify User Role (member ↔ admin)
- ✅ Remove User from Group
- ✅ Duplicate prevention
- ✅ Member access verification
- ✅ Multiple members management

**Test File**: `workflows/user_workflow_test.dart`

## 🚀 Running Tests

### Run All Integration Tests
```bash
flutter test test/integration_tests/test_runner.dart --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Run Individual Workflow Tests

**Group Workflow**:
```bash
flutter test test/integration_tests/workflows/group_workflow_test.dart --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

**Game Workflow**:
```bash
flutter test test/integration_tests/workflows/game_workflow_test.dart --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

**User Workflow**:
```bash
flutter test test/integration_tests/workflows/user_workflow_test.dart --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## 📝 Test Structure

```
test/integration_tests/
├── README.md                           # This file
├── test_runner.dart                    # Main test orchestrator
├── test_helpers/
│   └── supabase_test_helper.dart      # Utility functions for tests
└── workflows/
    ├── group_workflow_test.dart        # Group CRUD tests
    ├── game_workflow_test.dart         # Game CRUD tests
    └── user_workflow_test.dart         # User/Member CRUD tests
```

## 🔧 Test Helper Functions

The `SupabaseTestHelper` class provides utility methods:

- `createTestUserProfile()` - Creates test user profiles
- `createTestGroup()` - Creates test groups
- `createTestGame()` - Creates test games
- `addGroupMember()` - Adds members to groups
- `cleanupTestGroup()` - Removes test data after tests
- `recordExists()` - Verifies record existence
- `getRecordCount()` - Counts records matching criteria
- `waitForCondition()` - Waits for async conditions

## ⚙️ Configuration

### Environment Variables Required:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anonymous key

### Setup Before Running:
1. Ensure Supabase project is created and configured
2. Database migrations are applied
3. RLS policies are enabled
4. Test user authentication is configured

## ✅ Test Validation

Each workflow test validates:
1. **Successful Operations** - CRUD operations work as expected
2. **Data Integrity** - Data is correctly stored and retrieved
3. **Validation Rules** - Required fields and constraints are enforced
4. **Error Handling** - Invalid operations fail appropriately
5. **Cascade Operations** - Related data is properly managed
6. **Edge Cases** - Boundary conditions and special scenarios

## 🎯 Success Criteria

Tests pass when:
- ✅ All CRUD operations complete successfully
- ✅ Database constraints are properly enforced
- ✅ RLS policies allow/deny access correctly
- ✅ Cascade deletions work as expected
- ✅ Data integrity is maintained
- ✅ Error handling works properly

## 🐛 Debugging Failed Tests

1. **Check Supabase Configuration**
   - Verify URL and keys are correct
   - Ensure database is accessible

2. **Review Migration Status**
   - Confirm all migrations are applied
   - Check table structures match expectations

3. **Inspect RLS Policies**
   - Verify policies allow test operations
   - Check authentication context

4. **Test Data Cleanup**
   - Ensure previous test data is cleaned up
   - Check for conflicts with existing data

## 📊 Test Reports

After running tests, review:
- Test execution time
- Pass/fail status for each test
- Error messages for failed tests
- Database state after tests

## 🔄 Continuous Integration

To integrate with CI/CD:

```yaml
# Example GitHub Actions workflow
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter test test/integration_tests/ --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

## 📚 Additional Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Supabase Testing Guide](https://supabase.com/docs/guides/testing)
- [Integration Testing Best Practices](https://flutter.dev/docs/testing/integration-tests)