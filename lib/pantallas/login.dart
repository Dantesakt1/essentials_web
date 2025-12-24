import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inicio.dart'; 

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // --- CONTROLADORES Y ESTADO ---
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _cargando = false;

  // --- COLORES (Paleta Verde/Beige de la foto) ---
  final Color colorFondoSuperior = const Color(0xFFA1BC98); // Verde medio arriba
  final Color colorFondoInferior = const Color(0xFFD2DCB6); // Verde claro abajo
  final Color colorTarjeta = const Color(0xFFF0F9E5);       // Beige muy clarito
  final Color colorTexto = const Color(0xFF778873);         // Verde oscuro (Textos y Botón)
  final Color colorBorde = const Color(0xFF778873);         // Borde de inputs

  // --- TU LÓGICA DE LOGIN ORIGINAL ---
  Future<void> _iniciarSesion() async {
    if (_usuarioController.text.isEmpty || _claveController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena los campos")),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      // AQUÍ ESTÁ TU LÓGICA DE @AMOR.CL
      final emailCompleto = "${_usuarioController.text.trim()}@amor.cl";
      
      // Usamos Supabase.instance.client que es la forma estándar
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailCompleto,
        password: _claveController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Hola amor ヾ(＾∇＾)!"), backgroundColor: Color(0xFF778873)),
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
    return Scaffold(
      // Stack para poner el fondo detrás y el formulario delante
      body: Stack(
        children: [
          // 1. FONDO DE ONDAS
          SizedBox.expand(
            child: CustomPaint(
              painter: FondoOndasPainter(
                colorArriba: colorFondoSuperior,
                colorAbajo: colorFondoInferior,
              ),
            ),
          ),

          // 2. FORMULARIO CENTRADO Y RESPONSIVO
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Si el ancho es mayor a 600px, es PC/Tablet, limitamos el ancho.
                // Si es móvil, usamos un porcentaje del ancho (90%).
                bool esPantallaGrande = constraints.maxWidth > 600;
                double anchoTarjeta = esPantallaGrande ? 400 : constraints.maxWidth * 0.85;

                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: anchoTarjeta),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    decoration: BoxDecoration(
                      color: colorTarjeta,
                      borderRadius: BorderRadius.circular(20), // Bordes redondeados de la tarjeta
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                      children: [
                        // IMAGEN DEL GATO
                        Image.asset(
                          'assets/images/gato-icon.png',
                          height: 70,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Icon(Icons.pets, size: 60, color: colorTexto),
                        ),
                        const SizedBox(height: 15),

                        // TÍTULO
                        Text(
                          "Bienvenid@",
                          style: TextStyle(
                            color: colorTexto,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // INPUT USUARIO
                        _buildInput(
                          controller: _usuarioController,
                          hintText: "Usuario..",
                        ),
                        
                        const SizedBox(height: 15),

                        // INPUT CONTRASEÑA
                        _buildInput(
                          controller: _claveController,
                          hintText: "Contraseña...",
                          obscureText: true,
                        ),

                        const SizedBox(height: 30),

                        // BOTÓN "Next >"
                        SizedBox(
                          width: 150, // Botón pequeño tipo píldora
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorTexto, // Verde oscuro
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _cargando
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Login >", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los inputs redondos
  Widget _buildInput({required TextEditingController controller, required String hintText, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: colorTexto),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colorTexto.withOpacity(0.5), fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorBorde.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: colorBorde, width: 2),
        ),
      ),
    );
  }
}

// --- PINTOR DE ONDAS (FONDO) ---
class FondoOndasPainter extends CustomPainter {
  final Color colorArriba;
  final Color colorAbajo;

  FondoOndasPainter({required this.colorArriba, required this.colorAbajo});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Pintar todo el fondo con el color de abajo (Verde claro)
    paint.color = colorAbajo;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Pintar la onda superior (Verde medio)
    paint.color = colorArriba;
    final path = Path();
    
    // Empezamos arriba a la izquierda
    path.moveTo(0, 0);
    // Vamos hasta abajo a la izquierda (pero no hasta el fondo, altura variable)
    path.lineTo(0, size.height * 0.6);

    // Dibujamos la curva suave
    path.quadraticBezierTo(
      size.width * 0.5,      // Punto de control X (centro)
      size.height * 0.4,     // Punto de control Y (sube)
      size.width,            // Punto final X (derecha)
      size.height * 0.65     // Punto final Y (baja un poco)
    );

    // Cerramos arriba a la derecha
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}