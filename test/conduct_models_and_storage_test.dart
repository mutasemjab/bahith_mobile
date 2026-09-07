import 'package:baheth/core/storage/secure_storage.dart';
import 'package:baheth/features/conduct/data/models/conduct_document_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('conduct models parse the documented API response', () {
    final document = ConductDocumentModel.fromJson(const {
      'id': 1,
      'title_ar': 'مدونة السلوك والانضباط الداخلي للطلبة',
      'title_en': 'Student Code of Conduct',
      'body': 'مقدمة\nتسعى أكاديمية ومدارس الباحث...',
    });
    final status = ConductStatusModel.fromJson(const {
      'signed': false,
      'document_id': 1,
    });

    expect(document.id, 1);
    expect(document.body, contains('\n'));
    expect(status.signed, isFalse);
    expect(status.documentId, 1);
  });

  test('the local conduct flag is scoped to the signing student', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = SecureStorage(const FlutterSecureStorage(), preferences);

    expect(storage.isConductSignedFor(10), isFalse);

    await storage.markConductSignedFor(10);

    expect(preferences.getBool('conduct_signed'), isTrue);
    expect(storage.isConductSignedFor(10), isTrue);
    expect(storage.isConductSignedFor(11), isFalse);
  });
}
