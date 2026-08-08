import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../application/localization/app_text.dart';
import 'app_card.dart';

class InteractiveMetricPoint {
  const InteractiveMetricPoint({
    required this.simulationMinutes,
    required this.value,
  });

  final int simulationMinutes;
  final double value;
}

class InteractiveMetricChartCard extends StatefulWidget {
  const InteractiveMetricChartCard({
    required this.title,
    required this.current,
    required this.points,
    required this.dateFormatter,
    required this.valueFormatter,
    super.key,
  });

  final String title;
  final String current;
  final List<InteractiveMetricPoint> points;
  final String Function(int simulationMinutes) dateFormatter;
  final String Function(double value) valueFormatter;

  @override
  State<InteractiveMetricChartCard> createState() =>
      _InteractiveMetricChartCardState();
}

class _InteractiveMetricChartCardState
    extends State<InteractiveMetricChartCard> {
  int? _selectedIndex;

  void _select(double dx, double width) {
    if (widget.points.isEmpty || width <= 0) return;
    final fraction = (dx / width).clamp(0.0, 1.0);
    final index = (fraction * math.max(0, widget.points.length - 1))
        .round()
        .clamp(0, widget.points.length - 1);
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.points.isEmpty
        ? null
        : widget.points[(_selectedIndex ?? widget.points.length - 1).clamp(
            0,
            widget.points.length - 1,
          )];
    final values = widget.points
        .map((item) => item.value)
        .toList(growable: false);
    final usable = values.length >= 2
        ? values
        : values.isEmpty
        ? const <double>[0, 0]
        : <double>[values.first, values.first];

    return RepaintBoundary(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                AppText(
                  selected == null
                      ? widget.current
                      : widget.valueFormatter(selected.value),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            if (selected != null) ...[
              const SizedBox(height: 3),
              AppText(
                '${widget.dateFormatter(selected.simulationMinutes)} • '
                '${widget.valueFormatter(selected.value)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _select(details.localPosition.dx, constraints.maxWidth),
                onHorizontalDragStart: (details) =>
                    _select(details.localPosition.dx, constraints.maxWidth),
                onHorizontalDragUpdate: (details) =>
                    _select(details.localPosition.dx, constraints.maxWidth),
                child: SizedBox(
                  key: Key('interactive-metric-${widget.title}'),
                  height: 142,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _InteractiveLinePainter(
                      points: usable,
                      selectedIndex: widget.points.isEmpty
                          ? null
                          : (_selectedIndex ?? widget.points.length - 1),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const AppText(
              'Проведите пальцем по графику для значения за конкретный день.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveLinePainter extends CustomPainter {
  const _InteractiveLinePainter({
    required this.points,
    required this.selectedIndex,
  });

  final List<double> points;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minValue = points.reduce(math.min);
    final maxValue = points.reduce(math.max);
    final range = math.max(0.000001, maxValue - minValue);
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var index = 1; index < 4; index += 1) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset pointOffset(int index) {
      final x = points.length == 1
          ? 0.0
          : size.width * index / (points.length - 1);
      final normalized = (points[index] - minValue) / range;
      final y = size.height - normalized * size.height;
      return Offset(x, y);
    }

    final path = Path();
    for (var index = 0; index < points.length; index += 1) {
      final offset = pointOffset(index);
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final selected = selectedIndex;
    if (selected != null && selected >= 0 && selected < points.length) {
      final offset = pointOffset(selected);
      canvas.drawLine(
        Offset(offset.dx, 0),
        Offset(offset.dx, size.height),
        Paint()
          ..color = AppColors.primary.withAlpha(95)
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(offset, 5, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveLinePainter oldDelegate) {
    if (oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.points.length != points.length) {
      return true;
    }
    for (var index = 0; index < points.length; index += 1) {
      if (oldDelegate.points[index] != points[index]) return true;
    }
    return false;
  }
}
