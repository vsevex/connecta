import 'dart:developer';

import 'package:connecta/connecta.dart';

Future<void> main() async {
  final connecta = Connecta(
    ConnectaToolkit(
      hostname: 'localhost',
      certificatePath: 'public/cert.pem',
      keyPath: 'public/key.pem',
    ),
  );

  await connecta.connect(onData: (value) => log(value.toString()));
  await connecta.upgradeConnection();

  connecta.send('hert');
}
