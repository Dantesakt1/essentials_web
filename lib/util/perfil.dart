import 'dart:typed_data'; // IMPORTANTE: Para manejar imágenes en Web
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../pantallas/login.dart'; 

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool cargando = true;
  bool subiendoFoto = false;
  
  String? avatarUrl;
  
  // PARA WEB: Usamos bytes en memoria en vez de File
  Uint8List? _imagenBytes; 

  final miId = Supabase.instance.client.auth.currentUser?.id;

  // COLORES (Tu paleta)
  final Color colorFondo = const Color(0xFFF0F9E5); 
  final Color colorVerde = const Color(0xFFA1BC98);
  final Color colorTexto = const Color(0xFF778873);
  final Color colorBarra = const Color(0xFFD2DCB6); 

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      if (miId == null) return;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', miId!)
          .single();

      if (mounted) {
        setState(() {
          _usuarioController.text = data['username'] ?? "";
          _passwordController.text = "******"; // Placeholder visual
          avatarUrl = data['avatar_url'];
          cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => cargando = false);
    }
  }

  // --- LÓGICA DE FOTO (WEB COMPATIBLE) ---
  Future<void> _cambiarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
    
    if (imagen == null) return;

    // LEER COMO BYTES (Funciona en Web y Móvil)
    final bytes = await imagen.readAsBytes();

    setState(() {
      _imagenBytes = bytes; // Guardamos bytes para mostrar preview
      subiendoFoto = true;
    });

    try {
      final nombreArchivo = '/$miId/perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // SUBIDA BINARIA (Clave para Web)
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            nombreArchivo, 
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg')
          );

      final urlPublica = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(nombreArchivo);

      await Supabase.instance.client.from('profiles').update({
        'avatar_url': urlPublica,
      }).eq('id', miId!);

      if (mounted) {
        setState(() {
          avatarUrl = urlPublica;
          subiendoFoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto actualizada")));
      }

    } catch (e) {
      print("Error subida: $e");
      if (mounted) {
        setState(() => subiendoFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al subir la imagen")));
      }
    }
  }

  Future<void> _guardarCambios() async {
    final nuevoNombre = _usuarioController.text.trim();
    if (nuevoNombre.isEmpty) return;

    try {
      await Supabase.instance.client.from('profiles').update({
        'username': nuevoNombre,
      }).eq('id', miId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaLogin()), 
          (route) => false
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // DETECTAR ESCRITORIO
    bool esEscritorio = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: colorFondo,
      
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorTexto),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Mi Perfil", style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000), // Límite de ancho
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: esEscritorio
              ? _vistaEscritorio() // Diseño Web
              : _vistaMovil(),     // Diseño Móvil
          ),
        ),
      ),
    );
  }

  // --- VISTA ESCRITORIO (TARJETA DIVIDIDA) ---
  Widget _vistaEscritorio() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: colorTexto.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      clipBehavior: Clip.antiAlias, 
      child: IntrinsicHeight( 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IZQUIERDA: Presentación (Fondo Verde)
            Expanded(
              flex: 4,
              child: Container(
                color: colorBarra.withOpacity(0.5), 
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _avatarWidget(tamano: 180),
                    const SizedBox(height: 20),
                    Text(
                      _usuarioController.text.isEmpty ? "..." : _usuarioController.text,
                      style: TextStyle(color: colorTexto, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text("Usuario", style: TextStyle(color: colorTexto.withOpacity(0.6))),
                  ],
                ),
              ),
            ),
            
            // DERECHA: Formulario (Fondo Blanco)
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Editar información", style: TextStyle(color: colorTexto, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _formularioWidget(),
                    const SizedBox(height: 40),
                    _botonesAccion(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VISTA MÓVIL (VERTICAL) ---
  Widget _vistaMovil() {
    return Column(
      children: [
        _avatarWidget(tamano: 140),
        const SizedBox(height: 15),
        Text("Toca para cambiar foto", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 30),
        _formularioWidget(),
        const SizedBox(height: 40),
        _botonesAccion(),
      ],
    );
  }

  // --- WIDGETS COMPARTIDOS ---

  Widget _avatarWidget({required double tamano}) {
    return GestureDetector(
      onTap: subiendoFoto ? null : _cambiarFoto,
      child: Stack(
        children: [
          Container(
            width: tamano, height: tamano,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.white, width: 6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
              ],
              image: _imagenBytes != null
                  ? DecorationImage(image: MemoryImage(_imagenBytes!), fit: BoxFit.cover) // USA MEMORIA (WEB)
                  : avatarUrl != null
                      ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                      : null,
            ),
            child: _imagenBytes == null && avatarUrl == null
                ? Icon(Icons.person, size: tamano * 0.5, color: Colors.grey[400])
                : null,
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorTexto,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: subiendoFoto 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Widget _formularioWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Usuario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _usuarioController,
          style: TextStyle(color: colorTexto),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: colorVerde)),
          ),
        ),
        const SizedBox(height: 20),
        const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          readOnly: true,
          style: TextStyle(color: colorTexto),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100], 
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _botonesAccion() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _guardarCambios,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorVerde,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: _cerrarSesion,
          icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
          label: const Text("Cerrar sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }
}