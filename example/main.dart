import 'dart:developer';

import 'package:connecta/connecta.dart';

Future<void> main() async {
  final connecta = Connecta(
    ConnectaToolkit(
      hostname: 'example.org',
      port: 5222,
      connectionType: ConnectionType.upgradableTcp,
    ),
  );

  await connecta.connect(
    ConnectaListener(onData: (data) async => _handleData(connecta, data)),
  );
  connecta.send(
    "<stream:stream to='example.org' xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:client' xml:lang='en' version='1.0'>",
  );
}

Future<void> _handleData(
  Connecta connecta,
  List<int> data,
) async {
  final rawData = String.fromCharCodes(data);
  if (rawData.contains(
    "<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'><required/></starttls>",
  )) {
    connecta.send('<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls" />');
  } else if (rawData == "<proceed xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>") {
    await connecta.upgradeConnection(
      listener:
          ConnectaListener(onData: (data) => log(String.fromCharCodes(data))),
    );

    connecta.send(
      "<stream:stream to='example.org' xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:client' xml:lang='en' version='1.0'>",
    );
  }
}
