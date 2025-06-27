import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerEditModel.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/services/CustomerService/CustomerEditService.dart';

class CustomerEditPage extends StatefulWidget {
  final int customerId;
  const CustomerEditPage({super.key, required this.customerId});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _formKey = GlobalKey<FormState>();
  CustomerEditModel? _editModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    final detail = await CustomerEditService().fetchCustomerDetails(
      widget.customerId,
    );

    if (detail != null) {
      setState(() {
        _editModel = CustomerEditModel(
          id: detail.id,
          name: detail.name,
          isCompany: detail.isCompany,
          taxOffice: detail.taxOffice ?? '',
          taxNumber: detail.taxNumber ?? '',
          email: detail.email ?? '',
          iban: detail.iban ?? '',
          address: detail.address ?? '',
          phone: detail.phone ?? '',
          countryIso2: detail.countryIso2,
          city: detail.city ?? '',
          district: detail.district ?? '',
          isActive: detail.active,
          type: CustomerTypeExtension.fromString(detail.type),
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müşteri bilgisi alınamadı.")),
      );
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final success = await CustomerEditService().editCustomer(_editModel!);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Müşteri güncellendi' : 'Hata oluştu')),
    );
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _editModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                'Ad',
                _editModel!.name,
                (v) => _editModel?.name = v ?? '',
              ),
              _buildSwitch(
                'Şirket mi?',
                _editModel!.isCompany,
                (v) => setState(() => _editModel?.isCompany = v),
              ),
              _buildTextField(
                'Vergi Dairesi',
                _editModel!.taxOffice,
                (v) => _editModel?.taxOffice = v ?? '',
              ),
              _buildTextField(
                'Vergi Numarası',
                _editModel!.taxNumber,
                (v) => _editModel?.taxNumber = v ?? '',
              ),
              _buildTextField(
                'Email',
                _editModel!.email,
                (v) => _editModel!.email = v ?? '',
              ),
              _buildTextField(
                'Telefon',
                _editModel!.phone,
                (v) => _editModel!.phone = v ?? '',
              ),
              _buildTextField(
                'IBAN',
                _editModel!.iban,
                (v) => _editModel!.iban = v ?? '',
              ),
              _buildTextField(
                'Adres',
                _editModel!.address,
                (v) => _editModel!.address = v ?? '',
              ),
              _buildTextField(
                'Ülke (ISO2)',
                _editModel!.countryIso2,
                (v) => _editModel!.countryIso2 = v ?? '',
              ),
              _buildTextField(
                'Şehir',
                _editModel!.city,
                (v) => _editModel!.city = v ?? '',
              ),
              _buildTextField(
                'İlçe',
                _editModel!.district,
                (v) => _editModel!.district = v ?? '',
              ),
              _buildSwitch(
                'Aktif',
                _editModel!.isActive,
                (v) => setState(() => _editModel!.isActive = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initial,
    FormFieldSetter<String?> onSave,
  ) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(labelText: label),
      onSaved: onSave,
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
