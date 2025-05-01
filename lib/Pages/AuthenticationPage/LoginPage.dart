import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/services/AuthenticationService/LoginServices.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF3D3D3D), Color(0xFFB00034)],
          ),
        ),
        child: _page(),
      ),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _icon(),
            const SizedBox(height: 50),
            _inputField("Kullanıcı Adı", usernameController),
            const SizedBox(height: 20),
            _inputField("Şifre", passwordController, isPassword: true),
            const SizedBox(height: 50),
            _loginBtn(),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 100),
    );
  }

  Widget _inputField(
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.white),
    );
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: () async {
        final username = usernameController.text.trim();
        final password = passwordController.text.trim();

        final loginServices = LoginServices();
        final response = await loginServices.login(username, password);

        if (response != null) {
          final item = response.item!;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('apiKey', item.apiKey);
          await prefs.setString('apiSecret', item.apiSecret);
          await prefs.setString('subscriptionType', item.subscriptionType.name);
          await prefs.setBool('isEInvoiceActive', item.isEInvoiceActive);

          debugPrint("Giriş Başarılı");
          debugPrint(prefs.getString('apiKey'));
          debugPrint(prefs.getString('apiSecret'));
          debugPrint(prefs.getString('subscriptionType'));
          debugPrint(prefs.getBool('isEInvoiceActive').toString());

          if (mounted) {
            context.go('/');
          }
        } else {
          debugPrint("Giriş Başarısız");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB00034),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Giriş Yap",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
