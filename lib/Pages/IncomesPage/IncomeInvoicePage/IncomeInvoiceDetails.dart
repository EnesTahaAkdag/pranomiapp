// lib/pages/InvoiceDetailPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceDetailsService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceDetailsModel.dart';

class InvoiceDetailPage extends StatefulWidget {
  final int invoiceId;
  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  // ignore: library_private_types_in_public_api
  _InvoiceDetailPageState createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Future<InvoiceDetailsResponseModel> _futureDetails;
  final _expandedLines = <int>{};

  @override
  void initState() {
    super.initState();
    _futureDetails = InvoiceDetailsService().fetchInvoiceDetails(
      invoiceId: widget.invoiceId,
    );
  }

  Widget _buildGeneralInfo(InvoiceDetailsModel item) {
    final dateFmt = DateFormat('dd.MM.yyyy').format(item.date);
    final dueFmt = DateFormat('dd.MM.yyyy').format(item.dueDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Bilgiler',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _infoRow('Fatura No', item.documentNumber),
            _infoRow('Tarih', dateFmt),
            _infoRow('Vade', dueFmt),
            _infoRow('Müşteri', item.customerName),
            _infoRow(
              'Adres',
              '${item.customerCityName}, ${item.customerDistrictName}',
            ),
            if (item.customerAddress.isNotEmpty)
              _infoRow('Detaylı Adres', item.customerAddress),
            if (item.customerPhone != null)
              _infoRow('Telefon', item.customerPhone!),
            if (item.email.isNotEmpty) _infoRow('E-Posta', item.email),
            const SizedBox(height: 8),
            Text(
              'Genel Toplam: ₺${item.balance.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildLineItems(InvoiceDetailsModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionPanelList(
        expansionCallback: (i, isOpen) {
          setState(() {
            isOpen ? _expandedLines.remove(i) : _expandedLines.add(i);
          });
        },
        children:
            item.invoiceLines.asMap().entries.map((entry) {
              final idx = entry.key;
              final line = entry.value;
              final amount = line.lineAmountIncVatRate.toStringAsFixed(2);
              return ExpansionPanel(
                isExpanded: _expandedLines.contains(idx),
                headerBuilder: (_, __) {
                  return ListTile(
                    title: Text(line.productName),
                    subtitle: Text('₺$amount'),
                    trailing: Text(line.unitType),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      _infoRow('Adet', line.quantity.toString()),
                      _infoRow(
                        'Birim Fiyat',
                        '₺${line.unitPriceExcVat.toStringAsFixed(2)}',
                      ),
                      _infoRow(
                        'KDV Tutarı',
                        '₺${line.vatRateLineAmount.toStringAsFixed(2)}',
                      ),
                      _infoRow(
                        'İletişim Vergisi',
                        '₺${line.communicationTaxLineAmount.toStringAsFixed(2)}',
                      ),
                      _infoRow(
                        'Tüketim Vergisi',
                        '₺${line.consumptionTaxLineAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<InvoiceDetailsResponseModel>(
        future: _futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata yükleniyor: ${snapshot.error}'));
          }
          final item = snapshot.data!.item;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildGeneralInfo(item),
              const SizedBox(height: 12),
              Text('Kalemler', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              _buildLineItems(item),
            ],
          );
        },
      ),
    );
  }
}
