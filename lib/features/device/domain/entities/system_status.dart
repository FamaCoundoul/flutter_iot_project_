import 'package:equatable/equatable.dart';

class SystemStatus extends Equatable {
  final int uptime;
  final String ledStatus;
  final int sensorCount;
  final int freeHeap;
  final int timestamp;
  final int lastUpdate; // en millisecondes (epoch local ou réception)



  const SystemStatus({
    required this.uptime,
    required this.ledStatus,
    required this.sensorCount,
    required this.freeHeap,
    required this.timestamp,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [uptime, ledStatus, sensorCount, freeHeap, timestamp];

  /// Convertit l'uptime (ms) en format lisible
  String get uptimeFormatted {
    final seconds = uptime ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) {
      return '${days}j ${hours % 24}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes % 60}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds % 60}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Temps depuis la dernière mise à jour
  String get lastUpdateFormatted {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMs = now - lastUpdate;

    if (diffMs <= 0) return 'À l’instant';

    final diff = Duration(milliseconds: diffMs);

    if (diff.inSeconds < 10) {
      return 'À l’instant';
    } else if (diff.inMinutes < 1) {
      return 'Il y a ${diff.inSeconds}s';
    } else if (diff.inHours < 1) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return minutes > 0
          ? 'Il y a ${hours}h ${minutes}min'
          : 'Il y a ${hours}h';
    } else {
      final days = diff.inDays;
      return 'Il y a ${days} jour${days > 1 ? 's' : ''}';
    }
  }

  /// Formatage de la mémoire
  String get freeHeapFormatted {
    if (freeHeap >= 1024 * 1024) {
      return '${(freeHeap / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (freeHeap >= 1024) {
      return '${(freeHeap / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$freeHeap bytes';
    }
  }

  /// Indicateur LED
  bool get isLedOn => ledStatus == 'on';






}