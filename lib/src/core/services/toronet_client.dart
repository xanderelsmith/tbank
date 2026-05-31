import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:tbank/src/core/services/api_urls.dart';
import 'package:toronet/toronet.dart';
import 'package:toronet/src/tns/tns.dart';
import '../util/env.dart';

class ToronetClient {
  late ToronetSDK _sdk;
  Network _network = Network.testnet;

  ToronetClient() {
    _network = Env.network;
    _sdk = ToronetSDK(
      network: _network,
      baseUrl: _network == Network.testnet ? ApiUrl.baseUrl : null,
      customConnectWUrl: _network == Network.mainnet ? 'https://restapi.connectw.com/api' : ApiUrl.baseUrl,
      dio: _createDio(),
    );
  }

  ToronetSDK get sdk => _sdk;
  Network get network => _network;
  String get nodeUrl => _network == Network.testnet
      ? ApiUrl.baseUrl
      : 'https://api.toronet.org/';

  void switchNetwork(Network newNetwork) {
    _network = newNetwork;
    _sdk = ToronetSDK(
      network: newNetwork,
      baseUrl: newNetwork == Network.testnet ? ApiUrl.baseUrl : null,
      customConnectWUrl: newNetwork == Network.mainnet ? 'https://restapi.connectw.com/api' : ApiUrl.baseUrl,
      dio: _createDio(),
    );
  }

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) {
        return status != null && (status >= 200 && status < 300 || status == 308);
      },
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.endsWith('/payment/toro/')) {
          options.path = options.path.replaceFirst('/payment/toro/', '/payment/');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.statusCode == 308) {
          var location = response.headers.value('location');
          if (location != null) {
            if (location.startsWith('/')) {
              final originalUri = response.requestOptions.uri;
              final portStr = (originalUri.hasPort && originalUri.port != 80 && originalUri.port != 443) ? ':${originalUri.port}' : '';
              location = '${originalUri.scheme}://${originalUri.host}$portStr$location';
            }
            print('Redirecting 308 to resolved location: $location');
            try {
              final newOptions = Options(
                method: response.requestOptions.method,
                headers: response.requestOptions.headers,
              );
              final newResponse = await dio.request(
                location,
                data: response.requestOptions.data,
                queryParameters: response.requestOptions.queryParameters,
                options: newOptions,
              );
              if (newResponse.data is String) {
                try {
                  newResponse.data = jsonDecode(newResponse.data);
                } catch (_) {
                  newResponse.data = {'result': false, 'error': newResponse.data};
                }
              }
              if (newResponse.data is List) {
                newResponse.data = newResponse.data.isNotEmpty ? newResponse.data.first : {};
              }
              print('Toronet 308 Redirected Response: ${newResponse.data}');
              return handler.resolve(newResponse);
            } catch (e) {
              print('Redirect request failed with error: $e');
              // ignore and fallback
            }
          }
        }
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (_) {
            response.data = {'result': false, 'error': response.data};
          }
        }
        if (response.data is List) {
          // If Toronet API returns a List but SDK expects Map, wrap it or take first
          response.data = response.data.isNotEmpty ? response.data.first : {};
        }
        print('Toronet Response Data: ${response.data}');
        return handler.next(response);
      },
    ));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
    return dio;
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
