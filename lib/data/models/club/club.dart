
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

  Club.map(dynamic o) {
    if (o != null) {
      name = o['name'];
      description = o['description'];
      id = o['id'];
      adminId = o['admin_id'];
      createdAt =
          o['created_at'] != null ? DateTime.parse(o['created_at']) : null;
    }
  }

  Club.withError(String errorValue)
      : name = null,
        description = null,
        id = null,
        adminId = null,
        exception = errorValue;

  bool get isValid =>
      name != null && description != null && id != null && adminId != null;

  factory Club.fromJson(Map<String, dynamic> json) => Club.map(json);

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'id': id,
        'admin_id': adminId,
        'created_at': createdAt?.toIso8601String(),
      };

  Club deletedCopy() {
    return Club(
      id: id,
      name: name,
      description: description,
      isDeleted: true,
    );
  }
}
