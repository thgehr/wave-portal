import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_client/contract_linking.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/browser.dart';

import 'WavePortal.g.dart';

final List<String> entries = <String>['A', 'B', 'C'];
final List<int> colorCodes = <int>[600, 500, 100];

Future main() async {
  // print('Beginning of Main function');
  // // Use Environment Variables
  // await dotenv.load(fileName: "../.env");

  // final eth = window.ethereum;
  // if (eth == null) {
  //   print('MetaMask is not available');
  //   return;
  // }

  // String rpcUrl = dotenv.env['WEB3_INFURA_RCP']!;
  // print('RPC URL is $rpcUrl');
  // String wsUrl = dotenv.env['WEB3_INFURA_WS']!;

  // final client = Web3Client.custom(eth.asRpcService());
  // final credentials = await eth.requestAccount();

  // String privateKey = dotenv.env['PRIVATE_KEY']!;
  // print('Creating Client and credentials');
  // final client = Web3Client(rpcUrl, Client(), socketConnector: () {
  //   return IOWebSocketChannel.connect(wsUrl).cast<String>();
  // });
  // final credentials = EthPrivateKey.fromHex(privateKey);

  // print('Using ${credentials.address}');
  //print('Client is listening: ${await client.isListeningForNetwork()}');

  // final message = Uint8List.fromList(utf8.encode('Hello from web3dart'));
  // final signature = await credentials.signPersonalMessage(message);
  // print('Signature: ${base64.encode(signature)}');

  // final EthereumAddress contractAddr =
  //     EthereumAddress.fromHex('0xD8Cbd670490fD1680b2947f2AE5e18bA81b4bc68');
  // print('Contract address saved');
  // final wavePortal = WavePortal(address: contractAddr, client: client);
  // print('Get Contract to flutter');
  // await wavePortal.wave(credentials: credentials);

  // final waveCount = await wavePortal.getTotalWaves();
  // print('We have ${waveCount} waves');

  // await client.dispose();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContractLinking(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Wave Portal',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.brown,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Getting the value and object or contract_linking
    var contractLink = Provider.of<ContractLinking>(context);
    TextEditingController textController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Wave Portal!"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: contractLink.isLoading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Hello, I'm looking forwards to your waves :) ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            contractLink.isMetaMask
                                ? Text(
                                    "I already have ${contractLink.waveCount} waves.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.blueGrey),
                                  )
                                : Container(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 29,
                            horizontal: 256,
                          ),
                          child: TextFormField(
                            controller: textController,
                            style: TextStyle(color: Colors.blueGrey),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Your Wave",
                                hintText: "Add a message to your wave :)",
                                icon: Icon(
                                  Icons.add_reaction_outlined,
                                  color: Colors.amberAccent[300],
                                )),
                          ),
                        ),
                        contractLink.isMetaMask
                            ? Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: ElevatedButton(
                                  child: Text(
                                    'Wave at me',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.brown[200],
                                  ),
                                  onPressed: () {
                                    contractLink.wave(textController.text);
                                    textController.clear();
                                  },
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: ElevatedButton(
                                  child: Text(
                                    'Connect Wallet',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.brown[200],
                                  ),
                                  onPressed: () {
                                    contractLink.connectWallet();
                                  },
                                ),
                              ),
                        contractLink.isMetaMask
                            ? buildListView(
                                context,
                                contractLink.waveList
                                    .sublist(contractLink.waveList.length - 3))
                            : Padding(
                                padding: const EdgeInsets.all(64.0),
                                child: Text(
                                    'You have to connect your MetaMask in order to wave at me and see all past waves.'),
                              ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

Widget buildListView(BuildContext context, List waveList) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 64, vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Here you can see the last three waves."),
        ListTile(
          trailing: Text('Timestamp: ${waveList.last[2]}'),
          title: Text('${waveList.last[1]}'),
          subtitle: Text('Address: ${waveList.last[0]}'),
        ),
        ListTile(
          trailing: Text('${waveList[1][2]}'),
          title: Text('${waveList[1][1]}'),
          subtitle: Text('${waveList[1][0]}'),
        ),
        ListTile(
          trailing: Text('${waveList[0][2]}'),
          title: Text('${waveList[0][1]}'),
          subtitle: Text('${waveList[0][0]}'),
        )
      ],
      // children ListTile(
      //   trailing: Text('${waveList[index].timestamp}'),
      //   title: Text('${waveList[index].message}'),
      //   subtitle: Text('${waveList[index].waver}'),
    ),
  );
}
