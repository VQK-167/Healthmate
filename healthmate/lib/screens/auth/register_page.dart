import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        final message = error.code == 'email-already-in-use' ? 'Email này đã được sử dụng.' : error.message ?? 'Đăng ký thất bại.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tạo tài khoản.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Bắt đầu hành trình khỏe mạnh', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextFormField(controller: _nameController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline)), validator: (value) => value == null || value.trim().isEmpty ? 'Nhập họ và tên' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, autocorrect: false, enableSuggestions: false, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: (value) => value == null || !value.contains('@') ? 'Nhập email hợp lệ' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _passwordController, obscureText: _obscurePassword, autocorrect: false, enableSuggestions: false, keyboardType: TextInputType.visiblePassword, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off))), validator: (value) => value == null || value.length < 6 ? 'Mật khẩu có ít nhất 6 ký tự' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _confirmController, obscureText: true, autocorrect: false, enableSuggestions: false, keyboardType: TextInputType.visiblePassword, decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu', prefixIcon: Icon(Icons.lock_reset_outlined)), validator: (value) => value != _passwordController.text ? 'Mật khẩu chưa khớp' : null),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: _isLoading ? null : _register, child: Padding(padding: const EdgeInsets.all(12), child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Đăng ký'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
