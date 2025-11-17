import 'package:flutter/material.dart';

class AgendamentoCard extends StatelessWidget {
  final String foto;
  final String nomePet;
  final String servico;
  final String dataHora;
  final String status;
  final String funcionario;
  final String observacoes;
  final VoidCallback? onTap;

  const AgendamentoCard({
    super.key,
    required this.foto,
    required this.nomePet,
    required this.servico,
    required this.dataHora,
    required this.status,
    required this.funcionario,
    required this.observacoes,
    this.onTap,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'chegou':
        return Colors.orange;
      case 'em processo':
        return Colors.blue;
      case 'finalizado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (foto.isNotEmpty)
                ? Image.network(foto, width: 56, height: 56, fit: BoxFit.cover)
                : Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Icon(Icons.pets),
            ),
          ),
          title: Text(
            nomePet.isEmpty ? '—' : nomePet,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(servico.isEmpty ? '—' : servico),
              const SizedBox(height: 4),
              Text(
                dataHora,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
