import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../util/recordatorio.dart';
import '../util/notas.dart';
import '../util/estados.dart';
import '../util/servicios.dart';
import 'calendario.dart';

import '../util/perfil.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int _indiceActual = 0;
  String _nombrePareja = "Cargando...";

  @override
  void initState() {
    super.initState();
    _obtenerNombrePareja();
  }

  Future<void> _obtenerNombrePareja() async {
    try {
      final myId = Supabase.instance.client.auth.currentUser?.id;
      if (myId == null) return;
      final miPerfil = await Supabase.instance.client.from('profiles').select('partner_id').eq('id', myId).single();
      final partnerId = miPerfil['partner_id'];
      if (partnerId != null) {
        final perfilPareja = await Supabase.instance.client.from('profiles').select('nickname, username').eq('id', partnerId).single();
        if (mounted) setState(() => _nombrePareja = perfilPareja['nickname'] ?? perfilPareja['username'] ?? "Mi Pareja");
      } else {
        if (mounted) setState(() => _nombrePareja = "Sin Pareja");
      }
    } catch (e) {
      if (mounted) setState(() => _nombrePareja = "Mi Amor");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. DETECTAMOS EL TAMAÑO DE LA PANTALLA
    bool esEscritorio = MediaQuery.of(context).size.width > 900;

    // --- 1. VISTA DASHBOARD (Inicio) ---
    Widget vistaDashboard = SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          if (esEscritorio) 
            // --- VISTA PC ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  flex: 1, 
                  child: Column(
                    children: const [
                      Recordatorio(),
                      SizedBox(height: 20),
                      Notas(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  flex: 1, 
                  child: Estados(), 
                ),
              ],
            )
          else 
            // --- VISTA MÓVIL ---
            Column(
              children: const [
                Recordatorio(),
                SizedBox(height: 20),
                Notas(),
                SizedBox(height: 20),
                Estados(),
              ],
            ),

          const SizedBox(height: 50),
        ],
      ),
    );

    // --- 2. VISTA SERVICIOS ---
    Widget vistaServicios = const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Servicios(), 
          ],
        ),
      ),
    );

    final List<Widget> paginas = [
      vistaDashboard,                      
      vistaServicios,
      // <--- 2. AQUÍ CONECTAMOS EL CALENDARIO REAL ---
      const CalendarioPage(), 
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFf0f9e5),
      appBar: _barraNavegacionWeb(),
      body: Center(
        child: ConstrainedBox(
          // Si estamos en el calendario (índice 2), dejamos que use su propio ancho (1200)
          // Si no, usamos el del dashboard (1100)
          constraints: BoxConstraints(maxWidth: esEscritorio ? (_indiceActual == 2 ? 1200 : 1100) : double.infinity), 
          child: paginas[_indiceActual],
        ),
      ),
    );
  }

  PreferredSizeWidget _barraNavegacionWeb() {
    bool esEscritorio = MediaQuery.of(context).size.width > 600;

    return AppBar(
      backgroundColor: const Color(0xFFD2DCB6),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 90,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leadingWidth: 80,
      leading: Container(
        margin: const EdgeInsets.all(15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD2DCB6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset('assets/images/gato-icon.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.pets)),
      ),
      
      title: esEscritorio 
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _botonNav("Inicio", 0),
              const SizedBox(width: 10),
              _botonNav("Servicios", 1),
              const SizedBox(width: 10),
              _botonNav("Calendario", 2),
            ],
          )
        : Row( 
            mainAxisSize: MainAxisSize.min,
            children: [
              _botonIcono(Icons.home, 0),
              const SizedBox(width: 10),
              _botonIcono(Icons.grid_view_rounded, 1),
              const SizedBox(width: 10),
              _botonIcono(Icons.calendar_month, 2),
            ],
          ),

      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaPerfil()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 241, 241, 241),
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/images/heart-icon.png',
                height: 25, width: 25, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.favorite, color: Colors.red)),
          ),
        )
      ],
    );
  }

  Widget _botonNav(String titulo, int index) {
    bool activo = _indiceActual == index;
    return TextButton(
      onPressed: () => setState(() => _indiceActual = index),
      style: TextButton.styleFrom(
        backgroundColor: activo ? Colors.white.withOpacity(0.4) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        titulo,
        style: TextStyle(
          color: const Color(0xFF778873),
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _botonIcono(IconData icono, int index) {
    bool activo = _indiceActual == index;
    return IconButton(
      onPressed: () => setState(() => _indiceActual = index),
      style: IconButton.styleFrom(
        backgroundColor: activo ? Colors.white.withOpacity(0.4) : null,
      ),
      icon: Icon(icono, color: const Color(0xFF778873)),
    );
  }
}