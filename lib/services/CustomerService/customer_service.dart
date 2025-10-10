import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/Models/CustomerModels/customer_model.dart';
import 'package:pranomiapp/Models/TypeEnums/customer_type_enum.dart';

class CustomerService extends ApiServiceBase {
  String? name;

  Future<CustomerResponseModel?> fetchCustomers({
    required int page,
    required int size,
    required CustomerTypeEnum customerType,
    String? search,
  }) {
    final path =
        (search != null && search.isNotEmpty)
            ? 'Customer/Customers/$search'
            : 'Customer/Customers';

    return getRequest<CustomerResponseModel>(
      path: path,
      queryParameters: {
        'page': page,
        'size': size,
        'customerType': customerType.name,
      },
      fromJson: (data) => CustomerResponseModel.fromJson(data),
    );
  }
}
