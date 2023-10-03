import 'dart:developer';

import 'package:connecta/connecta.dart';

Future<void> main() async {
  final connecta = Connecta(
    ConnectaToolkit(
      hostname: 'localhost',
      port: 443,
      startTLS: true,
      certificatePath: 'public/cert.pem',
      keyPath: 'public/key.pem',
    ),
  );

  try {
    await connecta.connect(onData: (value) => log(value.toString()));

    /// Upgrade the connection to secure if needed.
    await connecta.upgradeConnection();

    connecta.send('hert');
  } on ConnectaException catch (error) {
    log(error.message);
  }
}
