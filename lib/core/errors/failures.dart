import 'package:equatable/equatable.dart';

/// Failure de base pour la couche domain
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// Erreur serveur/API
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Erreur de cache
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Erreur réseau
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Erreur de validation
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}