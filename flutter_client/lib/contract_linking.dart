import 'dart:html';
import 'package:web_socket_channel/io.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/browser.dart';

import 'WavePortal.g.dart';

class ContractLinking extends ChangeNotifier {
  bool isLoading = false;
  bool isMetaMask = false;

  final EthereumAddress _contractAddress =
      EthereumAddress.fromHex('0xBBf5326A9bB69C8E0dBF326678C8C437f090b58B');

  String rpcUrl =
      'https://rinkeby.infura.io/v3/7577fca1369141f2a6d05ab048d45eba';
  String wsUrl =
      'wss://rinkeby.infura.io/ws/v3/7577fca1369141f2a6d05ab048d45eba';

  Web3Client? client;
  WavePortal? _contract;
  Credentials? _credentials;

  BigInt? waveCount;
  List waveList = [];

  ContractLinking() {}

  connectWallet() async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    final eth = window.ethereum;
    if (eth == null) {
      print('MetaMask is not available');
      notifyListeners();
      return;
    }
    isMetaMask = true;
    // final _client = Web3Client.custom(eth.asRpcService());
    client = Web3Client(rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    _credentials = await eth.requestAccount();
    _contract = WavePortal(address: _contractAddress, client: client!);
    getAllWaves();
    getTotalWaveCount();
  }

  getAllWaves() async {
    waveList = await _contract!.getAllWaves();
  }

  getTotalWaveCount() async {
    // Getting the current name declared in the smart contract.

    waveCount = await _contract?.getTotalWaves();

    isLoading = false;
    notifyListeners();
  }

  wave(String _message) async {
    // Setting the name to nameToSet(name defined by user)
    isLoading = true;
    notifyListeners();
    try {
      final txHash = await _contract!.wave(
        _message,
        credentials: _credentials!,
        transaction: Transaction(
          maxGas: 300000,
          // gasPrice: EtherAmount.fromUnitAndValue(
          //   EtherUnit.gwei,
          //   1,
          // ),
        ),
      );
      await client!
          .addedBlocks()
          .asyncMap((_) => client!.getTransactionReceipt(txHash))
          .where((receipt) => receipt != null)
          .first;
    } catch (e) {
      print('Transaction canceled');
    }
    getAllWaves();
    getTotalWaveCount();
  }
}
