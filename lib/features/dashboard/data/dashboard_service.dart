import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/features/dashboard/data/dashboard_model.dart';

class DashboardService extends ApiServiceBase {
  Future<DashboardResponse?> fetchDashboard(){
    final path = 'pranomihelper/dashboarddata';

    return getRequest<DashboardResponse?>(
      path: path,
      queryParameters: {
      },
      fromJson: (data) => DashboardResponse.fromJson(data),
    );
  }
}