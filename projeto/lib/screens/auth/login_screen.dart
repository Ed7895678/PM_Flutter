import 'package:flutter/material.dart';
import '../../main.dart';
import '../../widgets/header.dart';

// Ecrã de login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para os campos de texto de email e palavra-passe
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Indica se o botão de login está desativado (enquanto está a carregar)
  bool _isLoading = false;

  // Função de login
  Future<void> _login() async {
    // Define o estado como "a carregar"
    setState(() => _isLoading = true);

    try {
      // Chamada à API para fazer login com o email e a palavra-passe
      final response = await apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Navega para o ecrã inicial se montado e login for bem-sucedido
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Mostra uma mensagem de erro caso o login falhe
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais Incorretas.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const Header(
        title: "Login",
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de entrada para o email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Campo de entrada para a palavra-passe
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Palavra-passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Oculta o texto
            ),

            const SizedBox(height: 24),

            // Botão para fazer login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login, // Desativa se estiver a carregar
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2), // Indicador de progresso
                )
                    : const Text('Entrar'),
              ),
            ),

            // Botão para o ecrã de registo
            Container(
              padding: const EdgeInsets.only(top: 24),
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Ainda não tem conta? Registe-se aqui.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
