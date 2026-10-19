import 'package:flutter_test/flutter_test.dart';
import 'package:examen_computacion_movil/main.dart';

void main() {
  testWidgets('La aplicación muestra el menú principal', (tester) async {
    await tester.pumpWidget(const ExamenApp());

    expect(find.text('Panel de administración'), findsOneWidget);
    expect(find.text('Proveedores'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
  });
}
