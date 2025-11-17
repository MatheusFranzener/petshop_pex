import 'package:flutter/material.dart';
import 'package:petshop_pex/features/admin/pages/home_admin.dart';
import 'package:petshop_pex/features/admin/pages/visualizar_clientes_pets.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';
import 'package:petshop_pex/features/cliente/pages/servicos_cliente.dart';
import 'package:petshop_pex/features/cliente/pages/status_pets_page.dart';
import 'package:petshop_pex/features/pet/models/pet_model.dart';
import 'package:petshop_pex/features/pet/pages/cadastro_pet.dart';
import 'package:petshop_pex/features/pet/pages/home.dart';
import 'package:provider/provider.dart';

class MainNavMenuButton extends StatelessWidget {
  final List<Pet> pets;

  const MainNavMenuButton({
    super.key, required this.pets
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Colors.black),
      onPressed: () => _openMenu(context),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final parentContext = context;

    final auth = Provider.of<AuthController>(parentContext, listen: false);
    final isAdmin = await auth.isCurrentUserAdmin();

    if (!parentContext.mounted) return;

    showModalBottomSheet(
      context: parentContext,
      builder: (sheetContext) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Meus Pets'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.pushReplacement(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Cadastrar pets'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await Navigator.push(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const CadastroPetPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.miscellaneous_services),
              title: const Text('Serviços'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => ServicosClientePage(pets: pets),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Status'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => StatusPetsPage(pets: pets),
                  ),
                );
              },
            ),

            const Divider(),

            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Agendamentos Clientes'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(builder: (_) => const HomeAdmin()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Clientes e Pets'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(builder: (_) => const ClientesPetsPage()),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}