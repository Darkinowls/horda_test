abstract class HordaException {
  get message;

  @override
  String toString() {
    return message;
  }
}

class OpenaiException extends HordaException {
  final String _message;

  OpenaiException(this._message);

  @override
  get message => _message;
}
