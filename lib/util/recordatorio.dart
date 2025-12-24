import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Recordatorio extends StatefulWidget {
  const Recordatorio({super.key});

  @override
  State<Recordatorio> createState() => _RecordatorioState();
}

class _RecordatorioState extends State<Recordatorio> {
  Map<String, dynamic>? eventoMasCercano;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerEvento();
  }

  Future<void> _obtenerEvento() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await Supabase.instance.client
          .from('events')
          .select()
          .gte('start_time', now)
          .order('start_time', ascending: true)
          .limit(1);

      if (mounted) {
        setState(() {
          eventoMasCercano = response.isNotEmpty ? response[0] : null;
          cargando = false;
        });
      }
    } catch (e) {
      print("Error buscando evento: $e");
      if (mounted) setState(() => cargando = false);
    }
  }

  String _formatearFecha(String fechaIso) {
    try {
      final fecha = DateTime.parse(fechaIso);
      return DateFormat('dd/MM - HH:mm').format(fecha);
    } catch (e) {
      return "--/--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xffA1BC98),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/recordatory-icon.png',
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (c,e,s) => const Icon(Icons.calendar_today, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 50,
                      offset: const Offset(0, 5))
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: cargando
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : eventoMasCercano == null
                      ? const Column(
                          children: [
                            Text("Sin planes próximos",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("¡Añade uno en el calendario!",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              _formatearFecha(eventoMasCercano!['start_time']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              eventoMasCercano!['title'] ?? "Evento",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 99, 99, 99),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}