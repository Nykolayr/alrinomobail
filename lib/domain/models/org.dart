import 'dart:convert';

import 'package:alrino/domain/models/division.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

/// класс организации для ФРД, ФРХ, СЗ
class Organisation {
  final String id;
  final String name;
  final String service;
  final String contract;
  final DateTime endDate;
  final String projectManager;
  final String status;
  final int inOffice;
  final int onRoad;
  final List<Divisition> divs;
  final String fio;

  Organisation({
    required this.id,
    required this.name,
    required this.service,
    required this.contract,
    required this.endDate,
    required this.projectManager,
    required this.status,
    required this.inOffice,
    required this.onRoad,
    required this.divs,
    required this.fio,
  });

  List<String> get divNames => divs.map((e) => e.name).toList();

  factory Organisation.fromJson(Map<String, dynamic> data) {
    List<Map<String, dynamic>> divs = [];
    try {
      if (data['department'] != null) {
        if (data['department'] is List<dynamic>) {
          divs = List<Map<String, dynamic>>.from(data['department']);
        } else if (data['department'] is String) {
          divs =
              List<Map<String, dynamic>>.from(json.decode(data['department']));
        } else {
          throw Exception('data[\'department\'] is null or empty');
        }
      } else {
        throw Exception('data[\'department\'] is null or empty');
      }
    } on FormatException catch (e) {
      Logger.e(' data');
      throw Exception('Error decoding department data: $e');
    } catch (e) {
      throw Exception('Error  department anather: $e');
    }

    return Organisation(
      id: data['id'] == null ? '0' : data['id'].toString(),
      name: data['name'] ?? '',
      service: data['service'] ?? '',
      contract: data['contract'] ?? '',
      endDate: data['end_date'] == null
          ? DateTime.now()
          : DateTime.parse(data['end_date']),
      projectManager: data['project_manager'] ?? '',
      status: data['status'].toString(),
      inOffice: data['in_office'] ?? 0,
      onRoad: data['on_road'] ?? 0,
      divs: divs.map<Divisition>((e) => Divisition.fromJson(e)).toList(),
      fio: data['project_manager'] ?? '',
    );
  }

  Organisation copyWith({
    String? name,
    String? id,
    String? service,
    String? contract,
    DateTime? endDate,
    String? projectManager,
    String? status,
    int? inOffice,
    int? onRoad,
    List<Divisition>? divs,
    String? fio,
  }) {
    return Organisation(
      name: name ?? this.name,
      id: id ?? this.id,
      service: service ?? this.service,
      contract: contract ?? this.contract,
      endDate: endDate ?? this.endDate,
      projectManager: projectManager ?? this.projectManager,
      status: status ?? this.status,
      inOffice: inOffice ?? this.inOffice,
      onRoad: onRoad ?? this.onRoad,
      divs: divs ?? this.divs,
      fio: fio ?? this.fio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'service': service,
      'contract': contract,
      'end_date': endDate.toString(),
      'project_manager': projectManager,
      'status': status,
      'in_office': inOffice,
      'on_road': onRoad,
      'department': divs.map((e) => e.toJson()).toList(),
      'fio': fio,
    };
  }

  factory Organisation.initial({String name = ''}) {
    return Organisation(
      id: '',
      name: name,
      service: '',
      contract: '',
      endDate: DateTime.now(),
      projectManager: '',
      status: '',
      inOffice: 0,
      onRoad: 0,
      divs: [],
      fio: '',
    );
  }
}
