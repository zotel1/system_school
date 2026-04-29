import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Registro de Alumno')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 80, color: Theme.of(context).primaryColor),
              SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Usuario', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              ),
              SizedBox(height: 24),
              if (authViewModel.errorMessage != null)
                Text(authViewModel.errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authViewModel.isLoading
                      ? null
                      : () async {
                          if (_usernameController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Completá todos los campos clave')));
                            return;
                          }
                          
                          final success = await authViewModel.register(
                            _usernameController.text,
                            _passwordController.text,
                            _nameController.text,
                            _lastNameController.text,
                            _emailController.text,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro exitoso. Iniciá sesión.')));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          }
                        },
                  child: authViewModel.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Registrarse', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
