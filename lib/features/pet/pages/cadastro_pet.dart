import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/pet_model.dart';
import '../repository/pet_local_repository.dart';

class CadastroPetPage extends StatefulWidget {
  const CadastroPetPage({super.key});

  @override
  State<CadastroPetPage> createState() => _CadastroPetPageState();
}

class _CadastroPetPageState extends State<CadastroPetPage> {
  final _nome = TextEditingController();
  final _idade = TextEditingController();
  final _raca = TextEditingController();
  final _porte = TextEditingController();

  File? _image;
  final _picker = ImagePicker();
  final _repo = PetLocalRepository();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(picked.path).copy(path);

    setState(() => _image = File(path));
  }

  Future<void> _salvar() async {
    if (_nome.text.isEmpty ||
        _idade.text.isEmpty ||
        _raca.text.isEmpty ||
        _porte.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e escolha uma foto.')),
      );
      return;
    }

    final pet = Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nome.text.trim(),
      idade: _idade.text.trim(),
      raca: _raca.text.trim(),
      porte: _porte.text.trim(),
      imagePath: _image!.path,
    );
    await _repo.add(pet);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet cadastrado com sucesso!')),
    );

    Navigator.pop(context, true); // sinaliza para atualizar a Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.yellow, title: const Text('Cadastro Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade300,
                    image: _image != null
                        ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ? const Center(child: Icon(Icons.camera_alt, size: 48))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Nome do Pet'), controller: _nome),
            TextField(decoration: const InputDecoration(labelText: 'Idade'), controller: _idade),
            TextField(decoration: const InputDecoration(labelText: 'Raça'), controller: _raca),
            TextField(decoration: const InputDecoration(labelText: 'Porte'), controller: _porte),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(48)),
              child: const Text('Finalizar Cadastro', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
