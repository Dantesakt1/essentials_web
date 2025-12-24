import 'package:essentials_web/util/wishlist.dart';
import 'package:flutter/material.dart';

class Servicios extends StatelessWidget {
  const Servicios({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba por si una es más alta que la otra
        children: [
          // 1. TARJETA WISH LIST
          Expanded(
            child: _tarjetaServicio(
              imagen: 'assets/images/wishlist.png', // Usa el nombre exacto de tu archivo (jpg o png)
              onTap: () {
                // <--- 2. AQUÍ AGREGAS LA NAVEGACIÓN
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
              },
            ),
          ),
          
          const SizedBox(width: 25), // Espacio en el medio

          // 2. TARJETA RULETA
          Expanded(
            child: _tarjetaServicio(
              imagen: 'assets/images/ruleta.png', // Usa el nombre exacto de tu archivo
              onTap: () {
                print("Navegar a Ruleta");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaServicio({required String imagen, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      // ClipRRect redondeará las esquinas de la imagen completa
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          imagen,
          // AL QUITAR EL HEIGHT, LA IMAGEN CRECE PROPORCIONALMENTE
          fit: BoxFit.fitWidth, 
          // Esto evita que se rompa si no encuentra la imagen
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}