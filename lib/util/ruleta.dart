import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:rxdart/rxdart.dart';

class RuletaPage extends StatefulWidget {
  const RuletaPage({super.key});

  @override
  State<RuletaPage> createState() => _RuletaPageState();
}

class _RuletaPageState extends State<RuletaPage> {
  final selected = BehaviorSubject<int>();
  final TextEditingController _textController = TextEditingController();

  List<String> items = [];
  int _ganadorIndex = 0;

  // --- PALETA DE COLORES ---
  final Color colorFondo = const Color(0xFFF1F3E0);
  final Color colorAcentoClaro = const Color(0xFFD2DCB6);
  final Color colorAcentoMedio = const Color(0xFFA1BC98);
  final Color colorTexto = const Color(0xFF778873);

  @override
  void dispose() {
    selected.close();
    _textController.dispose();
    super.dispose();
  }

  void _agregarOpcion() {
    String texto = _textController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        items.add(texto);
        _textController.clear();
      });
    }
  }

  void _eliminarOpcion(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _girarRuleta() {
    if (items.length < 2) return;

    setState(() {
      _ganadorIndex = Random().nextInt(items.length);
      selected.add(_ganadorIndex);
    });
  }

  void _mostrarGanador() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Tenemos un ganador", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: colorTexto)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/ganador.png', // Asegúrate de tener esta imagen o cambiarla
                height: 80, 
                fit: BoxFit.contain,
                errorBuilder: (_,__,___) => Icon(Icons.star, size: 60, color: colorAcentoClaro),
              ),
              const SizedBox(height: 15),
              Text(
                items[_ganadorIndex],
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: colorTexto 
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Genial", style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos si es Web (pantalla ancha)
    bool esWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: colorFondo,
      
      // --- APPBAR (Estilo consistente) ---
      appBar: AppBar(
        backgroundColor: colorAcentoClaro,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leadingWidth: 80,
        leading: Container(
          margin: const EdgeInsets.all(15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorAcentoClaro,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset('assets/images/gato-icon.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.pets)),
        ),
        title: Text("Ruleta", style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, color: colorTexto, size: 20),
            ),
          )
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200), // Ancho máximo para web
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: esWeb ? _vistaWeb() : _vistaMovil(),
          ),
        ),
      ),
    );
  }

  // --- VISTA WEB (IZQUIERDA: RULETA | DERECHA: CONTROLES) ---
  Widget _vistaWeb() {
    return Row(
      children: [
        // 1. RULETA (Izquierda)
        Expanded(
          flex: 1,
          child: items.length < 2
              ? _EmptyStateRuleta(colorTexto: colorTexto, colorIcono: colorAcentoClaro)
              : Padding(
                  padding: const EdgeInsets.all(40.0), // Margen para que respire
                  child: AspectRatio( // Mantiene la ruleta redonda
                    aspectRatio: 1,
                    child: FortuneWheel(
                      selected: selected.stream,
                      animateFirst: false,
                      onAnimationEnd: _mostrarGanador,
                      items: [
                        for (int i = 0; i < items.length; i++)
                          FortuneItem(
                            child: Text(
                              items[i], 
                              style: TextStyle(
                                color: (i % 2 == 0) ? colorTexto : Colors.white, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                            style: FortuneItemStyle(
                              color: (i % 2 == 0) ? colorAcentoClaro : colorTexto, 
                              borderColor: colorFondo,
                              borderWidth: 3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),

        const SizedBox(width: 40),

        // 2. CONTROLES (Derecha)
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Opciones de la Suerte", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorTexto)),
              const SizedBox(height: 20),
              _panelControles(), // Reutilizamos el panel de controles
            ],
          ),
        ),
      ],
    );
  }

  // --- VISTA MÓVIL (VERTICAL) ---
  Widget _vistaMovil() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: items.length < 2
                ? _EmptyStateRuleta(colorTexto: colorTexto, colorIcono: colorAcentoClaro)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      FortuneWheel(
                        selected: selected.stream,
                        animateFirst: false,
                        onAnimationEnd: _mostrarGanador,
                        items: [
                          for (int i = 0; i < items.length; i++)
                            FortuneItem(
                              child: Text(
                                items[i], 
                                style: TextStyle(
                                  color: (i % 2 == 0) ? colorTexto : Colors.white, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              style: FortuneItemStyle(
                                color: (i % 2 == 0) ? colorAcentoClaro : colorTexto, 
                                borderColor: colorFondo,
                                borderWidth: 3,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),
        _panelControles(), // Panel abajo en móvil
      ],
    );
  }

  // --- PANEL DE CONTROLES (INPUT + LISTA + BOTÓN) ---
  Widget _panelControles() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Redondeado completo
        boxShadow: [
          BoxShadow(
            color: colorTexto.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: colorFondo, 
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(color: colorTexto),
                    decoration: InputDecoration(
                      hintText: "Agregar opción.. ≽(•⩊ •マ≼",
                      hintStyle: TextStyle(color: colorAcentoMedio),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _agregarOpcion(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _agregarOpcion,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorTexto, 
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              )
            ],
          ),
          
          const SizedBox(height: 15),

          // Lista de Chips (Opciones)
          if (items.isNotEmpty)
            Container(
              height: 50, // Altura fija para el scroll horizontal
              alignment: Alignment.centerLeft,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Chip(
                    label: Text(items[index], style: TextStyle(color: colorTexto, fontSize: 12, fontWeight: FontWeight.bold)),
                    backgroundColor: colorAcentoClaro,
                    deleteIcon: Icon(Icons.close, size: 16, color: colorTexto.withOpacity(0.6)),
                    onDeleted: () => _eliminarOpcion(index),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          // BOTÓN GIRAR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: items.length < 2 ? null : _girarRuleta,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTexto, 
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                disabledBackgroundColor: colorAcentoMedio.withOpacity(0.5),
              ),
              child: const Text(
                "¡GIRAR!", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para cuando no hay opciones
class _EmptyStateRuleta extends StatelessWidget {
  final Color colorTexto;
  final Color colorIcono;
  const _EmptyStateRuleta({required this.colorTexto, required this.colorIcono});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 80, color: colorIcono),
          const SizedBox(height: 20),
          Text(
            "Agrega al menos 2 opciones\npara girar la ruleta",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorTexto.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}