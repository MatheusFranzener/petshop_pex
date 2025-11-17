import 'dart:io';
import 'package:flutter/material.dart';

class ClientePetCard extends StatelessWidget {
  final String imagePath;
  final String nome;
  final String nomeDono;
  final String idade;
  final String raca;
  final String porte;

  const ClientePetCard({
    super.key,
    required this.imagePath,
    required this.nome,
    required this.nomeDono,
    required this.idade,
    required this.raca,
    required this.porte,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (imagePath.isNotEmpty && File(imagePath).existsSync())
              ? Image.file(
            File(imagePath),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          )
              : Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const Icon(Icons.pets),
          ),
        ),
        title: Text(
          '$nome - $nomeDono',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Idade: $idade'),
            Text('Raça: $raca'),
            Text('Porte: $porte'),
          ],
        ),
      ),
    );
  }
}
