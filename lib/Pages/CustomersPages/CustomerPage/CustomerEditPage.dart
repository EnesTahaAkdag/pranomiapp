import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerEditModel.dart';
import 'package:pranomiapp/services/CustomerService/CustomerEditService.dart';

class CustomerEditPage extends StatefulWidget {
  final String customerId;

  const CustomerEditPage({super.key, required this.customerId});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CustomerEditModel? _model;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerDetail();
  }

  Future<void> _loadCustomerDetail() async {
    final id = int.parse(widget.customerId);
    final detail = await CustomerEditService().getCustomerDetail(id);
    if (detail != null) {
      setState(() {
        _model = detail;
        _isLoading = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Müşteri bilgileri alınamadı.')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    setState(() => _isSubmitting = true);
    final success = await CustomerEditService().editCustomer(_model!);
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Müşteri başarıyla güncellendi.')),
      );
      Navigator.pop(context, true);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata oluştu, tekrar deneyin.')),
      );
    }
  }

  Widget _modernTextField(
    String label, {
    required String initialValue,
    required void Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null;

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _model == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Düzenle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _modernTextField(
                'Adı Soyadı',
                initialValue: _model!.name,
                validator: _requiredValidator,
                onSaved: (v) => _model!.name = v?.trim() ?? '',
              ),
              _modernTextField(
                'Email',
                initialValue: _model!.email,
                onSaved: (v) => _model!.email = v?.trim() ?? '',
              ),
              _modernTextField(
                'Telefon',
                initialValue: _model!.phone,
                onSaved: (v) => _model!.phone = v?.trim() ?? '',
              ),
              _modernTextField(
                'Vergi No',
                initialValue: _model!.taxNumber,
                onSaved: (v) => _model!.taxNumber = v?.trim() ?? '',
              ),
              _modernTextField(
                'Vergi Dairesi',
                initialValue: _model!.taxOffice,
                onSaved: (v) => _model!.taxOffice = v?.trim() ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon:
                    _isSubmitting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00034),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
