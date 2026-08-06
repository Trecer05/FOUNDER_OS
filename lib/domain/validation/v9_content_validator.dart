import '../catalog/v9_content_catalog.dart';
import '../entities/v9_models.dart';

abstract final class V9ContentValidator {
  static List<ContentValidationIssue> validate() {
    final issues = <ContentValidationIssue>[];
    _duplicates(
      V9ContentCatalog.hostingPlans.map((item) => item.id),
      'hosting',
      issues,
    );
    _duplicates(
      V9ContentCatalog.glossary.map((item) => item.id),
      'glossary',
      issues,
    );
    for (final plan in V9ContentCatalog.hostingPlans) {
      if (plan.name.trim().isEmpty || plan.description.trim().isEmpty) {
        issues.add(
          ContentValidationIssue(
            code: 'empty_hosting_text',
            message: '${plan.id}: пустое название или описание.',
          ),
        );
      }
      if (plan.kind != HostingKind.owned &&
          (plan.computeUnits <= 0 ||
              plan.monthlyCost < 0 ||
              plan.sla <= 0 ||
              plan.sla > 1)) {
        issues.add(
          ContentValidationIssue(
            code: 'hosting_range',
            message: '${plan.id}: ошибочный compute/cost/SLA.',
          ),
        );
      }
      if (plan.strengths.isEmpty ||
          plan.weaknesses.isEmpty ||
          plan.risks.isEmpty) {
        issues.add(
          ContentValidationIssue(
            code: 'hosting_explainability',
            message: '${plan.id}: нет плюсов, минусов или рисков.',
          ),
        );
      }
    }
    for (final entry in V9ContentCatalog.glossary) {
      if (entry.term.trim().isEmpty ||
          entry.shortExplanation.trim().isEmpty ||
          entry.detailedExplanation.trim().isEmpty ||
          entry.gameExample.trim().isEmpty ||
          entry.usedIn.isEmpty ||
          entry.whyImportant.trim().isEmpty) {
        issues.add(
          ContentValidationIssue(
            code: 'glossary_incomplete',
            message: '${entry.id}: термин заполнен не полностью.',
          ),
        );
      }
    }
    return List<ContentValidationIssue>.unmodifiable(issues);
  }

  static void _duplicates(
    Iterable<String> ids,
    String category,
    List<ContentValidationIssue> issues,
  ) {
    final seen = <String>{};
    final sorted = ids.toList()..sort();
    for (final id in sorted) {
      if (!seen.add(id)) {
        issues.add(
          ContentValidationIssue(
            code: 'duplicate_id',
            message: '$category: повтор ID $id.',
          ),
        );
      }
    }
  }
}
