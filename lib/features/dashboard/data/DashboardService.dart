import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/features/dashboard/data/DashboardModel.dart';

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