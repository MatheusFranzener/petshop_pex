import 'dart:convert';

class Pet {
  final String id;
  String nome;
  String idade;
  String raca;
  String porte;
  String imagePath; // caminho local do arquivo

  Pet({
    required this.id,
    required this.nome,
    required this.idade,
    required this.raca,
    required this.porte,
    required this.imagePath,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'] as String,
    nome: json['nome'] as String,
    idade: json['idade'] as String,
    raca: json['raca'] as String,
    porte: json['porte'] as String,
    imagePath: json['imagePath'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'idade': idade,
    'raca': raca,
    'porte': porte,
    'imagePath': imagePath,
  };

  static String encodeList(List<Pet> pets) =>
      jsonEncode(pets.map((p) => p.toJson()).toList());

  static List<Pet> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => Pet.fromJson(e as Map<String, dynamic>)).toList();
  }
}
