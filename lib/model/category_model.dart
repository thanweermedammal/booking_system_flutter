import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/model/pagination_model.dart';

class CategoryResponse {
  List<Category>? categoryList;
  Pagination? pagination;

  CategoryResponse({this.categoryList, this.pagination});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      categoryList: json['data'] != null ? (json['data'] as List).map((i) => Category.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categoryList != null) {
      data['data'] = this.categoryList!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}
