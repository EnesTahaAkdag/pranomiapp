import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranomiapp/features/customers/data/models/customer_address_model.dart';
import 'package:pranomiapp/features/customers/domain/customer_type_enum.dart';
import 'package:pranomiapp/features/employees/data/models/employee_add_model.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/phone_text_field.dart';
import '../../data/services/employee_add_service.dart';

class EmployeeAddPage extends StatefulWidget {
  final CustomerTypeEnum customerType;

  const EmployeeAddPage({super.key, required this.customerType});

  @override
  State<EmployeeAddPage> createState() => _EmployeeAddPageState();
}

class _EmployeeAddPageState extends State<EmployeeAddPage> {
  final _formKey = GlobalKey<FormState>();
  late EmployeeAddModel _model;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Country> _countries = [];
  List<City> _cities = [];
  List<District> _districts = [];

  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  final _employeeAddService = locator<EmployeeAddService>();

  @override
  void initState() {
    super.initState();

    _model = EmployeeAddModel(
      name: '',
      isCompany: false,
      taxOffice: '',
      taxNumber: '',
      email: '',
      iban: '',
      address: '',
      phone: '',
      countryIso2: '',
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
          (json.decode(cityData) as List).map((e) => City.fromJson(e)).toList();
      _districts =
          (json.decode(districtData) as List)
              .map((e) => District.fromJson(e))
              .toList();

      // 🇹🇷 Türkiye'yi varsayılan olarak seç
      _selectedCountry = _countries.firstWhere(
            (c) => c.alpha2.toUpperCase() == 'TR',
        orElse: () => _countries.first, // TR yoksa ilk ülkeyi seç
      );
      _model.countryIso2 = _selectedCountry!.alpha2.toUpperCase();

      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final success = await _employeeAddService.addEmployee(_model);
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.of(context).pop('refresh');
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cari Hesap Eklenemedi.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: AppLoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Çalışan Ekle'),
        scrolledUnderElevation: 0, // Kaydırma sırasında elevation değişimini engeller

        centerTitle: true,
        backgroundColor: AppTheme.mediumGrayBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _modernTextField(
                'İsim *',
                onSaved: (v) => _model.name = v!.trim(),
                validator: _requiredValidator,
              ),
              _modernTextField(
                'Çalışan Kodu',
                onSaved: (v) => _model.taxOffice = v?.trim() ?? '',
              ),
              _modernTextField(
                'TC Numarası',
                keyboardType: TextInputType.number,
                onSaved: (v) => _model.taxNumber = v?.trim() ?? '',
              ),
              const SizedBox(height: 15),
              _countryDropdown(),
              if (_selectedCountry != null &&
                  _selectedCountry!.name.toLowerCase() == 'türkiye') ...[
                const SizedBox(height: 10),
                _cityDropdown(),
                if (_selectedCity != null) ...[
                  const SizedBox(height: 10),
                  _districtDropdown(),
                ],
              ] else if (_selectedCountry != null) ...[
                const SizedBox(height: 10),
                _customCityInput(),
                const SizedBox(height: 10),
                _customDistrictInput(),
              ],
              _modernTextField(
                'Adres',
                maxLines: 3,
                onSaved: (v) => _model.address = v?.trim() ?? '',
              ),
              _modernTextField(
                'E-Posta Adresi',
                keyboardType: TextInputType.emailAddress,
                onSaved: (v) => _model.email = v?.trim() ?? '',
              ),
              PhoneTextField(
                label: 'Telefon Numarası',
                onSaved: (v) => _model.phone = v ?? '',
              ),
              _modernTextField(
                'IBAN Numarası',
                onSaved: (v) => _model.iban = v?.trim() ?? '',
              ),

              if (_model.hasOpeningBalance)
                _modernTextField(
                  'Açılış Bakiyesi (₺)',
                  keyboardType: TextInputType.number,
                  onSaved:
                      (v) => _model.openingBalance = int.tryParse(v ?? '') ?? 0,
                ),
              const SizedBox(height: 30),
              Center(child: _submitButton()),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _submitButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submit,
      icon:
          _isSubmitting
              ? const SizedBox(
                width: 20,
                height: 20,
                child: AppLoadingIndicator(size: 20),
              )
              : const Icon(Icons.save),
      label: const Text('Kaydet'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _countryDropdown() => DropdownSearch<Country>(
    popupProps: PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Ülke *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    items: _countries,
    itemAsString: (c) => c.name,
    selectedItem: _selectedCountry,
    onChanged: (val) {
      setState(() {
        _selectedCountry = val;
        _model.countryIso2 = val?.alpha2.toUpperCase() ?? '';
        _selectedCity = null;
        _selectedDistrict = null;
        _model.city = '';
        _model.district = '';
      });
    },
    validator: (v) => v == null ? 'Zorunlu alan' : null,
  );

  Widget _cityDropdown() => DropdownSearch<City>(
    popupProps: PopupProps.menu(showSearchBox: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Şehir',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    items: _cities,
    itemAsString: (c) => c.name,
    selectedItem: _selectedCity,
    onChanged: (val) {
      setState(() {
        _selectedCity = val;
        _model.city = val?.name ?? '';
        _selectedDistrict = null;
        _model.district = '';
      });
    },
  );

  Widget _districtDropdown() => DropdownSearch<District>(
    popupProps: PopupProps.menu(showSearchBox: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'İlçe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    items: _districts.where((d) => d.cityId == _selectedCity!.id).toList(),
    itemAsString: (d) => d.name,
    selectedItem: _selectedDistrict,
    onChanged: (val) {
      setState(() {
        _selectedDistrict = val;
        _model.district = val?.name ?? '';
      });
    },
  );

  Widget _customCityInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Şehir',
          hintText: 'Şehir giriniz',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        initialValue: _model.city,
        validator: _requiredValidator,
        onSaved: (v) => _model.city = v?.trim() ?? '',
      ),
    );
  }

  Widget _customDistrictInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'İlçe',
          hintText: 'İlçe giriniz',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        initialValue: _model.district,
        validator: _requiredValidator,
        onSaved: (v) => _model.district = v?.trim() ?? '',
      ),
    );
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null;
}
