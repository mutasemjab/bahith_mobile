import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final int id;
  final String imageUrl;
  final int orderIndex;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, imageUrl, orderIndex];
}
