import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/customer_add_model.dart';
import '../../data/models/customer_address_model.dart';
import '../../data/services/customer_add_service.dart';
import '../../domain/customer_type_enum.dart';

class CustomerAddPage extends StatefulWidget {
  final CustomerTypeEnum customerType;

  const CustomerAddPage({super.key, required this.customerType});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _formKey = GlobalKey<FormState>();
  late CustomerAddModel _model;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Country> _countries = [];
  List<City> _cities = [];
  List<District> _districts = [];

  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  final _customerAddService = locator<CustomerAddService>();

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
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final success = await _customerAddService.addCustomer(_model);
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
        backgroundColor: AppTheme.white,
        body: Center(child: AppLoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Cari Hesap Ekle'),
        scrolledUnderElevation: 0,
        // Kaydırma sırasında elevation değişimini engeller
        centerTitle: true,
        backgroundColor: AppTheme.mediumGrayBackground,
        elevation: AppConstants.elevationNone,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _companySwitch(),
              _modernTextField(
                'İsim *',
                onSaved: (v) => _model.name = v!.trim(),
                validator: _requiredValidator,
              ),
              _modernTextField(
                'Vergi Dairesi',
                onSaved: (v) => _model.taxOffice = v?.trim() ?? '',
              ),
              _modernTextField(
                'TCKN/Vergi Numarası',
                keyboardType: TextInputType.number,
                onSaved: (v) => _model.taxNumber = v?.trim() ?? '',
              ),
              const SizedBox(height: AppConstants.spacing15),
              _countryDropdown(),
              if (_selectedCountry != null &&
                  _selectedCountry!.name.toLowerCase() == 'türkiye') ...[
                const SizedBox(height: AppConstants.spacing10),
                _cityDropdown(),
                if (_selectedCity != null) ...[
                  const SizedBox(height: AppConstants.spacing10),
                  _districtDropdown(),
                ],
              ] else if (_selectedCountry != null) ...[
                const SizedBox(height: AppConstants.spacing10),
                _customCityInput(),
                const SizedBox(height: AppConstants.spacing10),
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
                // validator: (v) => v == null || v.isEmpty ? 'Zorunlu alan' : null, // Opsiyonel custom validator
              ),
              _modernTextField(
                'IBAN Numarası',
                onSaved: (v) => _model.iban = v?.trim() ?? '',
              ),
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
              const SizedBox(height: AppConstants.spacing30),
              Center(child: _submitButton()),
              const SizedBox(height: AppConstants.spacing30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _companySwitch() => ListTile(
    title: Text(
      _model.isCompany ? 'Tüzel Kişi' : 'Gerçek Kişi',
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    trailing: Switch(
      value: _model.isCompany,
      onChanged: (v) => setState(() => _model.isCompany = v),
      activeThumbColor: AppTheme.accentColor,
    ),
  );

  Widget _modernTextField(
    String label, {
    required void Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters, // Yeni parametre ekleyin
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.fontSizeM,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  Widget _modernSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submit,
      icon:
          _isSubmitting
              ? const SizedBox(
                width: AppConstants.spacing20,
                height: AppConstants.spacing20,
                child: AppLoadingIndicator(size: AppConstants.spacing20),
              )
              : const Icon(Icons.save),
      label: const Text('Kaydet'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing40,
          vertical: AppConstants.fontSizeXl,
        ),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _countryDropdown() => DropdownSearch<Country>(
    popupProps: const PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Ülke *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
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
    popupProps: const PopupProps.menu(showSearchBox: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Şehir',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
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
    popupProps: const PopupProps.menu(showSearchBox: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'İlçe',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Şehir',
          hintText: 'Şehir giriniz',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.fontSizeM,
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
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'İlçe',
          hintText: 'İlçe giriniz',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.fontSizeM,
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


class PhoneTextField extends StatelessWidget {
  final String label;
  final void Function(String?) onSaved;
  final String? Function(String?)? validator;
  final String? initialValue;

  const PhoneTextField({
    super.key,
    required this.label,
    required this.onSaved,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: '(5XX) XXX XX XX',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.fontSizeM,
          ),
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          PhoneNumberFormatter(),
        ],
        validator: validator ?? _defaultValidator,
        onSaved: (value) => onSaved(value?.unformatPhoneNumber()),
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    String cleaned = value.unformatPhoneNumber();
    if (cleaned.length != 10) {
      return 'Geçerli bir telefon numarası girin (10 hane)';
    }
    return null;
  }
}

// Formatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    String formatted = '';

    if (text.isNotEmpty) {
      formatted = '(${text.substring(0, text.length.clamp(0, 3))}';

      if (text.length > 3) {
        formatted += ') ${text.substring(3, text.length.clamp(3, 6))}';
      }

      if (text.length > 6) {
        formatted += ' ${text.substring(6, text.length.clamp(6, 8))}';
      }

      if (text.length > 8) {
        formatted += ' ${text.substring(8, text.length.clamp(8, 10))}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Extension
extension PhoneNumberExtension on String {
  String formatPhoneNumber() {
    String cleaned = replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return this;
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
  }

  String unformatPhoneNumber() {
    return replaceAll(RegExp(r'\D'), '');
  }
}

