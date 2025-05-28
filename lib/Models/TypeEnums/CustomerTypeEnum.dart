enum CustomerTypeEnum { customer, supplier, employee }

CustomerTypeEnum parseCustomerType(final value) {
  switch (value) {
    case 1:
      return CustomerTypeEnum.customer;
    case 2:
      return CustomerTypeEnum.supplier;
    case 3:
      return CustomerTypeEnum.employee;
    default:
      throw Exception("Bilinmeyen Kullanıcı Tipi: $value");
  }
}
