#!/usr/bin/env bash
set -euo pipefail

# Génère l'architecture lib/ (d'après architecture.txt)
# Usage:
#   chmod +x gen_lib_arch.sh
#   ./gen_lib_arch.sh

mkdir -p lib

# Helper: crée dossier parent + fichier si absent
mkfile() {
  local f="$1"
  mkdir -p "$(dirname "$f")"
  if [[ ! -f "$f" ]]; then
    cat > "$f" <<'EOF'
// TODO: implement
EOF
  fi
}

# --- Files ---
mkfile lib/main.dart

mkfile lib/app/app.dart
mkfile lib/app/routes.dart
mkfile lib/app/theme.dart
mkfile lib/app/di.dart

mkfile lib/core/constants/api_constants.dart
mkfile lib/core/constants/firestore_constants.dart
mkfile lib/core/constants/app_constants.dart

mkfile lib/core/errors/exceptions.dart
mkfile lib/core/errors/failures.dart

mkfile lib/core/network/http_client.dart
mkfile lib/core/network/network_info.dart

mkfile lib/core/utils/logger.dart
mkfile lib/core/utils/formatters.dart
mkfile lib/core/utils/extensions.dart

mkfile lib/core/bloc/app_bloc_observer.dart

# --- features/sensors ---
mkfile lib/features/sensors/data/datasources/sensors_remote_datasource.dart
mkfile lib/features/sensors/data/datasources/sensors_firestore_datasource.dart
mkfile lib/features/sensors/data/models/sensor_model.dart
mkfile lib/features/sensors/data/models/sensor_history_model.dart
mkfile lib/features/sensors/data/repositories/sensors_repository_impl.dart

mkfile lib/features/sensors/domain/entities/sensor.dart
mkfile lib/features/sensors/domain/entities/sensor_history.dart
mkfile lib/features/sensors/domain/repositories/sensors_repository.dart
mkfile lib/features/sensors/domain/usecases/get_sensors.dart
mkfile lib/features/sensors/domain/usecases/get_sensor_by_id.dart
mkfile lib/features/sensors/domain/usecases/stream_sensors.dart
mkfile lib/features/sensors/domain/usecases/get_sensor_history.dart

mkfile lib/features/sensors/presentation/bloc/sensors_bloc.dart
mkfile lib/features/sensors/presentation/bloc/sensors_event.dart
mkfile lib/features/sensors/presentation/bloc/sensors_state.dart
mkfile lib/features/sensors/presentation/pages/home_page.dart
mkfile lib/features/sensors/presentation/pages/charts_page.dart
mkfile lib/features/sensors/presentation/pages/data_page.dart
mkfile lib/features/sensors/presentation/widgets/sensor_card.dart
mkfile lib/features/sensors/presentation/widgets/sensor_chart.dart
mkfile lib/features/sensors/presentation/widgets/json_viewer.dart

# --- features/led ---
mkfile lib/features/led/data/datasources/led_remote_datasource.dart
mkfile lib/features/led/data/datasources/led_firestore_datasource.dart
mkfile lib/features/led/data/models/led_info_model.dart
mkfile lib/features/led/data/models/led_event_model.dart
mkfile lib/features/led/data/repositories/led_repository_impl.dart

mkfile lib/features/led/domain/entities/led_info.dart
mkfile lib/features/led/domain/entities/led_event.dart
mkfile lib/features/led/domain/repositories/led_repository.dart
mkfile lib/features/led/domain/usecases/get_led_status.dart
mkfile lib/features/led/domain/usecases/control_led.dart
mkfile lib/features/led/domain/usecases/set_led_mode.dart
mkfile lib/features/led/domain/usecases/get_led_history.dart

mkfile lib/features/led/presentation/bloc/led_bloc.dart
mkfile lib/features/led/presentation/bloc/led_event.dart
mkfile lib/features/led/presentation/bloc/led_state.dart
mkfile lib/features/led/presentation/widgets/led_control_card.dart

# --- features/thresholds ---
mkfile lib/features/thresholds/data/datasources/thresholds_remote_datasource.dart
mkfile lib/features/thresholds/data/models/threshold_model.dart
mkfile lib/features/thresholds/data/repositories/thresholds_repository_impl.dart

mkfile lib/features/thresholds/domain/entities/threshold.dart
mkfile lib/features/thresholds/domain/repositories/thresholds_repository.dart
mkfile lib/features/thresholds/domain/usecases/get_thresholds.dart
mkfile lib/features/thresholds/domain/usecases/update_threshold.dart

mkfile lib/features/thresholds/presentation/bloc/thresholds_bloc.dart
mkfile lib/features/thresholds/presentation/bloc/thresholds_event.dart
mkfile lib/features/thresholds/presentation/bloc/thresholds_state.dart
mkfile lib/features/thresholds/presentation/pages/settings_page.dart
mkfile lib/features/thresholds/presentation/widgets/threshold_slider_card.dart
mkfile lib/features/thresholds/presentation/widgets/settings_list_item.dart
mkfile lib/features/thresholds/presentation/widgets/device_info_card.dart

# --- features/device ---
mkfile lib/features/device/data/datasources/device_remote_datasource.dart
mkfile lib/features/device/data/models/device_info_model.dart
mkfile lib/features/device/data/models/system_status_model.dart
mkfile lib/features/device/data/repositories/device_repository_impl.dart

mkfile lib/features/device/domain/entities/device_info.dart
mkfile lib/features/device/domain/entities/system_status.dart
mkfile lib/features/device/domain/repositories/device_repository.dart
mkfile lib/features/device/domain/usecases/get_device_info.dart
mkfile lib/features/device/domain/usecases/get_system_status.dart

mkfile lib/features/device/presentation/bloc/device_bloc.dart
mkfile lib/features/device/presentation/bloc/device_event.dart
mkfile lib/features/device/presentation/bloc/device_state.dart
mkfile lib/features/device/presentation/widgets/connection_status_pill.dart

# --- shared ---
mkfile lib/shared/presentation/pages/shell_page.dart
mkfile lib/shared/presentation/widgets/app_header.dart
mkfile lib/shared/presentation/widgets/rounded_card.dart
mkfile lib/shared/presentation/widgets/primary_button.dart
mkfile lib/shared/presentation/bloc/navigation_bloc.dart
mkfile lib/shared/presentation/bloc/navigation_event.dart
mkfile lib/shared/presentation/bloc/navigation_state.dart

echo "✅ Architecture générée dans lib/ (fichiers créés si absents)."

