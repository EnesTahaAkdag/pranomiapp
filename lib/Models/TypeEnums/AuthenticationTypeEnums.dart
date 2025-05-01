enum PraNomiSubscriptionTypeEnum { monthly, sixMonths, yearly, demo, eInvoice }

PraNomiSubscriptionTypeEnum parseSubscriptionType(int value) {
  switch (value) {
    case 1:
      return PraNomiSubscriptionTypeEnum.monthly;
    case 2:
      return PraNomiSubscriptionTypeEnum.sixMonths;
    case 3:
      return PraNomiSubscriptionTypeEnum.yearly;
    case 5:
      return PraNomiSubscriptionTypeEnum.demo;
    case 6:
      return PraNomiSubscriptionTypeEnum.eInvoice;
    default:
      throw Exception("Bilinmeyen abonelik tipi: $value");
  }
}
