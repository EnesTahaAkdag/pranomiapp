import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerEditModel.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerAddressModel.dart';
import 'package:pranomiapp/services/CustomerService/CustomerEditService.dart';
import 'package:pranomiapp/services/CustomerService/CustomerDetailService.dart';

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
  List<City> _cities = [];
  List<District> _districts = [];

  Country? _selectedCountry;
  City? _selectedCity;
  District? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadData();
    await _loadCustomer();

    if (_model != null) {}

    setState(() => _isLoading = false);
  }

  Future<void> _loadCustomer() async {
    final response = await CustomerDetailService().getCustomerDetail(
      widget.customerId,
    );
    if (response != null) {
      _model = CustomerEditModel(
        id: response.id,
        name: response.name,
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
        type: CustomerTypeExtension.fromString(response.type),
      );
    } else if (context.mounted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Müşteri bilgisi yüklenemedi. Tekrar deneyin."),
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
        (json.decode(cityData)[0] as List)
            .map((e) => City.fromJson(e))
            .toList();

    _districts =
        (json.decode(districtData)[0] as List)
            .map((e) => District.fromJson(e))
            .toList();
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cari Hesap Güncellenemedi.'),
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
      appBar: AppBar(title: const Text('Müşteri Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSwitch(
                'Şirket mi?',
                _model!.isCompany,
                (v) => setState(() => _model!.isCompany = v),
              ),
              _buildTextField(
                'Ad',
                _model!.name,
                (v) => _model!.name = v ?? '',
              ),
              _buildTextField(
                'Vergi Dairesi',
                _model!.taxOffice,
                (v) => _model!.taxOffice = v ?? '',
              ),
              _buildTextField(
                'Vergi Numarası',
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
                const SizedBox(height: 10),
                _customCityInput(),
                const SizedBox(height: 10),
                _customDistrictInput(),
              ],
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
                (label == 'Ad' && (v == null || v.trim().isEmpty))
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

  Widget _countryDropdown() => DropdownSearch<Country>(
    popupProps: PopupProps.menu(showSearchBox: true, fit: FlexFit.loose),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Ülke *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
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
    popupProps: PopupProps.menu(showSearchBox: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'Şehir',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
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
    popupProps: PopupProps.menu(showSearchBox: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      dropdownSearchDecoration: InputDecoration(
        labelText: 'İlçe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        initialValue: _model?.city,
        validator: _requiredValidator,
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        initialValue: _model?.district,
        validator: _requiredValidator,
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

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null;
}
