// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../widgets/header.dart';

// Ecrã de registo
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para os campos de input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Indica se o botão de registo está desativado (enquanto está a carregar)
  bool _isLoading = false;

  // Função de registo
  Future<void> _register() async {
    // Define o estado como "a carregar"
    setState(() => _isLoading = true);

    try {
      // Chamada à API para registar com os dados fornecidos
      await apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // Navega para o ecrã inicial se registo for bem-sucedido
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Mostra uma mensagem de erro em caso de falha
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no registo: $e')),
        );
      }
    } finally {
      // Redefine o estado como "não está a carregar"
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const Header(
        title: "Registo",
      ),

      // Corpo do ecrã
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Campo de entrada para o nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),

            // Campo de entrada para o email
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            // Campo de entrada para a palavra-passe
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Palavra-passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Oculta a palavra-passe
            ),

            // Botão para realizar o registo
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register, // Desativa se estiver a carregar
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2), // Indicador de progresso
                )
                    : const Text('Registar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
