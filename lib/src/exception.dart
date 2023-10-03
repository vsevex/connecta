/// An abstract base class for exceptions thrown by the [Connecta].
///
/// ```dart
/// try {
///   // Code that may throw ConnectaException
/// } on ConnectaException catch (exception) {
///   log('Connecta Exception: ${exception.message}');
/// }
/// ```
abstract class ConnectaException implements Exception {
  const ConnectaException(this.message);

  /// A [String] providing additional details about the exception.
  final String message;
}

/// Thrown when an error occurs while establishing a `TCP` connection.
class TCPConnectionException extends ConnectaException {
  const TCPConnectionException(this.error)
      : super(
          'Connecta exception thrown when establishing TCP connection: $error',
        );

  final dynamic error;
}

/// Thrown when the data to be written is not in a valid type.
class DataTypeException extends ConnectaException {
  DataTypeException(this.type)
      : super('Data to be written is not in valid type: $type');

  final Type type;
}

/// Thrown when an attempt to upgrade a socket is made without creating a socket
/// in advance.
class NoSocketAttached extends ConnectaException {
  const NoSocketAttached()
      : super('To upgrade socket you must create Socket connection in advance');
}

/// Thrown when attempting to send a message to the socket without upgrading the
/// socket first.
class NoSecureSocketException extends ConnectaException {
  NoSecureSocketException()
      : super(
          'In order to send message to the socket, you need to upgrade socket first',
        );
}

/// Thrown when an error occurs while securing a socket connection.
class SecureSocketException extends ConnectaException {
  SecureSocketException(this.error)
      : super('An error occured while Securing Socket: $error');

  final dynamic error;
}

/// Thrown when an error occurs while building a certificate for the socket
/// context.
class BuildSocketContextException extends ConnectaException {
  const BuildSocketContextException()
      : super('An error occured while building certificate for Socket Context');
}

/// Thrown when the provided certificate or key file is invalid.
class InvalidCertOrKeyException extends ConnectaException {
  const InvalidCertOrKeyException()
      : super('Provided certificate or key file is invalid');
}
