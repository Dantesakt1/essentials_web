import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final miId = Supabase.instance.client.auth.currentUser?.id;
  String _nombrePareja = "...";
  String? _idPareja;

  // Controladores
  final _tituloController = TextEditingController();
  final _precioController = TextEditingController();
  final _linkController = TextEditingController();

  // Colores
  final Color colorFondo = const Color(0xFFF0F9E5);
  final Color colorVerde = const Color(0xFFA1BC98);
  final Color colorTexto = const Color(0xFF778873);
  final Color colorBarra = const Color(0xFFD2DCB6);

  @override
  void initState() {
    super.initState();
    _obtenerDatosPareja();
  }

  Future<void> _obtenerDatosPareja() async {
    try {
      if (miId == null) return;
      final dataYo = await Supabase.instance.client.from('profiles').select('partner_id').eq('id', miId!).single();
      _idPareja = dataYo['partner_id'];

      if (_idPareja != null) {
        final dataPareja = await Supabase.instance.client.from('profiles').select('nickname').eq('id', _idPareja!).single();
        if (mounted) setState(() => _nombrePareja = dataPareja['nickname'] ?? "Tu pareja");
      }
    } catch (e) { print(e); }
  }

  // --- LÓGICA BD ---
  Future<void> _guardarDeseo({int? idEdicion}) async {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) return;

    try {
      final datos = {
        'user_id': miId,
        'title': titulo,
        'price_estimate': double.tryParse(_precioController.text) ?? 0.0,
        'link_url': _linkController.text.trim(),
        'is_fulfilled': false,
      };

      if (idEdicion != null) {
        await Supabase.instance.client.from('wishes').update(datos).eq('id', idEdicion);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Deseo actualizado! ✨")));
      } else {
        await Supabase.instance.client.from('wishes').insert(datos);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Deseo agregado! ✨")));
      }

      _tituloController.clear(); _precioController.clear(); _linkController.clear();
      if (mounted) Navigator.pop(context);
      
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"))); 
    }
  }

  Future<void> _borrarDeseo(int id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("¿Borrar deseo.. ( °ヮ° ) ?"),
        content: const Text("Se eliminará de tu lista."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await Supabase.instance.client.from('wishes').delete().eq('id', id);
          }, child: Text("Borrar", style: TextStyle(color: colorVerde))),
        ],
      )
    );
  }

  Future<void> _cumplirDeseo(int id, bool estadoActual) async {
    await Supabase.instance.client.from('wishes').update({
      'is_fulfilled': !estadoActual,
      'fulfilled_by': !estadoActual ? miId : null,
    }).eq('id', id);
  }

  void _mostrarDialogo({Map<String, dynamic>? deseoEditar}) {
    if (deseoEditar != null) {
      _tituloController.text = deseoEditar['title'];
      _precioController.text = deseoEditar['price_estimate']?.toString() ?? "";
      _linkController.text = deseoEditar['link_url'] ?? "";
    } else {
      _tituloController.clear(); _precioController.clear(); _linkController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(deseoEditar != null ? "Editar deseo" : "Nuevo deseo", style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _tituloController, decoration: InputDecoration(hintText: "¿Qué deseas?", prefixIcon: Icon(Icons.star_border, color: colorVerde), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 10),
            TextField(controller: _precioController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Precio aprox", prefixIcon: Icon(Icons.attach_money, color: colorVerde), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 10),
            TextField(controller: _linkController, decoration: InputDecoration(hintText: "Link (opcional)", prefixIcon: Icon(Icons.link, color: colorVerde), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => _guardarDeseo(idEdicion: deseoEditar?['id']),
            style: ElevatedButton.styleFrom(backgroundColor: colorVerde, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
            child: Text(deseoEditar != null ? "Actualizar" : "Guardar", style: const TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _verHistorialPareja() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Center(
        child: Container(
          width: 600, // Ancho máximo controlado para web
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("Deseos de $_nombrePareja ❤️", style: TextStyle(color: colorTexto, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Toca el cuadro para marcar como cumplido", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 15),

              Expanded(
                child: _idPareja == null 
                  ? const Center(child: Text("Vincula a tu pareja primero."))
                  : StreamBuilder(
                      stream: Supabase.instance.client.from('wishes').stream(primaryKey: ['id']).eq('user_id', _idPareja!).order('created_at'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final deseos = snapshot.data as List<dynamic>;
                        if (deseos.isEmpty) return const Center(child: Text("Aún no ha pedido nada...", style: TextStyle(color: Colors.grey)));
                        return ListView.builder(
                          itemCount: deseos.length,
                          itemBuilder: (context, index) {
                            return _buildWishCard(deseos[index], false);
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      
      // BARRA ESTILO INICIO (PERO CON BOTÓN ATRÁS)
      appBar: AppBar(
        backgroundColor: colorBarra,
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
            color: colorBarra,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset('assets/images/gato-icon.png', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.pets)),
        ),
        title: Text("Wishlist", style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 241, 241, 241),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, color: colorTexto, size: 20),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogo(),
        backgroundColor: colorVerde,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Agregar deseo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Ancho estilo móvil
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BOTÓN PAREJA
                GestureDetector(
                  onTap: _verHistorialPareja,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: colorVerde.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: colorVerde.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, color: colorVerde),
                        const SizedBox(width: 10),
                        Text("Ver deseos de $_nombrePareja", style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 10),
                        Icon(Icons.keyboard_arrow_down, color: colorTexto.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                
                // 2. TÍTULO
                Text("Mis deseos /ᐠ˵- ⩊ -˵マ", style: TextStyle(color: colorTexto, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // 3. MI LISTA (LÓGICA DEL GATO 🐱)
                Expanded(
                  child: StreamBuilder(
                    stream: Supabase.instance.client.from('wishes').stream(primaryKey: ['id']).eq('user_id', miId!).order('created_at'),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final deseos = snapshot.data as List<dynamic>;
                      
                      // CASO 1: LISTA VACÍA -> Gato Gigante Centrado
                      if (deseos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: 0.8,
                                child: Image.asset(
                                  'assets/images/carrito.png', 
                                  height: 150, 
                                  fit: BoxFit.contain,
                                  errorBuilder: (c,e,s) => Icon(Icons.shopping_cart, size: 80, color: Colors.grey[300]),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text("¡Pide un deseo!", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        );
                      }

                      // CASO 2 y 3: Hay elementos -> ListView
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        // Agregamos +1 al conteo para el espacio del gato final
                        itemCount: deseos.length + 1,
                        itemBuilder: (context, index) {
                          
                          // SI ES EL ÚLTIMO ELEMENTO (EL FOOTER)
                          if (index == deseos.length) {
                            // Solo mostramos el gato si hay 3 o menos deseos
                            if (deseos.length <= 3) {
                              return Column(
                                children: [
                                  const SizedBox(height: 30), // Espacio para separarlo
                                  Opacity(
                                    opacity: 0.6, // Un poco más transparente
                                    child: Image.asset(
                                      'assets/images/carrito.png',
                                      height: 100, // Más pequeño que el principal
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text("¡Sigue añadiendo!", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 20),
                                ],
                              );
                            } else {
                              return const SizedBox(); // Si hay más de 3, no mostramos nada
                            }
                          }

                          // SI NO, ES UNA TARJETA NORMAL
                          return _buildWishCard(deseos[index], true);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWishCard(Map<String, dynamic> item, bool esMio) {
    bool cumplido = item['is_fulfilled'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF5A3E3E).withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
        border: cumplido ? Border.all(color: Colors.green.shade200, width: 2) : null,
      ),
      child: Row(
        children: [
          // Checkbox / Regalo
          GestureDetector(
            onTap: !esMio ? () => _cumplirDeseo(item['id'], cumplido) : null,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cumplido ? Colors.green.shade50 : (esMio ? const Color(0xFFFFF0F0) : const Color(0xFFF0F7FF)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                cumplido ? Icons.check_circle_rounded : (esMio ? Icons.card_giftcard_rounded : Icons.check_box_outline_blank_rounded),
                color: cumplido ? Colors.green : (esMio ? colorVerde : Colors.grey),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorTexto, decoration: cumplido ? TextDecoration.lineThrough : null),
                ),
                if (item['price_estimate'] != null && item['price_estimate'] > 0)
                  Text("\$${item['price_estimate']}", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Botones de edición
          if (esMio)
            Row(
              children: [
                InkWell(onTap: () => _mostrarDialogo(deseoEditar: item), child: Container(padding: const EdgeInsets.all(6), child: Icon(Icons.edit_rounded, size: 20, color: Colors.grey[400]))),
                InkWell(onTap: () => _borrarDeseo(item['id']), child: Container(padding: const EdgeInsets.all(6), child: Icon(Icons.delete_rounded, size: 20, color: colorVerde.withOpacity(0.7)))),
              ],
            )
        ],
      ),
    );
  }
}