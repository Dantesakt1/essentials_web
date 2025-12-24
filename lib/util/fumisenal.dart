import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'; //
import 'dart:convert';

class FumisenalWidget extends StatefulWidget {
  const FumisenalWidget({super.key});

  @override
  State<FumisenalWidget> createState() => _FumisenalWidgetState();
}

class _FumisenalWidgetState extends State<FumisenalWidget> {
  bool _enviando = false;
  String? _miWebhookUrl; // Aquí guardaremos la URL específica del usuario

  // COLORES
  final Color colorFondo = const Color(0xFFF0F9E5); 
  final Color colorBorde = const Color(0xFFA1BC98);
  final Color colorBoton = const Color(0xFF778873);

  // --- GATO ASCII (Raw String) ---
  static const String gatoAscii = r'''
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠒⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢠⠶⠚⠛⠲⠦⣤⣀⡤⠏⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⣀⣀⣀⣠⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⡴⠒⢦⡉⢲⣦⡀⢠⠟⠀⠀⠀⠀⠀⠀⣠⣶⡆⠀⠀⠀⢀⠀⠀⠀
⠀⣰⠋⠀⠀⠀⢹⠊⢠⠔⠛⢢⡀⠀⠀⠀⢠⣾⣿⣿⣿⠀⢀⣴⣿⣆⠀⠀
⠀⢿⠀⠀⠀⠀⠸⡀⠈⢤⠤⠼⠁⠀⠀⣰⣿⣿⣿⣿⣿⠀⣾⣿⣿⣿⡀⠀
⠀⠈⠣⣀⡀⠀⠀⠀⠀⠀⣆⠀⣀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀
⠀⠀⠀⣳⠀⠀⠀⡴⠞⢲⡗⠀⠈⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀
⢰⠳⠚⠁⠊⢰⠛⠣⠀⠘⠀⠐⠛⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀
⢸⠀⠀⠀⠀⠘⠦⢼⡆⠀⠀⠀⠀⣀⣠⣜⢿⣿⣿⣿⣿⣶⣿⣿⣿⣿⣧⠀
⠈⠳⠤⢴⠀⡴⠤⠞⣀⡤⠐⠀⠉⠀⠀⣸⠖⢩⣾⣶⣿⣿⣿⣷⠈⠁⠈⠁
⠀⠀⠀⠈⠳⣇⣴⣾⣧⢄⠀⠀⢀⡠⠈⠁⠀⣾⢻⣿⣿⣿⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠳⣿⣿⣷⣀⠄⠈⠀⠀⠀⠘⠁⠸⣿⣿⣿⣿⡏⠃⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠙⠿⠝⠁⠀⠀⠀⠀⠀⠀⠀⠀⠋⠉⠙⢿⡧⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠀''';

  @override
  void initState() {
    super.initState();
    _cargarWebhookUsuario(); // Cargar la URL al iniciar
  }

  // Lógica para obtener el webhook desde Supabase
  Future<void> _cargarWebhookUsuario() async {
    try {
      final myId = Supabase.instance.client.auth.currentUser?.id;
      if (myId == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select('webhook_url') // Seleccionamos la columna nueva
          .eq('id', myId)
          .single();

      if (mounted) {
        setState(() {
          _miWebhookUrl = data['webhook_url']; // Guardamos la URL
        });
      }
    } catch (e) {
      print("Error cargando webhook: $e");
    }
  }

  Future<void> _mandarFumisenal() async {
    // Validamos si tenemos la URL
    if (_miWebhookUrl == null || _miWebhookUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("⚠️ Configura el Webhook en tu perfil de Supabase (columna webhook_url)"),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _enviando = true);

    try {
      final mensaje = {
        "content": "**SE ACTIVÓ LA FUMISEÑAL (◝ ⩊ ◜) 𖠞༄**\n\n```\n$gatoAscii\n```\nFumemos mota juntos amor @everyone",
        "username": "Gato fumeta",
        "avatar_url": "https://media.tenor.com/AroWWAxsk-gAAAAM/cat-weed.gif"
      };

      // Usamos la URL cargada desde la base de datos
      final response = await http.post(
        Uri.parse(_miWebhookUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mensaje),
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Señal enviada al Discord!")));
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Discord: ${response.statusCode}")));
      }

    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: colorBorde.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_active_rounded, color: colorBoton),
              const SizedBox(width: 8),
              Text("Fumiseñal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorBoton)),
            ],
          ),
          
          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/enrolar.gif', 
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(
                height: 120, 
                color: colorFondo, 
                child: Center(child: Icon(Icons.emergency_share, size: 50, color: colorBorde))
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Deshabilitamos si no hay URL o si se está enviando
              onPressed: (_enviando || _miWebhookUrl == null) ? null : _mandarFumisenal,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorBoton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _enviando 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_miWebhookUrl == null ? "Cargando..." : "¡TE INVOCO!", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          )
        ],
      ),
    );
  }
}