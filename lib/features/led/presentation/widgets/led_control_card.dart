import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_event.dart';

import '../../../led/presentation/bloc/led_bloc.dart';
import '../../../led/presentation/bloc/led_event.dart';
import '../../../led/presentation/bloc/led_state.dart';

class LedControlCard extends StatelessWidget {
  const LedControlCard({super.key});

  void _refreshStats(BuildContext context) {
    // Rafraîchir la partie "Statistiques rapides"
    context.read<DeviceBloc>().add(LoadSystemStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<LedBloc, LedState>(
          builder: (context, state) {
            bool isOn = false;
            bool isLoading = state is LedLoading;

            if (state is LedLoaded) {
              isOn = state.ledInfo.isOn;
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Contrôle LED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.lightbulb, size: 24, color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isOn ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: isOn
                        ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 25,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  isOn ? 'État: Allumée' : 'État: Éteinte',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<LedBloc>().add(TurnOnLed());
                            _refreshStats(context); // ✅ refresh stats
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ON',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<LedBloc>().add(TurnOffLed());
                            _refreshStats(context); // ✅ refresh stats
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'OFF',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<LedBloc>().add(ToggleLed());
                            _refreshStats(context); // ✅ refresh stats
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Toggle',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
