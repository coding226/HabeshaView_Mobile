class HistoryModel{
  HistoryModel({
    this.id,
    this.userId,
    this.userName,
    this.paymentId,
    this.price,
    this.subscriptionFrom,
    this.subscriptionTo,
    this.packageId,
    this.planName,
    this.paymentMethod,
    this.createdDate,
    this.currency,
  });
  final int id;
  final  userId;
  final String userName;
  final String paymentId;
  final  price;
  final String subscriptionFrom;
  final String subscriptionTo;
  final  packageId;
  final List planName;
  final String paymentMethod;
  final String createdDate;
  final List currency;

}