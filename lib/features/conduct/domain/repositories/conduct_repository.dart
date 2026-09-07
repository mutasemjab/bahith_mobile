import '../../../../core/api/api_result.dart';
import '../entities/conduct_document_entity.dart';

abstract class ConductRepository {
  ApiResult<ConductDocumentEntity> getDocument();

  ApiResult<ConductStatusEntity> getStatus();

  ApiResult<void> sign({required String guardianName});

  bool isSignedLocallyFor(int studentId);

  Future<void> markSignedLocallyFor(int studentId);
}
