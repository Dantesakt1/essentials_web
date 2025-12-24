import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Para acceder a la variable 'supabase'
import 'inicio.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _cargando = false;

  Future<void> _iniciarSesion() async {
    if (_usuarioController.text.isEmpty || _claveController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena los campos")),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      final emailCompleto = "${_usuarioController.text.trim()}@amor.cl";
      
      await supabase.auth.signInWithPassword(
        email: emailCompleto,
        password: _claveController.text.trim(),
      );
      
      if (mounted) {
        // AQUÍ DETENEMOS LA NAVEGACIÓN POR AHORA
        // Como no hemos creado inicio.dart, solo mostraremos un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Login Exitoso! Vamos a crear el Inicio..."), backgroundColor: Colors.green),
        );
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const Inicio())
        );

      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.message}"), backgroundColor: Colors.red),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error inesperado"), backgroundColor: Colors.red),
      );
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final tamano = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Agregué este ConstrainedBox para que el login no se vea gigante en web
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450), 
          child: SingleChildScrollView(
            child: SizedBox(
              height: tamano.height, // Ojo aquí, en web a veces conviene height fijo, pero probemos así
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 0, right: 0,
                    height: tamano.height * 0.35,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF5E1),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: tamano.height * 0.12),
                        // SI NO TIENES LAS IMÁGENES AÚN, COMENTA ESTA LÍNEA O DARÁ ERROR
                        // Image.asset('assets/images/frutilla.png', width: 80),
                        const Icon(Icons.favorite, size: 80, color: Colors.red), // Placeholder temporal

                        SizedBox(height: tamano.height * 0.25),

                        TextField(
                          controller: _usuarioController,
                          decoration: InputDecoration(
                            labelText: "Usuario",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        TextField(
                          controller: _claveController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _cargando 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Iniciar sesión", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}