import 'package:alrino/domain/models/fhn/fhn_history.dart';
import 'package:alrino/domain/models/frd/ftd_history_table.dart';
import 'package:alrino/domain/models/org.dart';
import 'package:alrino/domain/models/sz/sz_operation.dart';
import 'package:alrino/domain/repository/frd_repository.dart';
import 'package:alrino/domain/repository/user_repository.dart';
import 'package:get/get.dart';

/// Документ
class Document {
  int id;
  DateTime data;
  String year;
  String service;
  String contract;
  String project;
  String fio;
  String type;
  String description;
  String url;
  DateTime begin;
  DateTime end;
  String place;
  String intensity;
  String post;
  String phone;
  String idOrg;

  Document({
    required this.id,
    required this.data,
    required this.year,
    required this.service,
    required this.contract,
    required this.project,
    required this.fio,
    required this.type,
    required this.description,
    required this.url,
    required this.begin,
    required this.end,
    required this.place,
    required this.intensity,
    required this.post,
    required this.phone,
    required this.idOrg,
  });
  factory Document.fromFrd(
      {required FrdHystory frd, required Organisation org}) {
    Duration duration = frd.end.difference(frd.begin);
    double workHours = duration.inSeconds.toDouble() == 0
        ? 0
        : duration.inSeconds.toDouble() / 3600;
    return Document(
      id: 0,
      year: frd.year,
      fio: Get.find<UserRepository>().user.fullName,
      data: frd.begin,
      service: org.service,
      contract: org.contract,
      project: org.name,
      type: 'ФРД',
      description: '',
      url: frd.pathName,
      begin: frd.begin,
      end: frd.end,
      place: 'Выезд',
      intensity: workHours.toStringAsFixed(3),
      post: frd.post,
      phone: frd.phone,
      idOrg: org.id,
    );
  }

  factory Document.fromFhn(
      {required FhnHystory fhn, required Organisation org}) {
    Duration duration = fhn.end.difference(fhn.begin);
    double workHours = duration.inSeconds.toDouble() == 0
        ? 0
        : duration.inSeconds.toDouble() / 3600;
    return Document(
      id: 0,
      year: fhn.year,
      fio: Get.find<UserRepository>().user.fullName,
      data: fhn.begin,
      service: org.service,
      contract: org.contract,
      project: org.name,
      type: 'ФХН',
      description: '',
      url: fhn.pathName,
      begin: fhn.begin,
      end: fhn.end,
      place: 'Выезд',
      intensity: workHours.toStringAsFixed(3),
      post: fhn.post,
      phone: fhn.phone,
      idOrg: org.id,
    );
  }

  factory Document.fromSzOperation(
      {required OperationSz operSz,
      required Organisation? org,
      required bool isOuter}) {
    DateTime end = operSz.beginDate.add(operSz.durationOperation);
    double workHours = operSz.durationOperation.inSeconds.toDouble() == 0
        ? 0
        : operSz.durationOperation.inSeconds.toDouble() / 3600;
    return Document(
      id: 0,
      year: operSz.beginDate.year.toString(),
      fio: Get.find<UserRepository>().user.fullName,
      data: operSz.beginDate,
      service: org?.service ?? '',
      contract: org?.contract ?? '',
      project: org?.name ?? operSz.org,
      type: 'СЗ',
      description: operSz.tasks,
      url: Get.find<FrdRepository>().tempSz.pathName,
      begin: operSz.beginDate,
      end: end,
      place: isOuter ? 'Выезд' : 'Офис',
      intensity: workHours.toStringAsFixed(3),
      post: '',
      phone: '',
      idOrg: org?.id ?? '0',
    );
  }

  factory Document.fromJson(Map<String, dynamic> data) {
    return Document(
      id: data['id'] == null ? 0 : int.parse(data['id']),
      data:
          data['data'] == null ? DateTime.now() : DateTime.parse(data['data']),
      year: data['year'] ?? '',
      service: data['service'] ?? '',
      contract: data['contract'] ?? '',
      project: data['project'] ?? '',
      fio: data['fio'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      url: data['url'] ?? '',
      begin: data['begin'] == null
          ? DateTime.now()
          : DateTime.parse(data['begin']),
      end: data['end'] == null ? DateTime.now() : DateTime.parse(data['end']),
      place: data['place'] ?? '',
      intensity: data['intensity'] ?? '',
      post: data['post'] ?? '',
      phone: data['phone'] ?? '',
      idOrg: data['idOrg'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'data': data.toIso8601String(),
      'year': year,
      'service': service,
      'contract': contract,
      'project': project,
      'fio': fio,
      'type': type,
      'description': description,
      'url': url,
      'begin': begin.toIso8601String(),
      'end': end.toIso8601String(),
      'place': place,
      'intensity': intensity,
      'post': post,
      'phone': phone,
      'idOrg': idOrg,
    };
  }

  factory Document.initial() {
    return Document(
      id: 0,
      data: DateTime.now(),
      year: '',
      service: '',
      contract: '',
      project: '',
      fio: '',
      type: '',
      description: '',
      url: '',
      begin: DateTime.now(),
      end: DateTime.now(),
      place: '',
      intensity: '',
      post: '',
      phone: '',
      idOrg: '0',
    );
  }
}
