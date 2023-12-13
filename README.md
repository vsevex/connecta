# Connecta

Connecta is a Dart package that wraps TLS and TCP communication protocol connections under a package and provides a configurable way to manage these configurations.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  connecta: ^1.0.1
```

Then run:

```bash
dart pub get
```

### Usage

```dart
import 'dart:developer';

import 'package:connecta/connecta.dart';

Future<void> main() async {
  final connecta = Connecta(
    ConnectaToolkit(
      hostname: 'example.org',
      port: 443,
      connectionType: ConnectionType.tls,
    ),
  );

  try {
    await connecta.connect(ConnectaListener(onData: (data) => log(String.fromCharCodes(data))));

    /// Upgrade the connection to secure if needed.
    await connecta.upgradeConnection();

    connecta.send('hello');
  } on ConnectaException catch (error) {
    log(error.message);
  }
}
```

## Contributing to Connecta

I do welcome and appreciate contributions from the community to enhance the `Connecta`. If you have any improvements, bug fixes, or new features to contribute, you can do so by creating a pull request.
