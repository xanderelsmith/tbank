import 'package:toronet/toronet.dart';
import 'package:toronet/src/tns/tns.dart';
import '../util/env.dart';

class ToronetClient {
  late ToronetSDK _sdk;
  Network _network = Network.testnet;

  ToronetClient() {
    _network = Env.network;
    _sdk = ToronetSDK(network: _network);
  }

  ToronetSDK get sdk => _sdk;
  Network get network => _network;

  void switchNetwork(Network newNetwork) {
    _network = newNetwork;
    _sdk = ToronetSDK(network: newNetwork);
  }

  // Short-hand accessors for SDK services
  WalletService get wallet => _sdk.walletService;
  QueryService get query => _sdk.queryService;
  CurrencyService get currency => _sdk.currencyService;
  TNSService get tns => _sdk.tnsService;
  PaymentsService get payments => _sdk.paymentsService;
  VirtualService get virtual => _sdk.virtualService;
  TokenService get token => _sdk.tokenService;
  RolesService get roles => _sdk.rolesService;
  BlockchainService get blockchain => _sdk.blockchainService;
  ExchangeService get exchange => _sdk.exchangeService;
  BalanceService get balance => _sdk.balanceService;
  UtilService get util => _sdk.utilService;
  AuthService get auth => _sdk.authService;
  ContractService get contract => _sdk.contractService;
  DeployerService get deployer => _sdk.deployerService;

  // Bridge services
  SolanaService get solana => _sdk.solanaService;
  PolygonService get polygon => _sdk.polygonService;
  BSCService get bsc => _sdk.bscService;
  BaseService get base => _sdk.baseService;
  ArbitrumService get arbitrum => _sdk.arbitrumService;
  EthService get eth => _sdk.ethService;
  AvaxService get avax => _sdk.avaxService;
  TronService get tron => _sdk.tronService;
}
