import 'package:baheth/core/api/api_result.dart';
import 'package:baheth/core/di/service_locator.dart';
import 'package:baheth/features/conduct/domain/entities/conduct_document_entity.dart';
import 'package:baheth/features/conduct/domain/repositories/conduct_repository.dart';
import 'package:baheth/features/conduct/presentation/cubit/conduct_cubit.dart';
import 'package:baheth/features/conduct/presentation/pages/conduct_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('agreement requires guardian name and reading to the end', (
    tester,
  ) async {
    final repository = _PageConductRepository(
      body: List.generate(
        80,
        (index) => 'البند ${index + 1}: يلتزم الطالب بالسلوك والانضباط.',
      ).join('\n'),
    );
    sl.registerFactory(() => ConductCubit(repository));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: ConductPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final agreement = find.widgetWithText(
      ElevatedButton,
      'أوافق وأُقرّ بالالتزام',
    );
    expect(find.text('مدونة السلوك والانضباط الداخلي للطلبة'), findsOneWidget);
    expect(find.text('اسم ولي الأمر'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(agreement).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField), 'محمد أحمد الخالدي');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(agreement).onPressed, isNull);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -10000),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(agreement).onPressed, isNotNull);
    expect(find.text('تمت قراءة المدونة حتى النهاية'), findsOneWidget);
  });
}

class _PageConductRepository implements ConductRepository {
  final String body;

  _PageConductRepository({required this.body});

  @override
  ApiResult<ConductDocumentEntity> getDocument() async => Right(
    ConductDocumentEntity(
      id: 1,
      titleAr: 'مدونة السلوك والانضباط الداخلي للطلبة',
      titleEn: 'Student Code of Conduct',
      body: body,
    ),
  );

  @override
  ApiResult<ConductStatusEntity> getStatus() async =>
      const Right(ConductStatusEntity(signed: false, documentId: 1));

  @override
  bool isSignedLocallyFor(int studentId) => false;

  @override
  Future<void> markSignedLocallyFor(int studentId) async {}

  @override
  ApiResult<void> sign({required String guardianName}) async =>
      const Right(null);
}
