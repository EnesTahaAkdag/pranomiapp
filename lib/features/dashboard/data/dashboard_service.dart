import 'package:pranomiapp/features/dashboard/data/dashboard_model.dart';

import '../../../core/services/api_service_base.dart';

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