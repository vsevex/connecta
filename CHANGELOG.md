# 1.1.0

- Enchanced data listener functionality to handle data larger than 1024 bytes. This is a common Dart behavior where data is received sequentially (maybe only in SecureSocket connections), and this improvement ensures proper parsing even for large data chunks. The `onData` method now handled partial data and waits for the complete data before processing.
- Added functionality to check for data ending (EOF), which can be declared by the user.

## 1.0.1

- Add timeout to creating task connection in both TCP and TLS connection types.

## 1.0.0+1

- Fix TLS unassigned problem.

## 1.0.0

- Initial stable release.

## 1.0.0-beta2

- Lil exception fix.

## 1.0.0-beta1

- Initial release, but not stable yet.
- Support for TCP and TLS (Secure) socket connections.
- `ConnectaToolkit` for configuration of connection parameters.
- Ability to upgrade connection from TCP to TLS.
