// lib/pages/player_create_page.dart
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../repositories/player_repository.dart';
import '../services/token_service.dart';

class PlayerCreatePage extends StatefulWidget {
  const PlayerCreatePage({super.key});

  @override
  _PlayerCreatePageState createState() => _PlayerCreatePageState();
}

class _PlayerCreatePageState extends State<PlayerCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _imageUrlController = TextEditingController();

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

      final newPlayer = Player(
        id: 0, // El ID se generará en el servidor
        name: _nameController.text,
        position: _positionController.text,
        imageUrl: _imageUrlController.text,
        rating: 0.0, // Puntuación inicial en 0
          gamesPlayed: [], // 🔹 Lista vacía ya que es un jugador nuevo

      );

      try {
        await PlayerRepository().createPlayer(token, newPlayer);
        Navigator.pop(context, true); // Devolver true si se crea correctamente
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el jugador: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Añadir Nuevo Jugador")),
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
                child: const Text("Guardar Jugador"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
