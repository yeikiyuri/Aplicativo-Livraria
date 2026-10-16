
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview_plus/device_preview_plus.dart';

import 'view/cadastro_usuario_view.dart';
import 'view/home_view.dart';
import 'view/login_view.dart';
import 'view/perfil_view.dart';
import 'view/recuperar_senha_view.dart';
import 'view/sobre_view.dart';

void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MainApp(),
  ),
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'loja de livros',
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7A4E35),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F5F0),
          appBarTheme: const AppBarTheme(centerTitle: false),
          inputDecorationTheme:
              const InputDecorationTheme(filled: true),
        ),

        initialRoute: 'login',
        routes: {
          'login': (_) => const LoginView(),
          'cadastro_usuario': (_) => const CadastroUsuarioView(),
          'perfil': (_) => const PerfilView(),
          'recuperar_senha': (_) => const RecuperarSenhaView(),
          'sobre': (_) => const SobreView(),
          'home': (_) => const HomeView(),
        },
        onUnknownRoute: (_) => MaterialPageRoute(
          builder: (_) => const LoginView(),
        ),
      );
}
