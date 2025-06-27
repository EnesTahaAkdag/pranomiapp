// ignore: file_names, constant_identifier_names
enum CustomerTypeEnum { Customer, Supplier, Employee }

extension CustomerTypeExtension on CustomerTypeEnum {
  String get name {
    switch (this) {
      case CustomerTypeEnum.Customer:
        return "Customer";
      case CustomerTypeEnum.Supplier:
        return "Supplier";
      case CustomerTypeEnum.Employee:
        return "Employee";
    }
  }

  static CustomerTypeEnum fromString(String value) {
    switch (value) {
      case "Customer":
        return CustomerTypeEnum.Customer;
      case "Supplier":
        return CustomerTypeEnum.Supplier;
      case "Employee":
        return CustomerTypeEnum.Employee;
      default:
        throw ArgumentError("Invalid CustomerTypeEnum value: $value");
    }
  }
}
