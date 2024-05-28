class UserEdit {
  String? fullName;
  String? birthDate;

  UserEdit.map(dynamic o) {
    if (o != null) {
      fullName = o['full_name'];
      birthDate = o['birth_date'];
    }
  }

  String? get getFirstName => fullName;
  String? get getBirthdate => birthDate;

}