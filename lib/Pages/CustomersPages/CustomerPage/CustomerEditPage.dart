import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerEditModel.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/services/CustomerService/CustomerEditService.dart';

class Country {
  final int id;
  final String name;
  final String alpha2;

  Country({required this.id, required this.name, required this.alpha2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(id: json['id'], name: json['name'], alpha2: json['alpha2']);
  }

  String get alpha2Formatted => alpha2.toUpperCase();
}

class City {
  final int id;
  final String name;
  final String countryAlpha2;

  City({required this.id, required this.name, required this.countryAlpha2});

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'],
    name: json['name'],
    countryAlpha2: json['country_alpha2'],
  );
}

class District {
  final int id;
  final String name;
  final int cityId;

  District({required this.id, required this.name, required this.cityId});

  factory District.fromJson(Map<String, dynamic> json) =>
      District(id: json['id'], name: json['name'], cityId: json['city_id']);
}

class CustomerEditPage extends StatefulWidget {
  final int customerId;
  const CustomerEditPage({super.key, required this.customerId});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _formKey = GlobalKey<FormState>();
  CustomerEditModel? _model;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Country> _countries = [];
  Country? _selectedCountry;

  List<City> _cities = [];
  List<District> _districts = [];

  List<City> _filteredCities = [];
  List<District> _filteredDistricts = [];

  City? _selectedCity;
  District? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadCustomer(),
      _loadCountries(),
      _loadCities(),
      _loadDistricts(),
    ]);
    _matchCountry();
    _matchCityAndDistrict();
    setState(() => _isLoading = false);
  }

  Future<void> _loadCustomer() async {
    final response = await CustomerEditService().fetchCustomerDetails(
      widget.customerId,
    );
    if (response != null) {
      _model = CustomerEditModel(
        id: response.id,
        name: response.name,
        isCompany: response.isCompany,
        taxOffice: response.taxOffice ?? '',
        taxNumber: response.taxNumber ?? '',
        email: response.email ?? '',
        iban: response.iban ?? '',
        address: response.address ?? '',
        phone: response.phone ?? '',
        countryIso2: response.countryIso2,
        city: response.city ?? '',
        district: response.district ?? '',
        isActive: response.active,
        type: CustomerTypeExtension.fromString(response.type),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("M\u00fc\u015fteri bilgisi al\u0131namad\u0131."),
          ),
        );
      }
    }
  }

  Future<void> _loadCountries() async {
    final String response = await rootBundle.loadString(
      'lib/assets/json/countries.json',
    );
    final List<dynamic> data = json.decode(response);
    _countries = data.map((e) => Country.fromJson(e)).toList();
  }

  Future<void> _loadCities() async {
    final String response = await rootBundle.loadString(
      'lib/assets/json/cities.json',
    );
    final List<dynamic> data = json.decode(response);
    _cities = data.map((e) => City.fromJson(e)).toList();
  }

  Future<void> _loadDistricts() async {
    final String response = await rootBundle.loadString(
      'lib/assets/json/districts.json',
    );
    final List<dynamic> data = json.decode(response);
    _districts = data.map((e) => District.fromJson(e)).toList();
  }

  void _matchCountry() {
    if (_model != null) {
      _selectedCountry = _countries.firstWhere(
        (c) => c.alpha2Formatted == _model!.countryIso2.toUpperCase(),
        orElse: () => _countries.first,
      );
    }
  }

  void _matchCityAndDistrict() {
    if (_model == null) return;

    _filteredCities =
        _cities.where((c) => c.countryAlpha2 == _model!.countryIso2).toList();
    _selectedCity = _filteredCities.firstWhere(
      (c) => c.name.toLowerCase() == _model!.city.toLowerCase(),
      orElse:
          () =>
              _filteredCities.isNotEmpty
                  ? _filteredCities.first
                  : City(id: 0, name: 'Unknown', countryAlpha2: ''),
    );

    if (_selectedCity != null) {
      _filteredDistricts =
          _districts.where((d) => d.cityId == _selectedCity!.id).toList();
      _selectedDistrict = _filteredDistricts.firstWhere(
        (d) => d.name.toLowerCase() == _model!.district.toLowerCase(),
        orElse:
            () =>
                _filteredDistricts.isNotEmpty
                    ? _filteredDistricts.first
                    : District(id: 0, name: 'Unknown', cityId: 0),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    final success = await CustomerEditService().editCustomer(_model!);
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.of(context).pop('refresh');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cari Hesap G\u00fcncellenemedi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _model == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('M\u00fc\u015fteri D\u00fczenle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSwitch(
                '\u015eirket mi?',
                _model!.isCompany,
                (v) => setState(() => _model!.isCompany = v),
              ),
              _buildTextField('Ad', _model!.name, (v) => _model!.name = v!),
              _buildTextField(
                'Vergi Dairesi',
                _model!.taxOffice,
                (v) => _model!.taxOffice = v ?? '',
              ),
              _buildTextField(
                'Vergi Numaras\u0131',
                _model!.taxNumber,
                (v) => _model!.taxNumber = v ?? '',
              ),
              _buildTextField(
                'Email',
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
              _buildCountryDropdown(),
              _buildCityDropdown(),
              _buildDistrictDropdown(),
              _buildSwitch(
                'Aktif',
                _model!.isActive,
                (v) => setState(() => _model!.isActive = v),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: inputType,
        maxLines: maxLines,
        validator:
            (v) =>
                (label == 'Ad' || label == 'Ad') &&
                        (v == null || v.trim().isEmpty)
                    ? 'Zorunlu alan'
                    : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFB00034),
    );
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<Country>(
        value: _selectedCountry,
        items:
            _countries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Text(country.name),
              );
            }).toList(),
        onChanged: (Country? newCountry) {
          setState(() {
            _selectedCountry = newCountry;
            _model!.countryIso2 = newCountry?.alpha2Formatted ?? '';
            _filteredCities =
                _cities
                    .where(
                      (c) => c.countryAlpha2 == newCountry?.alpha2Formatted,
                    )
                    .toList();
            _selectedCity = null;
            _selectedDistrict = null;
            _filteredDistricts = [];
            _model!.city = '';
            _model!.district = '';
          });
        },
        decoration: InputDecoration(
          labelText: '\u00dclke',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (val) => val == null ? 'Zorunlu alan' : null,
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<City>(
        value: _selectedCity,
        items:
            _filteredCities.map((city) {
              return DropdownMenuItem<City>(
                value: city,
                child: Text(city.name),
              );
            }).toList(),
        onChanged: (City? newCity) {
          setState(() {
            _selectedCity = newCity;
            _model!.city = newCity?.name ?? '';
            _filteredDistricts =
                _districts.where((d) => d.cityId == newCity?.id).toList();
            _selectedDistrict = null;
            _model!.district = '';
          });
        },
        decoration: InputDecoration(
          labelText: '\u015eehir',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<District>(
        value: _selectedDistrict,
        items:
            _filteredDistricts.map((district) {
              return DropdownMenuItem<District>(
                value: district,
                child: Text(district.name),
              );
            }).toList(),
        onChanged: (District? newDistrict) {
          setState(() {
            _selectedDistrict = newDistrict;
            _model!.district = newDistrict?.name ?? '';
          });
        },
        decoration: InputDecoration(
          labelText: '\u0130l\u00e7e',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.save),
      label: const Text('Kaydet'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB00034),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}
