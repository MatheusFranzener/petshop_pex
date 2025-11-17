import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';
import 'package:petshop_pex/features/nav_button.dart';
import 'package:provider/provider.dart';

import '../../pet/models/pet_model.dart';
import 'agendamentos_cliente.dart';

class ServicosClientePage extends StatefulWidget {
  final List<Pet> pets;

  const ServicosClientePage({super.key, required this.pets});

  @override
  State<ServicosClientePage> createState() => _ServicosClientePageState();
}

class _ServicosClientePageState extends State<ServicosClientePage> {
  Pet? _selectedPet;
  List<Pet> _pets = [];

  final Map<String, bool> _selectedServices = {
    'Banho completo': false,
    'Tosa': false,
    'Veterinário': false,
  };

  Widget _buildPetImage(Pet? pet) {
    if (pet == null || pet.imagePath.isEmpty || kIsWeb) {
      return Container(
        width: 150,
        height: 150,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 48, color: Colors.black),
      );
    }

    final file = File(pet.imagePath);
    if (!file.existsSync()) {
      return Container(
        width: 150,
        height: 150,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 48, color: Colors.black),
      );
    }

    return SizedBox(
      width: 150,
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesList = _selectedServices.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        leading: MainNavMenuButton(pets: _pets),
        title: const Text('Serviços', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sair',
            onPressed: () {
              context.read<AuthController>().logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecione o PET',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Pet>(
              value: _selectedPet,
              items: widget.pets
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.nome)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPet = value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escolha um pet',
              ),
            ),
            const SizedBox(height: 16),
            Center(child: _buildPetImage(_selectedPet)),
            const SizedBox(height: 24),
            const Text(
              'Selecione o agendamento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: servicesList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final service = servicesList[index];
                  final selected = _selectedServices[service] ?? false;
                  return Row(
                    children: [
                      Expanded(child: Text(service)),
                      Checkbox(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            _selectedServices.updateAll((key, _) => false);
                            _selectedServices[service] = value ?? false;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedPet != null &&
                        _selectedServices.values.any((v) => v)
                    ? () {
                        final selectedServices = _selectedServices.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgendamentosClientePage(
                              pet: _selectedPet!,
                              services: selectedServices,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Agendamentos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
