import 'package:dio/dio.dart';
import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/Models/InvoiceModels/invoice_claim_model.dart';

class InvoiceClaimService extends ApiServiceBase {
  Future<InvoiceClaimResponseModel> fetchInvoiceClaim({
    required int page,
    required int size,
    required int invoiceType,
    String? search,
  }) async {
    final bool hasSearch = search != null && search.trim().isNotEmpty;

    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        hasSearch
            ? "Claim/Claims/${Uri.encodeComponent(search)}?size=$size&page=$page&invoiceType=$invoiceType"
            : "Claim/Claims?size=$size&page=$page&invoiceType=$invoiceType",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return InvoiceClaimResponseModel.fromJson(response.data);
      } else {
        throw Exception("Fatura verisi alınamadı: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio hatası: ${e.message}");
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }
}
