import 'package:flutter/material.dart';

class AppStyles {
  // Colores principales
  static const Color primaryColor = Color(0xFF3A7BDE);
  static const Color accentColor = Color(0xFF79A9FF);
  static const Color backgroundColor = Color(0xFFF9FAFF);
  static const Color darkBlue = Color(0xFF1A54B8);

  // Decoraciones generales
  static BoxDecoration circleDecoration(Color color, double opacity) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      shape: BoxShape.circle,
    );
  }
  
  static BoxDecoration logoDecoration() {
    return BoxDecoration(
      color: primaryColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.4),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );
  }
  
  static BoxDecoration formContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }
  
  static BoxDecoration errorContainerDecoration() {
    return BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.shade200),
    );
  }
  
  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
  
  static TextStyle errorTextStyle = TextStyle(
    color: Colors.red.shade700,
    fontSize: 13,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
  
  // Decoraciones de input
  static InputDecorationTheme inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
  
  static InputDecoration inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryColor),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
  
  // Estilos de botones
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: primaryColor.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,
    );
  }
  
  // Animaciones
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
  }
  
  static Animation<Offset> createSlideAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }
  
  // Tema de la aplicación
  static ThemeData appTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Poppins',
      inputDecorationTheme: inputDecorationTheme(),
    );
  }
  
  // Estilos para el menú principal
  static AppBar customAppBar() {
    return AppBar(
      backgroundColor: darkBlue,
      elevation: 0,
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar aquí',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.notifications_outlined, color: Colors.white),
        ),
      ],
    );
  }
  
  static BoxDecoration userProfileDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [darkBlue, darkBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }
  
  static BoxDecoration categoryItemDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
  
  static BoxDecoration categoryIconDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryColor, darkBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
  
  static TextStyle categoryLabelStyle() {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
  }
  
  static TextStyle dialogTitleStyle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: darkBlue,
    );
  }
  
  static BoxDecoration dialogDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    );
  }
  
  static BoxDecoration bottomNavDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, -5),
        ),
      ],
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    );
  }
  
  static BottomNavigationBarThemeData bottomNavTheme() {
    return BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    );
  }
}