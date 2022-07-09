class AttendanceModel {
  String? email;
  String? firstName;
  String? lastName;
  String? phoneNum;
  DateTime? timeStamp;

  AttendanceModel({this.email, this.firstName, this.lastName, this.phoneNum, this.timeStamp});

  factory AttendanceModel.fromMap(map) {
    return AttendanceModel(
        email: map['email'],
        firstName: map['firstName'],
        lastName: map['lastName'],
        phoneNum: map['phoneNum'],
        timeStamp: map['timeStamp']);
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNum': phoneNum,
      'timeStamp': timeStamp
    };
  }
}
