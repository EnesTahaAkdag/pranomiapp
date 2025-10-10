import 'package:dio/dio.dart';
import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/Models/InvoiceModels/invoice_details_model.dart';

class InvoiceDetailsService extends ApiServiceBase {
  Future<InvoiceDetailsResponseModel> fetchInvoiceDetails({
    required int invoiceId,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        '/Invoice/Detail/$invoiceId',
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        return InvoiceDetailsResponseModel.fromJson(response.data);
      } else {
        throw Exception("Fatura Detayları Gelmedi: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio Hatası: ${e.message}");
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }
}
