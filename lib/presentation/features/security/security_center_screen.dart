import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/controllers/game_controller.dart';
import '../../../domain/catalog/operations_catalog.dart';
import '../../../domain/commands/game_action.dart';
import '../../../domain/entities/models.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../../application/localization/app_text.dart';
import '../../shared/widgets/scoped_listenable_builder.dart';
import '../../../application/localization/app_localizer.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    return ScopedListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final available = state.products
            .where((item) => item.stage != ProductStage.failed)
            .toList(growable: false);
        final selectedId =
            available.any((item) => item.id == _selectedProductId)
            ? _selectedProductId
            : available.isEmpty
            ? null
            : available.first.id;
        final product = selectedId == null
            ? null
            : state.productById(selectedId);

        return Scaffold(
          appBar: AppBar(title: const AppText('Центр безопасности')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const SectionHeader(
                title: 'Управление безопасностью',
                subtitle:
                    'Риск рассчитывается из категории, масштаба, уровня безопасности, загрузки инфраструктуры и внедрённых контролей.',
              ),
              const SizedBox(height: 12),
              if (available.isEmpty)
                const AppCard(
                  child: AppText(
                    'Создайте продукт, чтобы настроить безопасность.',
                  ),
                )
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    labelText: trContext(context, 'Продукт'),
                  ),
                  items: available
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: AppText(item.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) =>
                      setState(() => _selectedProductId = value),
                ),
                const SizedBox(height: 12),
                if (product != null) ...[
                  _RiskOverview(
                    controller: widget.controller,
                    product: product,
                  ),
                  const SizedBox(height: 18),
                  const SectionHeader(
                    title: 'Контроли',
                    subtitle:
                        'Каждый контроль имеет разовую стоимость внедрения, ежемесячную стоимость и точный коэффициент снижения вероятности инцидента.',
                  ),
                  const SizedBox(height: 10),
                  ...OperationsCatalog.securityControls.map(
                    (control) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SecurityControlCard(
                        controller: widget.controller,
                        product: product,
                        controlId: control.id,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RiskOverview extends StatelessWidget {
  const _RiskOverview({required this.controller, required this.product});

  final GameController controller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final risk = state.productSecurityRisk(product);
    final multiplier = state.productIncidentMultiplier(product.id);
    final latest = state.latestAuditFor(product.id);
    final installed = state.securityControlIdsFor(product.id).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              MetricCard(
                label: 'Риск атаки',
                value: percent(risk, fractionDigits: 1),
                positive: risk < 0.18,
              ),
              MetricCard(
                label: 'Уровень безопасности',
                value: '${product.securityScore.round()}/100',
                positive: product.securityScore >= 75,
              ),
              MetricCard(label: 'Контролей', value: '$installed'),
              MetricCard(
                label: 'Коэффициент риска',
                value: '${multiplier.toStringAsFixed(2)}×',
                positive: multiplier <= 0.6,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppText(
                  latest == null
                      ? 'Аудит ещё не проводился.'
                      : 'Последний аудит: риск ${latest.riskPercent.toStringAsFixed(1)}%, замечаний ${latest.findingsCount}.',
                ),
              ),
              FilledButton.icon(
                key: Key('audit-${product.id}'),
                onPressed: state.cash >= 75000
                    ? () => controller.dispatch(RunSecurityAudit(product.id))
                    : null,
                icon: const Icon(Icons.fact_check_outlined),
                label: const AppText('Аудит 75 тыс.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityControlCard extends StatelessWidget {
  const _SecurityControlCard({
    required this.controller,
    required this.product,
    required this.controlId,
  });

  final GameController controller;
  final Product product;
  final String controlId;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final control = OperationsCatalog.securityControlById(controlId);
    final installed = state.hasSecurityControl(product.id, control.id);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  control.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (installed)
                const Chip(
                  avatar: Icon(Icons.check_circle, size: 16),
                  label: AppText('Внедрено'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AppText(control.description),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag('Разово ${money(control.setupCost)}'),
              _Tag('${money(control.monthlyCost)}/мес.'),
              _Tag('+${control.securityDelta.round()} к безопасности'),
              _Tag('${control.incidentMultiplier.toStringAsFixed(2)}× риск'),
            ],
          ),
          if (!installed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                key: Key('install-${product.id}-${control.id}'),
                onPressed: state.cash >= control.setupCost
                    ? () => controller.dispatch(
                        PurchaseSecurityControl(
                          productId: product.id,
                          controlId: control.id,
                        ),
                      )
                    : null,
                child: const AppText('Внедрить'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: AppText(text),
    );
  }
}
