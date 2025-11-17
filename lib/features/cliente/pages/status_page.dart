import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../pet/models/pet_model.dart';

class StatusPage extends StatelessWidget {
  final Pet pet;
  final String servico;
  final int etapa; // 0 = Chegou, 1 = Em processo, 2 = Finalizado
  final List<String> historico; // comentários do serviço

  const StatusPage({
    super.key,
    required this.pet,
    required this.servico,
    required this.etapa,
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.yellow,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: pet.imagePath.isNotEmpty
                        ? Image.file(
                            File(pet.imagePath),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.pets, size: 40),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoLine('NOME', pet.nome),
                        _infoLine('IDADE', pet.idade),
                        _infoLine('RAÇA', pet.raca),
                        _infoLine('PORTE', pet.porte),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                servico.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatusSteps(etapaAtual: etapa),
            ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'HISTÓRICO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: historico.isEmpty
                    ? const [Text('Ainda não há registros.')]
                    : historico
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(h)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value', style: const TextStyle(fontSize: 14)),
    );
  }
}

class _StatusSteps extends StatelessWidget {
  final int etapaAtual; // 0 chegou, 1 em processo, 2 finalizado

  const _StatusSteps({required this.etapaAtual});

  @override
  Widget build(BuildContext context) {
    const steps = ['Chegou', 'Em processo', 'Finalizado'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps
              .map(
                (s) => Expanded(
                  child: Text(
                    s,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 22,
          child: Row(
            children: List.generate(3, (index) {
              final bool isDone = index < etapaAtual;
              final bool isCurrent = index == etapaAtual;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 2,
                    right: index == 2 ? 0 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors
                              .blue
                        : isCurrent
                        ? Colors
                              .yellow
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
