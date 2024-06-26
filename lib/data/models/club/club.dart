class Club {
  String? name;
  String? description;
  int? id;
  int? adminId;
  DateTime? createdAt;
  String? exception;
  bool? isDeleted;

  Club({
    this.name,
    this.description,
    this.id,
    this.adminId,
    this.createdAt,
    this.exception,
    this.isDeleted = false,
  });

  factory Club.fromJson(Map<String, dynamic> json) => Club(
        name: json['name'],
        description: json['description'],
        id: json['id'],
        adminId: json['admin_id'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        exception: json['detail'], 
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'id': id,
        'admin_id': adminId,
        'created_at': createdAt?.toIso8601String(),
      };

  Club.withError(String errorValue)
      : name = null,
        description = null,
        id = null,
        adminId = null,
        exception = errorValue;

  bool get isValid =>
      name != null && description != null && id != null && adminId != null && createdAt != null;

  Club deletedCopy() {
    return Club(
      id: id,
      name: name,
      description: description,
      isDeleted: true,
    );
  }
}
