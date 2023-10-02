abstract class ConnectaException implements Exception {
  const ConnectaException(this.message);

  final String message;
}

class TCPConnectionException extends ConnectaException {
  const TCPConnectionException(this.error)
      : super(
          'Connecta exception thrown when establishing TCP connection: $error',
        );

  final dynamic error;
}

class DataTypeException extends ConnectaException {
  DataTypeException(this.type)
      : super('Data to be written is not in valid type: $type');

  final Type type;
}

class NoSocketAttached extends ConnectaException {
  const NoSocketAttached()
      : super('To upgrade socket you must create Socket connection in advance');
}

class NoSecureSocketException extends ConnectaException {
  NoSecureSocketException()
      : super(
          'In order to send message to the socket, you need to upgrade socket first',
        );
}

class SecureSocketException extends ConnectaException {
  SecureSocketException(this.error)
      : super('An error occured while Securing Socket: $error');

  final dynamic error;
}

class BuildSocketContextException extends ConnectaException {
  const BuildSocketContextException()
      : super('An error occured while building certificate for Socket Context');
}

class InvalidCertOrKeyException extends ConnectaException {
  const InvalidCertOrKeyException()
      : super('Provided certificate or key file is invalid');
}
