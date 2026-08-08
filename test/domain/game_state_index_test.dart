import 'package:flutter_test/flutter_test.dart';
import 'package:founder_os/domain/entities/game_state.dart';
import 'package:founder_os/domain/entities/models.dart';
import 'package:founder_os/domain/entities/operations_models.dart';

void main() {
  test('derived indexes preserve immutable lookup behavior', () {
    final employee = GameState.initial().candidates.first.toEmployee();
    final state = GameState.initial().copyWith(
      employees: <Employee>[employee],
      employeeAssignments: <EmployeeAssignment>[
        EmployeeAssignment(
          employeeId: employee.id,
          productId: 'fixture_product',
          assignedAtMinutes: 0,
          allocationPercent: 60,
        ),
      ],
    );

    expect(identical(state.employeeById(employee.id), employee), isTrue);
    expect(state.assignmentsForEmployee(employee.id), hasLength(1));
    expect(
      identical(
        state.employeesForProduct('fixture_product'),
        state.employeesForProduct('fixture_product'),
      ),
      isTrue,
    );
    expect(
      state.employeeAllocationForProduct(employee.id, 'fixture_product'),
      100,
    );

    final changed = state.copyWith(
      employeeAssignments: const <EmployeeAssignment>[],
    );
    expect(changed.assignmentsForEmployee(employee.id), isEmpty);
    expect(state.assignmentsForEmployee(employee.id), hasLength(1));
  });
}
