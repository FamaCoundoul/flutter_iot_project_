import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_event.dart';
import '../../../device/presentation/bloc/device_state.dart';
import '../../../device/domain/entities/system_status.dart';

class StatsCard extends StatefulWidget {
  const StatsCard({super.key});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  SystemStatus? _lastStatus;

  @override
  void initState() {
    super.initState();

    // ⚠️ Safe: appeler après le 1er frame pour éviter context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeviceBloc>().add(LoadSystemStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<DeviceBloc, DeviceState>(
          // ✅ On mémorise les stats quand elles arrivent, même si ensuite l'état change
          listener: (context, state) {
            if (state is SystemStatusLoaded) {
              _lastStatus = state.systemStatus;
            }
          },
          builder: (context, state) {
            // Header constant
            Widget header() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistiques Rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.bar_chart, size: 24, color: Colors.grey[600]),
              ],
            );

            // Erreur
            if (state is DeviceError) {
              return Column(
                children: [
                  header(),
                  const SizedBox(height: 15),
                  Text(
                    'ErrelastUpdate: null,ur: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            // Loading: si on a déjà une ancienne valeur, on l'affiche (UX meilleure)
            if (state is DeviceLoading && _lastStatus == null) {
              return Column(
                children: [
                  header(),
                  const SizedBox(height: 15),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }

            // ✅ Si on a des stats en cache, on les affiche,
            // même si l'état courant est DeviceLoaded (IP polling) ou autre.
            final status = (state is SystemStatusLoaded)
                ? state.systemStatus
                : _lastStatus;

            if (status == null) {
              return Column(
                children: [
                  header(),
                  const SizedBox(height: 15),
                  const Text('Chargement des statistiques...'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<DeviceBloc>().add(LoadSystemStatus()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              );
            }

            return Column(
              children: [
                header(),
                const SizedBox(height: 15),
                _buildStatRow('Temps de fonctionnement', status.uptimeFormatted),
                _buildStatRow('Dernière mise à jour', status.lastUpdateFormatted),
                _buildStatRow(
                  'Capteurs actifs',
                  '${status.sensorCount} / ${status.sensorCount}',
                ),
                _buildStatRow('LED', status.ledStatus, isLast: true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
