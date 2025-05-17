import 'package:flutter/material.dart';

class EInvoicesPage extends StatefulWidget {
  final int invoiceType;
  final int ansverType;
  const EInvoicesPage({
    super.key,
    required this.ansverType,
    required this.invoiceType,
  });

  @override
  State<EInvoicesPage> createState() => _EInvoicesPageState();
}

class _EInvoicesPageState extends State<EInvoicesPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
