class AiException implements Exception {
  final String msg;
  final int? code;

  const AiException(this.msg, [this.code]);

  @override
  int get hashCode => msg.hashCode ^ code.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AiException && other.msg == msg && other.code == code;
  }

  @override
  String toString() {
    return "$AiException#$hashCode(msg: $msg${code == null ? "" : ", code: $code"})";
  }
}
