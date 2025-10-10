import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/InvoiceModels/invoice_details_model.dart';
import 'package:pranomiapp/services/InvoiceServices/invoice_details_service.dart';

import '../../../core/di/injection.dart';

class InvoiceDetailPage extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Future<InvoiceDetailsResponseModel> _futureDetails;
  int? _openPanelIndex;

  final _invoiceDetailsService = locator<InvoiceDetailsService>();

  @override
  void initState() {
    super.initState();
    _futureDetails = _invoiceDetailsService.fetchInvoiceDetails(
      invoiceId: widget.invoiceId,
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.label_outline, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceDetailsModel item) {
    final dateFmt =
        // ignore: unnecessary_null_comparison
        item.date != null ? DateFormat('dd.MM.yyyy').format(item.date) : '-';
    final dueFmt =
        // ignore: unnecessary_null_comparison
        item.dueDate != null
            ? DateFormat('dd.MM.yyyy').format(item.dueDate)
            : '-';

    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.documentNumber,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoTile('Tarih', dateFmt),
            _infoTile('Vade', dueFmt),
            _infoTile('Müşteri', item.customerName),
            _infoTile(
              'Şehir / İlçe',
              '${item.customerCityName}, ${item.customerDistrictName}',
            ),
            if (item.customerAddress.isNotEmpty)
              _infoTile('Adres', item.customerAddress),
            if (item.customerPhone != null && item.customerPhone!.isNotEmpty)
              _infoTile('Telefon', item.customerPhone!),
            const SizedBox(height: 12),
            Text(
              'Toplam: ${currencyFormatter.format(item.balance)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ExpansionPanel _buildLinePanel(InvoiceLineModel line, int index) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return ExpansionPanelRadio(
      value: index,
      backgroundColor: Colors.white,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  line.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormatter.format(line.lineAmountIncVatRate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${line.quantity.toStringAsFixed(0)} ${line.unitType}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile(
              'Miktar',
              '${line.quantity.toStringAsFixed(2)} ${line.unitType}',
            ),
            _infoTile(
              'Birim Fiyat',
              currencyFormatter.format(line.unitPriceExcVat),
            ),
            _infoTile('KDV', currencyFormatter.format(line.vatRateLineAmount)),
            if (line.communicationTaxLineAmount > 0)
              _infoTile(
                'İletişim Vergisi',
                currencyFormatter.format(line.communicationTaxLineAmount),
              ),
            if (line.consumptionTaxLineAmount > 0)
              _infoTile(
                'Tüketim Vergisi',
                currencyFormatter.format(line.consumptionTaxLineAmount),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fatura Detayları')),
      body: FutureBuilder<InvoiceDetailsResponseModel>(
        future: _futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Yükleme hatası: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final item = snapshot.data!.item;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildInvoiceCard(item),

              // Kalem başlık
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Kalemler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              ExpansionPanelList.radio(
                elevation: 2,
                expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 4),
                animationDuration: const Duration(milliseconds: 300),
                initialOpenPanelValue: _openPanelIndex,
                children: [
                  for (int i = 0; i < item.invoiceLines.length; i++)
                    _buildLinePanel(item.invoiceLines[i], i),
                ],
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    _openPanelIndex = isExpanded ? null : index;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
