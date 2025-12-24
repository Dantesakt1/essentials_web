import 'package:flutter/material.dart';
import 'package:essentials_web/util/ruleta.dart';
import 'package:essentials_web/util/wishlist.dart';

class Servicios extends StatelessWidget {
  const Servicios({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Detectamos el ancho de la pantalla
    // Usamos 900px como punto de quiebre (puedes ajustarlo)
    bool esPantallaGrande = MediaQuery.of(context).size.width > 900;

    // 2. Definimos las tarjetas primero para no repetir código
    Widget tarjetaWishlist = _tarjetaServicio(
      imagen: 'assets/images/wishlist.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WishlistPage()),
        );
      },
    );

    Widget tarjetaRuleta = _tarjetaServicio(
      imagen: 'assets/images/ruleta.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RuletaPage()),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: esPantallaGrande
          ? _vistaPC(tarjetaWishlist, tarjetaRuleta)      // Diseño Horizontal
          : _vistaCelular(tarjetaWishlist, tarjetaRuleta), // Diseño Vertical
    );
  }

  // --- ESTRUCTURA PARA PC (Una al lado de la otra) ---
  Widget _vistaPC(Widget card1, Widget card2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: card1),
        const SizedBox(width: 25), // Separación horizontal
        Expanded(child: card2),
      ],
    );
  }

  // --- ESTRUCTURA PARA CELULAR (Una encima de la otra) ---
  Widget _vistaCelular(Widget card1, Widget card2) {
    return Column(
      children: [
        card1,
        const SizedBox(height: 25), // Separación vertical
        card2,
      ],
    );
  }

  // --- TU TARJETA CON SOMBRA SUAVE (SIN CAMBIOS) ---
  Widget _tarjetaServicio({required String imagen, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            imagen,
            fit: BoxFit.fitWidth, // Se adapta al ancho disponible
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}