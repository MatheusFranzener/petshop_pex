import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/pet_model.dart';

class AgendamentosClientePage extends StatefulWidget {
  final Pet pet;
  final List<String> services;

  const AgendamentosClientePage({
    super.key,
    required this.pet,
    required this.services,
  });

  @override
  State<AgendamentosClientePage> createState() =>
      _AgendamentosClientePageState();
}

class _AgendamentosClientePageState extends State<AgendamentosClientePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedSlot;
  late final List<TimeOfDay> _slots;

  @override
  void initState() {
    super.initState();
    _slots = _generateSlots();
  }

  bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }

  List<TimeOfDay> _generateSlots() {
    final result = <TimeOfDay>[];

    // manhã 8:00 até 12:00
    var current = const TimeOfDay(hour: 8, minute: 0);
    const morningEnd = TimeOfDay(hour: 12, minute: 0);

    while (_compareTimeOfDay(current, morningEnd) <= 0) {
      result.add(current);
      current = _add30min(current);
    }

    // tarde 13:00 até 16:30
    current = const TimeOfDay(hour: 13, minute: 0);
    const afternoonEnd = TimeOfDay(hour: 16, minute: 30);

    while (_compareTimeOfDay(current, afternoonEnd) <= 0) {
      result.add(current);
      current = _add30min(current);
    }

    return result;
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour - b.hour;
    return a.minute - b.minute;
  }

  TimeOfDay _add30min(TimeOfDay time) {
    final totalMinutes = time.hour * 60 + time.minute + 30;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _salvarAgendamento() async {
    final d = _selectedDay!;
    final horario = _selectedSlot!;

    // datetime completo do serviço
    final dataHora = DateTime(
      d.year,
      d.month,
      d.day,
      horario.hour,
      horario.minute,
    );

    final dataStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final horaStr = _formatTime(horario);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      return;
    }

    await FirebaseFirestore.instance.collection('agendamentos').add({
      'userId': user.uid,
      'petId': widget.pet.id,
      'petNome': widget.pet.nome,
      'petIdade': widget.pet.idade,
      'petRaca': widget.pet.raca,
      'petPorte': widget.pet.porte,
      'services': widget.services,
      'dataHora': Timestamp.fromDate(dataHora),
      'status': 0, // 0 = Chegou (vai ser atualizado pelo admin)
      'historico': ['Agendado para $dataStr às $horaStr'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendado ${widget.pet.nome} para $dataStr às $horaStr'),
      ),
    );

    // volta pra tela de Serviços
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // se quiser usar menu aqui depois
          },
        ),
        title: const Text(
          'Agendamentos',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PET: ${widget.pet.nome}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Serviços: ${widget.services.join(", ")}'),
            const SizedBox(height: 16),
            const Text(
              'Escolha um dia',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime(today.year, today.month, today.day),
                lastDay: DateTime(today.year + 1),
                focusedDay: _focusedDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
                enabledDayPredicate: (day) => !_isWeekend(day),
                selectedDayPredicate: (day) =>
                    _selectedDay != null &&
                    day.year == _selectedDay!.year &&
                    day.month == _selectedDay!.month &&
                    day.day == _selectedDay!.day,
                onDaySelected: (selectedDay, focusedDay) {
                  if (_isWeekend(selectedDay)) return;
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedSlot = null;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.yellow.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  weekendTextStyle: TextStyle(color: Colors.grey.shade500),
                  weekendDecoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Horários disponíveis',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_selectedDay == null)
              const Text(
                'Selecione um dia válido no calendário',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots.map((time) {
                  final isSelected = _selectedSlot == time;
                  return ChoiceChip(
                    label: Text(_formatTime(time)),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedSlot = time;
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedDay != null && _selectedSlot != null
                  ? _salvarAgendamento
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Confirmar agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
