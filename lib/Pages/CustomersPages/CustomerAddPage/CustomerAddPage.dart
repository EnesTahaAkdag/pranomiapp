import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
      cuontryIso2: '',
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
              _companySwitch(),
              _modernTextField(
                'İsim *',
                onSaved: (v) => _model.name = v!,
                validator: _requiredValidator,
              ),
              _modernTextField(
                'Vergi Dairesi',
                onSaved: (v) => _model.taxOffice = v ?? '',
              ),
              _modernTextField(
                'TC/Vergi Numarası',
                keyboardType: TextInputType.number,
                onSaved: (v) => _model.taxNumber = v ?? '',
              ),
              const SizedBox(height: 15),
              _countryDropdown(),
              if (_selectedCountry?.name.toLowerCase() == 'türkiye') ...{
                const SizedBox(height: 10),
                _cityDropdown(),
                if (_selectedCountry?.name.toLowerCase() == 'türkiye' &&
                    _selectedCity != null) ...{
                  const SizedBox(height: 10),
                  _districtDropdown(),
                } else if (_model.city.isNotEmpty) ...{
                  const SizedBox(height: 10),
                  _customDistrictInput(),
                },
              },
              _modernTextField(
                'Açık Adres',
                maxLines: 3,
                onSaved: (v) => _model.address = v ?? '',
              ),
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownSearch<Country>(
          popupProps: PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Ülke',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          items: _countries,
          itemAsString: (Country? c) => c?.name ?? '',
          selectedItem: _selectedCountry,
          onChanged: (val) {
            setState(() {
              _selectedCountry = val;
              _selectedCity = null;
              _selectedDistrict = null;
            });
          },
          validator: (val) => val == null ? 'Zorunlu alan' : null,
        ),
      ],
    );
  }

  Widget _cityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownSearch<City>(
          popupProps: PopupProps.menu(showSearchBox: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'Şehir',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          items: _cities,
          itemAsString: (City? c) => c?.name ?? '',
          selectedItem: _selectedCity,
          onChanged: (val) {
            setState(() {
              _selectedCity = val;
              _model.city = val?.name ?? '';
              _selectedDistrict = null;
            });
          },
          validator: (val) => val == null ? 'Zorunlu alan' : null,
        ),
      ],
    );
  }

  Widget _districtDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownSearch<District>(
          popupProps: PopupProps.menu(showSearchBox: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: 'İlçe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          items:
              _districts.where((d) => d.cityId == _selectedCity!.id).toList(),
          itemAsString: (District? d) => d?.name ?? '',
          selectedItem: _selectedDistrict,
          onChanged: (val) {
            setState(() {
              _selectedDistrict = val;
              _model.district = val?.name ?? '';
            });
          },
          validator: (val) => val == null ? 'Zorunlu alan' : null,
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _customCityInput() {
    return DropdownSearch<String>(
      popupProps: PopupProps.dialog(showSearchBox: true),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Şehir',
          border: OutlineInputBorder(),
        ),
      ),
      selectedItem: _model.city.isNotEmpty ? _model.city : null,
      onChanged: (val) => setState(() => _model.city = val ?? ''),
      validator: _requiredValidator,
      asyncItems: (String filter) async => [filter],
    );
  }

  Widget _customDistrictInput() {
    return DropdownSearch<String>(
      popupProps: PopupProps.dialog(showSearchBox: true),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'İlçe',
          border: OutlineInputBorder(),
        ),
      ),
      selectedItem: _model.district.isNotEmpty ? _model.district : null,
      onChanged: (val) => setState(() => _model.district = val ?? ''),
      asyncItems: (String filter) async => [filter],
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

  Widget _modernSwitch(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SwitchListTile(
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFB00034),
        ),
      ),
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

  String? _requiredValidator(String? val) {
    return (val == null || val.trim().isEmpty) ? 'Zorunlu alan' : null;
  }
}
