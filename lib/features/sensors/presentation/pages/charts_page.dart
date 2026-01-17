import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../shared/presentation/widgets/app_header.dart';
import '../../../led/presentation/bloc/led_bloc.dart';
import '../../../led/presentation/bloc/led_event.dart';
import '../../../led/presentation/bloc/led_state.dart';
import '../bloc/sensors_bloc.dart';
import '../bloc/sensors_event.dart';
import '../bloc/sensors_state.dart';

enum TimePeriod { hour, day, week, month }

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  TimePeriod _period = TimePeriod.hour;

  // Historique brut (x = epoch ms, y = valeur)
  final List<FlSpot> _tempHistory = [];
  final List<FlSpot> _lightHistory = [];
  final List<FlSpot> _ledHistory = []; // y: 1 ON, 0 OFF

  Timer? _pollTimer;
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();

    // Charge initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SensorsBloc>().add(RefreshSensors());
      context.read<LedBloc>().add(LoadLedStatus());
    });

    // Poll (si tu veux du "temps réel")
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_autoRefresh) return;
      context.read<SensorsBloc>().add(RefreshSensors());
      context.read<LedBloc>().add(LoadLedStatus());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Duration _durationForPeriod(TimePeriod p) {
    switch (p) {
      case TimePeriod.hour:
        return const Duration(hours: 1);
      case TimePeriod.day:
        return const Duration(days: 1);
      case TimePeriod.week:
        return const Duration(days: 7);
      case TimePeriod.month:
        return const Duration(days: 30);
    }
  }

  void _trimHistory() {
    // On garde un max de points pour performance (tu peux ajuster)
    const maxPoints = 800;
    if (_tempHistory.length > maxPoints) {
      _tempHistory.removeRange(0, _tempHistory.length - maxPoints);
    }
    if (_lightHistory.length > maxPoints) {
      _lightHistory.removeRange(0, _lightHistory.length - maxPoints);
    }
    if (_ledHistory.length > maxPoints) {
      _ledHistory.removeRange(0, _ledHistory.length - maxPoints);
    }
  }

  List<FlSpot> _filterByPeriod(List<FlSpot> data) {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final start = now - _durationForPeriod(_period).inMilliseconds.toDouble();
    return data.where((p) => p.x >= start).toList();
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<SensorsBloc, SensorsState>(
            listener: (context, state) {
              if (state is SensorsLoaded) {
                final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();

                // récupère temperature / light depuis tes sensors
                final sensors = state.sensors;

                final temp = sensors.firstWhere(
                      (s) => (s.type ?? '').toLowerCase() == 'temperature' || s.isTemperature,
                  orElse: () => sensors.first,
                );

                final light = sensors.firstWhere(
                      (s) => (s.type ?? '').toLowerCase() == 'light' || s.isLight,
                  orElse: () => sensors.last,
                );

                // Attention: adapte si ton modèle n’a pas "value" en double
                _tempHistory.add(FlSpot(nowMs, temp.value.toDouble()));
                _lightHistory.add(FlSpot(nowMs, light.value.toDouble()));
                _trimHistory();
                setState(() {});
              }
            },
          ),
          BlocListener<LedBloc, LedState>(
            listener: (context, state) {
              if (state is LedLoaded) {
                final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
                final isOn = state.ledInfo.isOn; // adapte si ton entité diffère
                _ledHistory.add(FlSpot(nowMs, isOn ? 1.0 : 0.0));
                _trimHistory();
                setState(() {});
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<SensorsBloc>().add(RefreshSensors());
            context.read<LedBloc>().add(LoadLedStatus());
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              const AppHeader(),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTopBar(context),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPeriodSelector(),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLineChartCard(
                  title: 'Température',
                  subtitle: 'Évolution dans le temps',
                  icon: Icons.thermostat,
                  unit: '°C',
                  data: _filterByPeriod(_tempHistory),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLineChartCard(
                  title: 'Lumière',
                  subtitle: 'Niveau de luminosité',
                  icon: Icons.wb_sunny,
                  unit: 'lux',
                  data: _filterByPeriod(_lightHistory),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLedChartCard(_filterByPeriod(_ledHistory)),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsCards(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Graphiques',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            const Text('Auto', style: TextStyle(fontSize: 12)),
            Switch(
              value: _autoRefresh,
              onChanged: (v) => setState(() => _autoRefresh = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(child: _periodBtn('1H', TimePeriod.hour)),
            const SizedBox(width: 8),
            Expanded(child: _periodBtn('24H', TimePeriod.day)),
            const SizedBox(width: 8),
            Expanded(child: _periodBtn('7J', TimePeriod.week)),
            const SizedBox(width: 8),
            Expanded(child: _periodBtn('30J', TimePeriod.month)),
          ],
        ),
      ),
    );
  }

  Widget _periodBtn(String label, TimePeriod p) {
    final selected = _period == p;
    return ElevatedButton(
      onPressed: () => setState(() => _period = p),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF667eea) : Colors.grey[200],
        foregroundColor: selected ? Colors.white : Colors.grey[700],
        elevation: selected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
    );
  }

  // ---- Charts ----

  Widget _buildLineChartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String unit,
    required List<FlSpot> data,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFF667eea)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (data.isNotEmpty)
                  Text(
                    '${data.last.y.toStringAsFixed(1)} $unit',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (data.length < 2)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text('Pas assez de points pour afficher un graphique'),
              )
            else
              SizedBox(
                height: 220,
                child: LineChart(_lineChartData(data, unit)),
              ),
          ],
        ),
      ),
    );
  }

  LineChartData _lineChartData(List<FlSpot> data, String unit) {
    final minY = data.map((e) => e.y).reduce(math.min);
    final maxY = data.map((e) => e.y).reduce(math.max);
    final padding = (maxY - minY).abs() * 0.15;
    final yMin = minY - padding;
    final yMax = maxY + padding;

    return LineChartData(
      minY: yMin,
      maxY: yMax,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 10,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((s) {
              final dt = DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
              final t = DateFormat('HH:mm').format(dt);
              return LineTooltipItem(
                '${s.y.toStringAsFixed(1)} $unit\n$t',
                const TextStyle(fontWeight: FontWeight.w700),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 46,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: _bottomInterval(data),
            getTitlesWidget: (value, meta) {
              final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('HH:mm').format(dt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: data,
          isCurved: true,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true),
        ),
      ],
    );
  }

  double _bottomInterval(List<FlSpot> data) {
    if (data.length < 2) return 1;
    final span = data.last.x - data.first.x; // ms
    // 5 labels environ
    return span / 5;
  }

  Widget _buildLedChartCard(List<FlSpot> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, size: 22, color: Color(0xFF667eea)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Historique LED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('ON / OFF dans le temps', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (data.isNotEmpty)
                  Text(
                    data.last.y >= 0.5 ? 'ON' : 'OFF',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (data.length < 2)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text('Pas assez de points pour afficher un graphique'),
              )
            else
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minY: -0.2,
                    maxY: 1.2,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) {
                          return spots.map((s) {
                            final dt = DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
                            final t = DateFormat('HH:mm').format(dt);
                            final st = s.y >= 0.5 ? 'ON' : 'OFF';
                            return LineTooltipItem('$st\n$t', const TextStyle(fontWeight: FontWeight.w700));
                          }).toList();
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 42,
                          getTitlesWidget: (v, meta) {
                            if (v == 0) return const Text('OFF', style: TextStyle(fontSize: 10, color: Colors.grey));
                            if (v == 1) return const Text('ON', style: TextStyle(fontSize: 10, color: Colors.grey));
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: _bottomInterval(data),
                          getTitlesWidget: (value, meta) {
                            final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(DateFormat('HH:mm').format(dt),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: false,
                        barWidth: 3,
                        isStepLineChart: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---- Stats ----

  Widget _buildStatsCards() {
    final temp = _filterByPeriod(_tempHistory);
    final light = _filterByPeriod(_lightHistory);

    return Row(
      children: [
        Expanded(child: _buildStatsMiniCard('Température', '°C', temp)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatsMiniCard('Lumière', 'lux', light)),
      ],
    );
  }

  Widget _buildStatsMiniCard(String title, String unit, List<FlSpot> data) {
    double? minV, maxV, avgV;
    if (data.isNotEmpty) {
      minV = data.map((e) => e.y).reduce(math.min);
      maxV = data.map((e) => e.y).reduce(math.max);
      avgV = data.map((e) => e.y).reduce((a, b) => a + b) / data.length;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (data.isEmpty)
              const Text('Aucune donnée', style: TextStyle(color: Colors.grey))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _kv('Min', '${minV!.toStringAsFixed(1)} $unit'),
                  _kv('Max', '${maxV!.toStringAsFixed(1)} $unit'),
                  _kv('Moy', '${avgV!.toStringAsFixed(1)} $unit'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
