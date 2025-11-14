import 'package:flutter/material.dart';
import 'package:petshop_pex/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';

class FloatingNavButton extends StatelessWidget {
  const FloatingNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar se o usuário é admin
    final authController = Provider.of<AuthController>(context);

    return FutureBuilder<bool>(
      future: authController.isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == false) {
          // Se não for admin, não exibe o botão
          return const SizedBox();
        }

        return FloatingActionButton(
          backgroundColor: Colors.yellow,
          onPressed: () {
            _showNavigationMenu(context);
          },
          child: const Icon(Icons.menu, color: Colors.blue),
        );
      },
    );
  }

  void _showNavigationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildMenuItem(context, 'Meus Pets', AppRoutes.home),
            // ADMIN
            _buildMenuItem(
              context,
              'Agendamentos Clientes',
              AppRoutes.agendamentosAdmin, // <- aqui trocou
            ),
            _buildMenuItem(context, 'Clientes e Pets', AppRoutes.clientesPets),
          ],
        );
      },
    );
  }

  ListTile _buildMenuItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
