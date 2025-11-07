import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/pet_model.dart';
import '../repository/pet_local_repository.dart';

class DetalhesPetPage extends StatefulWidget {
  final Pet pet;
  const DetalhesPetPage({super.key, required this.pet});

  @override
  State<DetalhesPetPage> createState() => _DetalhesPetPageState();
}

class _DetalhesPetPageState extends State<DetalhesPetPage> {
  late final TextEditingController _nome;
  late final TextEditingController _idade;
  late final TextEditingController _raca;
  late final TextEditingController _porte;

  final _picker = ImagePicker();
  final _repo = PetLocalRepository();

  File? _image;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.pet.nome);
    _idade = TextEditingController(text: widget.pet.idade);
    _raca = TextEditingController(text: widget.pet.raca);
    _porte = TextEditingController(text: widget.pet.porte);
    _image = File(widget.pet.imagePath);
  }

  @override
  void dispose() {
    _nome.dispose();
    _idade.dispose();
    _raca.dispose();
    _porte.dispose();
    super.dispose();
  }

  Future<void> _trocarFoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(picked.path).copy(path);

    setState(() => _image = File(path));
  }

  Future<void> _salvarEdicao() async {
    widget.pet.nome = _nome.text.trim();
    widget.pet.idade = _idade.text.trim();
    widget.pet.raca  = _raca.text.trim();
    widget.pet.porte = _porte.text.trim();
    if (_image != null) widget.pet.imagePath = _image!.path;
    await _repo.update(widget.pet);

    setState(() => _editing = false);
    Navigator.pop(context, true); // informa para recarregar a Home
  }

  Future<void> _excluir() async {
    await _repo.delete(widget.pet);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Detalhes do Pet'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            if (_editing)
              ElevatedButton(
                onPressed: _trocarFoto,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Trocar foto'),
              ),
            const SizedBox(height: 12),
            _field('Nome', _nome, enabled: _editing),
            _field('Idade', _idade, enabled: _editing),
            _field('Raça', _raca, enabled: _editing),
            _field('Porte', _porte, enabled: _editing),
            const SizedBox(height: 16),
            if (_editing)
              ElevatedButton(
                onPressed: _salvarEdicao,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size.fromHeight(48)),
                child: const Text('Salvar alterações', style: TextStyle(color: Colors.white)),
              )
            else
              ElevatedButton(
                onPressed: _excluir,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size.fromHeight(48)),
                child: const Text('Excluir pet', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {bool enabled = false}) {
    return TextField(
      controller: c,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
    );
  }
}
