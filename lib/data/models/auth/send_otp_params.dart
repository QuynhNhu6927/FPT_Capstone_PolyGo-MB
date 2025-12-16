class SendOtpParams {
  final String mail;
  final int verificationType;

  SendOtpParams({required this.mail, required this.verificationType});

  Map<String, dynamic> toQueryParams() => {
    'mail': mail,
    'verificationType': verificationType,
  };
}
