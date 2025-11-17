import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranomiapp/core/extensions/snackbar_extensions.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../customers/data/models/customer_address_model.dart';
import '../../data/models/employee_edit_model.dart';
import '../../data/services/employee_detail_service.dart';
import '../../data/services/employee_edit_service.dart';
import '../../../customers/domain/customer_type_enum.dart';


class EmployeesEditPage extends StatefulWidget {
  final int employeeId;

  const EmployeesEditPage({super.key, required this.employeeId});

  @override
  State<EmployeesEditPage> createState() => _EmployeesEditPageState();
}

class _EmployeesEditPageState extends State<EmployeesEditPage> {
  final _formKey = GlobalKey<FormState>();
  EmployeeEditModel? _model;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _submitSuccess = false;

  List<Country> _countries = [];
  List<City> _cities = [];
  List<District> _districts = [];

  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  final _employeeDetailService = locator<EmployeeDetailService>();
  final _employeeEditService = locator<EmployeeEditService>();

  String? _cityValidator(String? v) {
    if (_selectedCountry == null) return 'Zorunlu alan';
    if (_selectedCountry!.name.toLowerCase() != 'türkiye' &&
        (v == null || v.trim().isEmpty)) {
      return 'Şehir alanı zorunludur';
    }
    return null;
  }

  String? _districtValidator(String? v) {
    if (_selectedCountry == null) return 'Zorunlu alan';
    if (_selectedCountry!.name.toLowerCase() != 'türkiye' &&
        (v == null || v.trim().isEmpty)) {
      return 'İlçe alanı zorunludur';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadData();
    await _loadEmployee();

    if (_model != null) {
      _selectedCountry = _countries.firstWhereOrNull(
        (c) => c.alpha2.toLowerCase() == _model!.countryIso2.toLowerCase(),
      );

      if (_selectedCountry?.name.toLowerCase() == 'türkiye') {
        _selectedCity = _cities.firstWhereOrNull(
          (c) => c.name.toLowerCase() == _model!.city.toLowerCase(),
        );

        if (_selectedCity != null) {
          _selectedDistrict = _districts
              .where((d) => d.cityId == _selectedCity!.id)
              .firstWhereOrNull(
                (d) => d.name.toLowerCase() == _model!.district.toLowerCase(),
              );
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadEmployee() async {
    final response = await _employeeDetailService.getEmployeeDetail(
      widget.employeeId,
    );
    if (response != null) {
      _model = EmployeeEditModel(
        id: response.id,
        name: response.name,
        code: response.code,
        isCompany: response.isCompany,
        taxOffice: response.taxOffice,
        taxNumber: response.taxNumber,
        email: response.email,
        iban: response.iban,
        address: response.address,
        phone: response.phone,
        countryIso2: response.countryIso2,
        city: response.city,
        district: response.district,
        isActive: response.active,
        type: customerType(response.type),
      );
    } else if (context.mounted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Çalışan bilgisi yüklenemedi. Tekrar deneyin."),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    final countryData = await rootBundle.loadString(
      'lib/assets/json/countries.json',
    );
    final cityData = await rootBundle.loadString('lib/assets/json/il.json');
    final districtData = await rootBundle.loadString(
      'lib/assets/json/ilce.json',
    );

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
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final responseModel = await _employeeEditService.editEmployee(_model!);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (responseModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sunucuya ulaşılamadı. Lütfen tekrar deneyin.'),
        ),
      );
      return;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(context.showSuccessSnackbar("Başarıyla güncellendi"));
      Navigator.pop(context);
    }

    if (responseModel.errorMessages.isNotEmpty ||
        responseModel.warningMessages.isNotEmpty) {
      final messages = [
        ...responseModel.errorMessages,
        ...responseModel.warningMessages,
      ].join('\n');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(messages)));
    } else if (responseModel.successMessages.isNotEmpty) {
      setState(() {
        _submitSuccess = true;
      });

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _submitSuccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _model == null) {
      return const Scaffold(body: Center(child: AppLoadingIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışan Düzenle'),
        scrolledUnderElevation:
            0, // Kaydırma sırasında elevation değişimini engeller
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                'Çalışan Adı',
                _model!.name,
                (v) => _model!.name = v ?? '',
              ),
              _buildTextField(
                'Çalışan Kodu',
                _model!.code,
                (v) => _model!.code = v ?? '',
              ),
              _buildTextField(
                'Vergi Dairesi',
                _model!.taxOffice,
                (v) => _model!.taxOffice = v ?? '',
              ),
              _buildTextField(
                'TC Numarası',
                _model!.taxNumber,
                (v) => _model!.taxNumber = v ?? '',
              ),
              _buildTextField(
                'E-Posta',
                _model!.email,
                (v) => _model!.email = v ?? '',
                inputType: TextInputType.emailAddress,
              ),
              _buildTextField(
                'Telefon',
                _model!.phone,
                (v) => _model!.phone = v ?? '',
              ),
              _buildTextField(
                'IBAN',
                _model!.iban,
                (v) => _model!.iban = v ?? '',
              ),
              _buildTextField(
                'Adres',
                _model!.address,
                (v) => _model!.address = v ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 10),
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
                const SizedBox(height: 5),
                _customCityInput(),
                _customDistrictInput(),
              ],
              const SizedBox(height: 24),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    void Function(String?) onSaved, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    int? maxLength;
    List<TextInputFormatter>? inputFormatters;

    switch (label) {
      case 'Ad':
        maxLength = 50;
        break;
      case 'Vergi Dairesi':
        maxLength = 50;
        break;
      case 'TC Numarası':
        maxLength = 11;
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case 'E-Posta':
        maxLength = 100;
        break;
      case 'Telefon':
        maxLength = 10;
        inputFormatters = [FilteringTextInputFormatter.digitsOnly];
        break;
      case 'IBAN':
        maxLength = 26;
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
        ];
        break;
      case 'Adres':
        maxLength = 250;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          counterText: '',
        ),
        keyboardType: inputType,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        validator: (v) {
          if (label == 'Ad' && (v == null || v.trim().isEmpty)) {
            return 'Zorunlu alan';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentColor,
    );
  }

  Widget _countryDropdown() => DropdownSearch<Country>(
    popupProps: const PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
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
        _model?.countryIso2 = val?.alpha2.toUpperCase() ?? '';
        _selectedCity = null;
        _selectedDistrict = null;
        _model?.city = '';
        _model?.district = '';
      });
    },
    validator: (v) => v == null ? 'Zorunlu alan' : null,
  );

  Widget _cityDropdown() => DropdownSearch<City>(
    popupProps: const PopupProps.menu(showSearchBox: true),
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
        _model?.city = val?.name ?? '';
        _selectedDistrict = null;
        _model?.district = '';
      });
    },
  );

  Widget _districtDropdown() => DropdownSearch<District>(
    popupProps: const PopupProps.menu(showSearchBox: true),
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
        _model?.district = val?.name ?? '';
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
        initialValue: _model?.city,
        validator: _cityValidator,
        onSaved: (v) => _model?.city = v?.trim() ?? '',
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
        initialValue: _model?.district,
        validator: _districtValidator,
        onSaved: (v) => _model?.district = v?.trim() ?? '',
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
      label: Text(_submitSuccess ? 'Kaydedildi' : 'Kaydet'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}
