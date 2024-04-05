class ResultObj {
  String name;
  String status;
  String mobileNumber;

  ResultObj({
    required this.name,
    required this.status,
    required this.mobileNumber,
  });
  factory ResultObj.fromJson(Map<String, dynamic> json) {
    return ResultObj(
      name: json['invitee_name'],
      status: json['status'],
      mobileNumber: json['invitee_contact'],
    );
  }
}
