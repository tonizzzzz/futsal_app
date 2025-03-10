// lib/pages/player_edit_page.dart
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../repositories/player_repository.dart';
import '../services/token_service.dart';

class PlayerEditPage extends StatefulWidget {
  final Player player;

  const PlayerEditPage({super.key, required this.player});

  @override
  _PlayerEditPageState createState() => _PlayerEditPageState();
}

class _PlayerEditPageState extends State<PlayerEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.player.name;
    _positionController.text = widget.player.position;
    _imageUrlController.text = widget.player.imageUrl;
  }

  Future<void> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de autenticación: Token no válido'),
          ),
        );
        return;
      }

      final updatedPlayer = Player(
        id: widget.player.id,
        name: _nameController.text,
        position: _positionController.text,
        imageUrl: _imageUrlController.text,
        rating: widget.player.rating,
        gamesPlayed: widget.player.gamesPlayed, // 🔹 Agregar este argumento
      );

      try {
        await PlayerRepository().updatePlayer(token, updatedPlayer);
        Navigator.pop(
          context,
          updatedPlayer,
        ); // Devuelve el jugador actualizado
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el jugador: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Ficha")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Posición'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'La posición es obligatoria' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !Uri.parse(value).isAbsolute) {
                    return 'Introduce una URL válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePlayer,
                child: const Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
