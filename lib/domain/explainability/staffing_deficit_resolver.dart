import '../catalog/game_catalog.dart';
import '../entities/game_state.dart';
import '../entities/models.dart';
import '../entities/v9_models.dart';

abstract final class StaffingDeficitResolver {
  static List<SpecialistDeficit> forProduct(GameState state, Product product) {
    final phase = state.developmentPhaseFor(product);
    final team = state.employeesForProduct(product.id);
    final deficits = <SpecialistDeficit>[];

    final roleRequirements =
        state.roleRequirementsFor(product).toList(growable: false)
          ..sort((a, b) => a.role.index.compareTo(b.role.index));
    for (final requirement in roleRequirements) {
      final matching = team
          .where((employee) => employee.role == requirement.role)
          .toList(growable: false);
      final missing = requirement.minimumCount - matching.length;
      if (missing <= 0) continue;
      final languageId = _languageForRole(product, requirement.role);
      final technologyId = _technologyForRole(product, requirement.role);
      deficits.add(
        SpecialistDeficit(
          roleId: requirement.role.name,
          roleName: _roleName(requirement.role),
          languageId: languageId,
          languageName: languageId == null
              ? null
              : GameCatalog.languageById(languageId).name,
          technologyId: technologyId,
          technologyName: technologyId == null
              ? null
              : GameCatalog.technologyById(technologyId).name,
          minimumSkill: phase.criticalRoles.contains(requirement.role)
              ? 70
              : 55,
          missingCount: missing,
          stageName: phase.name,
          effect: phase.criticalRoles.contains(requirement.role)
              ? 'Блокирует или резко замедляет стадию «${phase.name}».'
              : 'Снижает coverage и общую эффективность разработки.',
          solutions: <String>[
            'Нанять ${_roleName(requirement.role)}.',
            'Снять подходящего сотрудника с другого проекта.',
            if (languageId != null)
              'Убрать ${GameCatalog.languageById(languageId).name} или сменить framework.',
            if (technologyId != null)
              'Убрать ${GameCatalog.technologyById(technologyId).name}.',
            'Упростить roadmap или архитектуру.',
          ],
        ),
      );
    }

    final selectedLanguages = product.languageIds.toList()..sort();
    for (final languageId in selectedLanguages) {
      final covered = team.any(
        (employee) => employee.languageIds.contains(languageId),
      );
      if (covered) continue;
      final role = _defaultRoleForLanguage(languageId);
      deficits.add(
        SpecialistDeficit(
          roleId: role.name,
          roleName: _roleName(role),
          languageId: languageId,
          languageName: GameCatalog.languageById(languageId).name,
          technologyId: null,
          technologyName: null,
          minimumSkill: 60,
          missingCount: 1,
          stageName: phase.name,
          effect: 'Язык выбран, но код на нём некому поддерживать.',
          solutions: <String>[
            'Нанять специалиста со знанием ${GameCatalog.languageById(languageId).name}.',
            'Снять сотрудника с другого проекта.',
            'Убрать язык.',
            'Сменить framework.',
          ],
        ),
      );
    }

    deficits.sort((a, b) {
      final stage = b.minimumSkill.compareTo(a.minimumSkill);
      if (stage != 0) return stage;
      final role = a.roleId.compareTo(b.roleId);
      if (role != 0) return role;
      return (a.languageId ?? '').compareTo(b.languageId ?? '');
    });
    return List<SpecialistDeficit>.unmodifiable(deficits);
  }

  static String? _languageForRole(Product product, EmployeeRole role) {
    final sorted = product.languageIds.toList()..sort();
    for (final id in sorted) {
      if (_defaultRoleForLanguage(id) == role) return id;
    }
    return sorted.isEmpty ? null : sorted.first;
  }

  static String? _technologyForRole(Product product, EmployeeRole role) {
    final technologies = product.technologyIds.toList()..sort();
    if (role == EmployeeRole.devOps && technologies.contains('kubernetes')) {
      return 'kubernetes';
    }
    if (role == EmployeeRole.security && technologies.contains('hsm')) {
      return 'hsm';
    }
    if (role == EmployeeRole.aiMl && technologies.contains('vector_db')) {
      return 'vector_db';
    }
    return null;
  }

  static EmployeeRole _defaultRoleForLanguage(String id) => switch (id) {
    'html_css' || 'javascript' || 'typescript' => EmployeeRole.frontend,
    'dart' || 'swift' || 'kotlin' => EmployeeRole.mobile,
    'python' => EmployeeRole.aiMl,
    'go' || 'java' || 'php' => EmployeeRole.backend,
    'rust' || 'cpp' => EmployeeRole.security,
    _ => EmployeeRole.backend,
  };

  static String _roleName(EmployeeRole role) => switch (role) {
    EmployeeRole.productManager => 'Product Manager',
    EmployeeRole.frontend => 'Frontend-разработчик',
    EmployeeRole.backend => 'Backend-разработчик',
    EmployeeRole.mobile => 'Mobile-разработчик',
    EmployeeRole.aiMl => 'AI/ML-инженер',
    EmployeeRole.designer => 'Product Designer',
    EmployeeRole.qa => 'QA-инженер',
    EmployeeRole.devOps => 'DevOps-инженер',
    EmployeeRole.security => 'Security Engineer',
    EmployeeRole.growth => 'Growth Manager',
    EmployeeRole.sales => 'Sales Manager',
    EmployeeRole.support => 'Support Engineer',
  };
}
