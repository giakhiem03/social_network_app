class Role {
  Role(
      {required this.roleId,
        this.roleName,
        });

  final int roleId;
  final String? roleName;

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
        roleId: json["userId"],
        roleName: json["roleName"]
    );
  }

  Map<String, dynamic> toJson() => {
    "roleId": roleId,
    "roleName": roleName
  };
}