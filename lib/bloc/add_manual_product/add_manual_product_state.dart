import 'package:equatable/equatable.dart';

abstract class AddManualProductState extends Equatable {
  const AddManualProductState();

  @override
  List<Object?> get props => [];
}

class AddManualProductInitial extends AddManualProductState {
  const AddManualProductInitial();
}

class AddManualProductSaving extends AddManualProductState {
  const AddManualProductSaving();
}

class AddManualProductSuccess extends AddManualProductState {
  const AddManualProductSuccess();
}

class AddManualProductFailure extends AddManualProductState {
  final String message;

  const AddManualProductFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}