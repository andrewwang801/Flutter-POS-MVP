// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_details_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentDetailsData _$PaymentDetailsDataFromJson(Map<String, dynamic> json) =>
    PaymentDetailsData(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      salesRef: json['salesRef'] as int,
    );

Map<String, dynamic> _$PaymentDetailsDataToJson(PaymentDetailsData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
      'salesRef': instance.salesRef,
    };
