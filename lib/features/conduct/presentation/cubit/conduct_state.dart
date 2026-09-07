import 'package:equatable/equatable.dart';

import '../../domain/entities/conduct_document_entity.dart';

sealed class ConductState extends Equatable {
  const ConductState();

  @override
  List<Object?> get props => [];
}

class ConductLoading extends ConductState {
  const ConductLoading();
}

class ConductLoadError extends ConductState {
  final String message;

  const ConductLoadError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConductLoaded extends ConductState {
  final ConductDocumentEntity document;
  final bool submitting;
  final String? errorMessage;

  const ConductLoaded(
    this.document, {
    this.submitting = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [document, submitting, errorMessage];
}

class ConductSignSuccess extends ConductState {
  const ConductSignSuccess();
}
