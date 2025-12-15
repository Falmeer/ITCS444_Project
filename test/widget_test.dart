import 'package:flutter_test/flutter_test.dart';
import 'package:itcs444_project/main.dart';

void main() {
	testWidgets('app builds without crashing', (WidgetTester tester) async {
		await tester.pumpWidget(const CareCenterApp());
		expect(find.byType(CareCenterApp), findsOneWidget);
	});
}

