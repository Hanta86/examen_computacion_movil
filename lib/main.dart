import 'package:flutter/material.dart';
import 'pages/crud_page.dart';

void main() {
  runApp(const ExamenApp());
}

class ExamenApp extends StatelessWidget {
  const ExamenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Comercial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión Comercial'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.inventory_2, size: 75, color: Color(0xFF1565C0)),
          const SizedBox(height: 15),
          const Text(
            'Panel de administración',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _botonModulo(context, 'Proveedores', Icons.local_shipping),
          _botonModulo(context, 'Categorías', Icons.category),
          _botonModulo(context, 'Productos', Icons.shopping_bag),
        ],
      ),
    );
  }

  Widget _botonModulo(BuildContext context, String titulo, IconData icono) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFF1565C0)),
        title: Text(titulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CrudPage(modulo: titulo)),
          );
        },
      ),
    );
  }
}
