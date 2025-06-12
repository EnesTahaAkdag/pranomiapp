import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerAddModel.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerAddressModel.dart';
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

  List<Country> _countries = [];
  List<City> _cities = [];
  List<District> _districts = [];

  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  bool _isSubmitting = false;

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
      isActive: true,
      type: widget.customerType,
      hasOpeningBalance: false,
      openingBalance: 0,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final countryData = await rootBundle.loadString(
      'lib/assets/json/countries.json',
    );
    final cityData = await rootBundle.loadString('lib/assets/json/il.json');
    final districtData = await rootBundle.loadString(
      'lib/assets/json/ilce.json',
    );

    setState(() {
      _countries =
          (json.decode(countryData) as List)
              .map((e) => Country.fromJson(e))
              .toList();
      _cities =
          (json.decode(cityData)[2]['data'] as List)
              .map((e) => City.fromJson(e))
              .toList();
      _districts =
          (json.decode(districtData)[2]['data'] as List)
              .map((e) => District.fromJson(e))
              .toList();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final success = await CustomerAddService().addCustomer(_model);
    setState(() => _isSubmitting = false);

    if (success && mounted) {
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Yeni Cari Hesap Ekle'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('1. Temel Bilgiler'),
              _modernTextField(
                'Ad Soyad / Firma Adı *',
                onSaved: (v) => _model.name = v!,
                validator: _requiredValidator,
              ),
              _companySwitch(),
              _modernTextField(
                _model.isCompany ? 'Vergi Dairesi' : 'Doğum Yeri',
                onSaved: (v) => _model.taxOffice = v ?? '',
              ),
              _modernTextField(
                _model.isCompany ? 'Vergi No' : 'TC Kimlik No',
                keyboardType: TextInputType.number,
                onSaved: (v) => _model.taxNumber = v ?? '',
              ),

              _sectionTitle('2. Adres Bilgileri'),
              _dropdown<Country>(
                'Ülke',
                _selectedCountry,
                _countries,
                (c) => c.name,
                (val) {
                  setState(() {
                    _selectedCountry = val;
                    _selectedCity = null;
                    _selectedDistrict = null;
                  });
                },
              ),
              if (_selectedCountry?.name.toLowerCase() == 'türkiye')
                _dropdown<City>(
                  'Şehir',
                  _selectedCity,
                  _cities,
                  (c) => c.name,
                  (val) {
                    setState(() {
                      _selectedCity = val;
                      _model.city = val?.name ?? '';
                      _selectedDistrict = null;
                    });
                  },
                ),
              if (_selectedCity != null)
                _dropdown<District>(
                  'İlçe',
                  _selectedDistrict,
                  _districts
                      .where((d) => d.cityId == _selectedCity!.id)
                      .toList(),
                  (d) => d.name,
                  (val) {
                    setState(() {
                      _selectedDistrict = val;
                      _model.district = val?.name ?? '';
                    });
                  },
                ),
              _modernTextField(
                'Açık Adres',
                maxLines: 3,
                onSaved: (v) => _model.address = v ?? '',
              ),

              _sectionTitle('3. İletişim ve Finans'),
              _modernTextField(
                'E-Posta Adresi',
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _model.email = v ?? '',
              ),
              _modernTextField(
                'Telefon Numarası',
                keyboardType: TextInputType.phone,
                onSaved: (v) => _model.phone = v ?? '',
              ),
              _modernTextField(
                'IBAN Numarası',
                onSaved: (v) => _model.iban = v ?? '',
              ),

              _sectionTitle('4. Diğer'),
              _modernSwitch(
                'Aktif mi?',
                _model.isActive,
                (val) => setState(() => _model.isActive = val),
              ),
              _modernSwitch(
                'Açılış Bakiyesi Var mı?',
                _model.hasOpeningBalance,
                (val) => setState(() => _model.hasOpeningBalance = val),
              ),
              if (_model.hasOpeningBalance)
                _modernTextField(
                  'Açılış Bakiyesi (₺)',
                  keyboardType: TextInputType.number,
                  onSaved:
                      (v) => _model.openingBalance = int.tryParse(v ?? '') ?? 0,
                ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.save),
                  label: const Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB00034),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernTextField(
    String label, {
    required void Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          fillColor: Colors.white,
          filled: true,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _dropdown<T>(
    String label,
    T? value,
    List<T> items,
    String Function(T) display,
    void Function(T?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          fillColor: Colors.white,
          filled: true,
        ),
        value: value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(display(e))))
                .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Zorunlu alan' : null,
      ),
    );
  }

  Widget _modernSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xFFB00034),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _companySwitch() {
    return ListTile(
      title: Text(
        _model.isCompany ? 'Tüzel Kişi' : 'Gerçek Kişi',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Switch(
        value: _model.isCompany,
        onChanged: (val) => setState(() => _model.isCompany = val),
        activeColor: Color(0xFFB00034),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  String? _requiredValidator(String? val) {
    return (val == null || val.trim().isEmpty) ? 'Zorunlu alan' : null;
  }
}
