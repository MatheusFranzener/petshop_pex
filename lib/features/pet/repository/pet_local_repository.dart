import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_model.dart';

class PetLocalRepository {
  static const _key = 'pets';

  Future<List<Pet>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return Pet.decodeList(raw);
  }

  Future<void> _saveAll(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Pet.encodeList(pets));
  }

  Future<void> add(Pet pet) async {
    final pets = await load();
    pets.add(pet);
    await _saveAll(pets);
  }

  Future<void> update(Pet pet) async {
    final pets = await load();
    final idx = pets.indexWhere((p) => p.id == pet.id);
    if (idx != -1) {
      pets[idx] = pet;
      await _saveAll(pets);
    }
  }

  Future<void> delete(Pet pet) async {
    final pets = await load();
    pets.removeWhere((p) => p.id == pet.id);
    await _saveAll(pets);
    // apaga a foto local (se existir)
    try {
      final file = File(pet.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
