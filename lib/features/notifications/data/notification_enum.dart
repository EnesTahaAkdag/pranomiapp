enum NotificationListTypeEnum {
  ProductOutOfStock,
  OrderNew,
  OrderCancelled,
  ClaimNew,
  StockChange,
  OrderInvoiceOrWaybillAdd,
  OrderInvoiceOrWaybillUpdate,
  OrderInvoiceOrWaybillDelete,
  OrderInvoiceOrWaybillCancelled,
  OrderInvoiceOrWaybillError,
  EArchiceInvoiceCancel,
  EDocumentError,
  TransactionDelete,
}

NotificationListTypeEnum getNotificationTypeFromValue(int value) {
  switch (value) {
    case 1:
      return NotificationListTypeEnum.ProductOutOfStock;
    case 2:
      return NotificationListTypeEnum.OrderNew;
    case 3:
      return NotificationListTypeEnum.OrderCancelled;
    case 4:
      return NotificationListTypeEnum.ClaimNew;
    case 5:
      return NotificationListTypeEnum.StockChange;
    case 6:
      return NotificationListTypeEnum.OrderInvoiceOrWaybillAdd;

    case 7:
      return NotificationListTypeEnum.OrderInvoiceOrWaybillUpdate;
    case 8:
      return NotificationListTypeEnum.OrderInvoiceOrWaybillDelete;
    case 9:
      return NotificationListTypeEnum.OrderInvoiceOrWaybillCancelled;
    case 10:
      return NotificationListTypeEnum.OrderInvoiceOrWaybillError;

    case 11:
      return NotificationListTypeEnum.EArchiceInvoiceCancel;
    case 12:
      return NotificationListTypeEnum.EDocumentError;
    case 13:
      return NotificationListTypeEnum.TransactionDelete;

    default:
      throw ArgumentError('Invalid value: $value');
  }
}

String getNotificationNameFromType(NotificationListTypeEnum type) {
  switch (type) {
    case NotificationListTypeEnum.ProductOutOfStock:
      return "Stoğu Biten Ürünler";
    case NotificationListTypeEnum.OrderNew:
      return "Yeni Sipariş";
    case NotificationListTypeEnum.OrderCancelled:
      return "İptal Sipariş";
    case NotificationListTypeEnum.ClaimNew:
      return "Yeni İade";
    case NotificationListTypeEnum.StockChange:
      return "Stok Değişimi";
    case NotificationListTypeEnum.OrderInvoiceOrWaybillAdd:
      return "Sipariş Fatura veya İrsaliye Ekleme";
    case NotificationListTypeEnum.OrderInvoiceOrWaybillUpdate:
      return "Sipariş Fatura veya İrsaliye Güncelleme";
    case NotificationListTypeEnum.OrderInvoiceOrWaybillDelete:
      return "Sipariş Fatura veya İrsaliye Silme";
    case NotificationListTypeEnum.OrderInvoiceOrWaybillCancelled:
      return "Sipariş Fatura veya İrsaliye İptal";
    case NotificationListTypeEnum.OrderInvoiceOrWaybillError:
      return "Sipariş Fatura veya İrsaliye Hatası";
    case NotificationListTypeEnum.EArchiceInvoiceCancel:
      return "E-Arşiv Fatura İptali";
    case NotificationListTypeEnum.EDocumentError:
      return "E-Belge Hatası";
    case NotificationListTypeEnum.TransactionDelete:
      return "Hareket Silme";
  }
}
