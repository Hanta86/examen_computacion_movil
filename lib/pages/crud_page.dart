import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CrudPage extends StatefulWidget {
  final String modulo;
  const CrudPage({super.key, required this.modulo});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  late final String prefijo;
  late final String clave;
  late final String campoId;
  late Future<List<Map<String, dynamic>>> registros;

  @override
  void initState() {
    super.initState();

    switch (widget.modulo) {
      case 'Productos':
        prefijo = 'product';
        clave = 'Listado';
        campoId = 'product_id';
        break;
      case 'Categorías':
        prefijo = 'category';
        clave = 'Listado Categorias';
        campoId = 'category_id';
        break;
      default:
        prefijo = 'provider';
        clave = 'Proveedores Listado';
        campoId = 'providerid';
    }

    actualizar();
  }

  void actualizar() {
    setState(() {
      registros = ApiService.listar('${prefijo}_list_rest/', clave);
    });
  }

  String nombre(Map<String, dynamic> dato) {
    if (prefijo == 'provider') {
      return '${dato['provider_name']} ${dato['provider_last_name']}';
    }
    return '${dato['${prefijo}_name']}';
  }

  Map<String, dynamic> camposIniciales(Map<String, dynamic>? dato) {
    if (prefijo == 'provider') {
      return {
        'provider_name': dato?['provider_name'] ?? '',
        'provider_last_name': dato?['provider_last_name'] ?? '',
        'provider_mail': dato?['provider_mail'] ?? '',
      };
    }
    if (prefijo == 'product') {
      return {
        'product_name': dato?['product_name'] ?? '',
        'product_price': dato?['product_price']?.toString() ?? '',
        'product_image': dato?['product_image'] ?? '',
      };
    }
    return {'category_name': dato?['category_name'] ?? ''};
  }

  Future<void> formulario([Map<String, dynamic>? dato]) async {
    final editar = dato != null;
    final campos = camposIniciales(dato);
    final controles = {
      for (final campo in campos.keys)
        campo: TextEditingController(text: campos[campo].toString()),
    };

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editar ? 'Editar registro' : 'Agregar registro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final campo in controles.keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controles[campo],
                    keyboardType: campo == 'product_price'
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: campo.replaceAll('_', ' '),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardar == true) {
      final datos = <String, dynamic>{
        for (final campo in controles.keys)
          campo: controles[campo]!.text.trim(),
      };

      if (prefijo == 'product') {
        datos['product_price'] =
            num.tryParse(datos['product_price'].toString()) ?? 0;
      }

      if (editar) {
        datos['${prefijo}_id'] = dato[campoId];
        datos['${prefijo}_state'] =
            dato['${prefijo}_state'] ??
            (prefijo == 'category' ? 'Activa' : 'Activo');
      }

      try {
        await ApiService.enviar(
          '${prefijo}_${editar ? 'edit' : 'add'}_rest/',
          datos,
        );
        if (!mounted) return;
        actualizar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Operación realizada')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> eliminar(Map<String, dynamic> dato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar ${nombre(dato)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ApiService.enviar('${prefijo}_del_rest/', {
        '${prefijo}_id': dato[campoId],
      });
      if (!mounted) return;
      actualizar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro eliminado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void verDetalle(Map<String, dynamic> dato) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nombre(dato)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final campo in dato.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text('${campo.key}: ${campo.value}'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.modulo)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => formulario(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: registros,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos:\n${snapshot.error}'),
            );
          }

          final datos = snapshot.data ?? [];
          if (datos.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              actualizar();
              await registros;
            },
            child: ListView.builder(
              itemCount: datos.length,
              itemBuilder: (context, index) {
                final dato = datos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(nombre(dato)),
                    subtitle: Text('ID: ${dato[campoId]}'),
                    onTap: () => verDetalle(dato),
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          onPressed: () => formulario(dato),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          onPressed: () => eliminar(dato),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
