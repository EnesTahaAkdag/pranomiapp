import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerAddModel.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/services/CustomerService/CustomerAddService.dart';

class CustomerAddPage extends StatefulWidget {
  final CustomerTypeEnum customerType;
  const CustomerAddPage({super.key, required this.customerType});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _formKey = GlobalKey<FormState>();
  late CustomerAddModel _model;
  bool _isSubmitting = false;

  List<String> _countries = [];
  List<String> _turkishCities = [];
  Map<String, List<String>> _turkishDistricts = {};

  String? _selectedCountry;
  String? _selectedCity;
  // ignore: unused_field
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _model = CustomerAddModel(
      name: '',
      isCompany: false,
      taxOffice: '',
      taxNumber: '',
      email: '',
      iban: '',
      address: '',
      phone: '',
      city: '',
      district: '',
      isActive: false,
      type: CustomerTypeEnum.Customer,
      hasOpeningBalance: false,
      openingBalance: 2147483647,
    );

    _loadCountryData();
  }

  Future<void> _loadCountryData() async {
    final countryData = await rootBundle.loadString(
      'lib/assets/json/countries.json',
    );
    final turkeyData = await rootBundle.loadString(
      'lib/assets/json/turkey_provinces.json',
    );

    setState(() {
      final List<dynamic> countryList = json.decode(countryData);
      _countries = countryList.map((e) => e['name'] as String).toList();

      final List<dynamic> turkeyJson = json.decode(turkeyData);
      _turkishDistricts = {
        for (var province in turkeyJson)
          province['il'] as String: List<String>.from(province['ilceler']),
      };
      _turkishCities = _turkishDistricts.keys.toList();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    final success = await CustomerAddService().addCustomer(_model);
    setState(() => _isSubmitting = false);

    if (success) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop('refresh');
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Müşteri eklenemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Cari Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: 'Ad Soyad / Ünvan *',
                onSaved: (val) => _model.name = val!,
                validator:
                    (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
              ),
              _buildCheckbox(
                label: 'Şirket Mi?',
                value: _model.isCompany,
                onChanged: (val) => setState(() => _model.isCompany = val!),
              ),
              _buildTextField(
                label: 'Vergi Dairesi',
                onSaved: (val) => _model.taxOffice = val!,
              ),
              _buildTextField(
                label: 'Vergi No',
                onSaved: (val) => _model.taxNumber = val!,
              ),
              _buildTextField(
                label: 'E-posta',
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => _model.email = val!,
              ),
              _buildTextField(
                label: 'IBAN',
                onSaved: (val) => _model.iban = val!,
              ),
              _buildTextField(
                label: 'Adres',
                onSaved: (val) => _model.address = val!,
              ),
              _buildTextField(
                label: 'Telefon',
                keyboardType: TextInputType.phone,
                onSaved: (val) => _model.phone = val!,
              ),
              _buildAutocompleteField(
                label: 'Ülke *',
                options: _countries,
                onSaved: (val) {
                  _selectedCountry = val;
                  _model.city = '';
                  _model.district = '';
                },
                validator:
                    (val) => val == null || val.isEmpty ? 'Zorunlu alan' : null,
              ),
              if (_selectedCountry == 'Turkey') ...[
                _buildAutocompleteField(
                  label: 'İl',
                  options: _turkishCities,
                  onSaved: (val) {
                    _selectedCity = val;
                    _model.city = val ?? '';
                    _selectedDistrict = null;
                  },
                ),
                if (_selectedCity != null)
                  _buildAutocompleteField(
                    label: 'İlçe',
                    options: _turkishDistricts[_selectedCity!] ?? [],
                    onSaved: (val) {
                      _selectedDistrict = val;
                      _model.district = val ?? '';
                    },
                  ),
              ] else ...[
                _buildTextField(
                  label: 'Şehir',
                  onSaved: (val) => _model.city = val!,
                ),
                _buildTextField(
                  label: 'İlçe',
                  onSaved: (val) => _model.district = val!,
                ),
              ],
              _buildCheckbox(
                label: 'Aktif Mi?',
                value: _model.isActive,
                onChanged: (val) => setState(() => _model.isActive = val!),
              ),
              _buildCheckbox(
                label: 'Açılış Bakiyesi Var mı?',
                value: _model.hasOpeningBalance,
                onChanged:
                    (val) => setState(() => _model.hasOpeningBalance = val!),
              ),
              if (_model.hasOpeningBalance)
                _buildTextField(
                  label: 'Açılış Bakiyesi',
                  keyboardType: TextInputType.number,
                  onSaved:
                      (val) =>
                          _model.openingBalance = int.tryParse(val ?? '') ?? 0,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required void Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAutocompleteField({
    required String label,
    required List<String> options,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return options.where(
            (option) => option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            ),
          );
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            onEditingComplete: onEditingComplete,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            validator: validator,
            onSaved: onSaved,
          );
        },
        onSelected: (val) => onSaved(val),
      ),
    );
  }
}
