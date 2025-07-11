// ignore: constant_identifier_names
enum CustomerTypeEnum { Customer, Supplier, Employee }

CustomerTypeEnum customerType(String value) {
  switch (value) {
    case "Customer":
      return CustomerTypeEnum.Customer;
    case "Supplier":
      return CustomerTypeEnum.Supplier;
    case "Employee":
      return CustomerTypeEnum.Employee;
    default:
      throw Exception("Bilinmeyen Müşteri Tipi: $value");
  }
}
