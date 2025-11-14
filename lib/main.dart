import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petshop_pex/features/admin/home_admin.dart';
import 'package:petshop_pex/features/admin/visualizar_clientes_pets.dart';
import 'package:provider/provider.dart';

import 'features/auth/controller/auth_controller.dart';
import 'features/auth/pages/login.dart';
import 'features/pet/pages/home.dart';
import 'features/pet/pages/cadastro_pet.dart';

import 'firebase_options.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthController())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // 🔹 TEMA GLOBAL (appbar com título centralizado)
        theme: ThemeData(appBarTheme: const AppBarTheme(centerTitle: true)),

        // Login é a primeira tela
        home: const LoginPage(),
        routes: {
          AppRoutes.home: (ctx) => const HomePage(),
          AppRoutes.cadastroPet: (ctx) => const CadastroPetPage(),

          // ADMIN
          AppRoutes.agendamentosAdmin: (ctx) => const HomeAdmin(),
          AppRoutes.clientesPets: (ctx) => const ClientesPetsPage(),

          // CLIENTE
        },
      ),
    );
  }
}
