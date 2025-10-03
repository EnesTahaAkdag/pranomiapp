import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerModel.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';

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
            ? '/Customer/$search'
            : '/Customer';

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
