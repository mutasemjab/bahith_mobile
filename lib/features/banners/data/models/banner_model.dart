import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.imageUrl,
    required super.orderIndex,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    dynamic rawImage =
        json['image_url'] ??
        json['image'] ??
        json['photo'] ??
        json['banner'] ??
        json['banner_image'] ??
        json['url'] ??
        json['file'] ??
        json['path'] ??
        json['media_url'];

    String imgStr = '';
    if (rawImage is String) {
      imgStr = rawImage.replaceAll(RegExp(r'[\r\n\t]'), '').trim();
    } else if (rawImage is Map) {
      final dynamic nested =
          rawImage['url'] ??
          rawImage['path'] ??
          rawImage['image'] ??
          rawImage['link'] ??
          '';
      imgStr = nested.toString().replaceAll(RegExp(r'[\r\n\t]'), '').trim();
    }

    final httpsIdx = imgStr.indexOf('https://');
    final httpIdx = imgStr.indexOf('http://');
    if (httpsIdx != -1) {
      imgStr = imgStr.substring(httpsIdx);
    } else if (httpIdx != -1) {
      imgStr = imgStr.substring(httpIdx);
    }

    final idVal = json['id'];
    final int parsedId = idVal is int
        ? idVal
        : (int.tryParse(idVal?.toString() ?? '0') ?? 0);

    final orderVal =
        json['order_index'] ?? json['order'] ?? json['sort_order'] ?? 0;
    final int parsedOrder = orderVal is int
        ? orderVal
        : (int.tryParse(orderVal?.toString() ?? '0') ?? 0);

    return BannerModel(id: parsedId, imageUrl: imgStr, orderIndex: parsedOrder);
  }
}
