class FileDocument {
  final String fileName;
  final List<int> bytes;

  const FileDocument({required this.fileName, required this.bytes});

  Map<String, dynamic> toJson() => {'fileName': fileName, 'bytes': bytes};

  static FileDocument fromJson(Map<String, dynamic> json) => FileDocument(
        fileName: json['fileName'] ?? 'another',
        bytes: json['bytes'] == null ? [] : List<int>.from(json['bytes']),
      );
}
