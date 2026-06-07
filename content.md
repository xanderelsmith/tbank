# Fireship-Style Script: Build a Web3 Wallet & Connect a Store in 100 Seconds

Hi, I just sent 21,200 USD to my account, and it's not what you think. A few days ago, I hopped on a challenge to explore Toronet, and it got me building a Web3 Wallet and connecting a store. That is what I am going to try to explain to you in 100 seconds. Before we start, I would like to say: Toronet is an EVM-compatible blockchain designed specifically for real-world financial inclusivity, natively supporting both cryptocurrencies and fiat currencies like USD or Naira.

That's smart talk for: it's a blockchain that actually lets you build apps with regular money, so your users don't need a PhD in crypto to buy something.

Essentially, it provides high-level SDKs that abstract away complex smart contracts, allowing developers to build decentralized wallet and e-commerce infrastructure with simple API calls.

Usually, building Web3 apps sucks. You have to learn Solidity, fight with MetaMask injections, pay outrageous gas fees, and beg your users to write down a 12-word seed phrase on a napkin they'll inevitably lose. 
But what if you could build a gorgeous, decentralized wallet entirely in Flutter—without writing a single line of backend code—AND connect it to a web store? That's what I attempted, and here's how it turned out.

**[0:25] THE SPEEDRUN: SETUP**
First, add the `toronet` SDK to your `pubspec.yaml`. 
In your `main.dart`, instantiate the `ToronetClient`. We point it at the `testnet` because we're broke developers and want to test with fake money.

*(Show Code Snippet)*
```dart
// The entire backend in one line.
final toronetClient = ToronetClient(
  sdk: ToronetSDK(network: Network.testnet),
);
```

**[0:35] FETCHING FIAT & CRYPTO**
Now we need to show the user's money. On Ethereum, you have to query every token individually. That’s slow. Toronet natively aggregates this. One API call returns your Fiat (like USD and Naira) alongside your Crypto.

*(Show Code Snippet)*
```dart
// Give me all the money.
final balances = await toronetClient.balance.getBalance(
  address: myAddress
);
// Returns: { "bal_toro": 150, "bal_dollar": 30000, "bal_naira": 1954000 }
```

**[0:45] TRANSACTIONS**
Time to move some value. Peer-to-peer settlement in milliseconds. We don't even have to handle raw private keys—we just pass the user's secure PIN, slap in the recipient's address, and fire the `transferCurrency` method. No complex smart contract calls needed.

*(Show Code Snippet)*
```dart
// Sending 50 bucks on the blockchain.
final txHash = await toronetClient.currency.transferCurrency(
  currency: 'ToroG',
  from: myAddress,
  to: '0xChad...',
  amount: '50.00',
  fromPassword: 'mySecurePin', 
);
```

You can even use the Toronet Name Service (TNS) to send it to a username like `xander_store` instead of a scary `0x` address.

**[0:55] CROSS-CHAIN BRIDGING**
Oh, your friend is stuck on Binance Smart Chain? Not an issue. Toronet has a native bridge built straight into the SDK. 

*(Show Code Snippet)*
```dart
// Bridging tokens from BSC into Toronet seamlessly.
final bridgeTx = await toronetClient.bsc.bridgeToken(
  from: myAddress,
  contractAddress: bscTokenAddress,
  amount: '1000',
  password: 'mySecurePin'
);
```

**[1:05] THE PLOT TWIST (DEEP LINKS)**
But wait... we didn't just build a consumer app. We built **Platform Infrastructure**. 
What if someone wants to build a web store, but they *hate* building wallets? 
We use deep linking to turn our Flutter app into the central wallet provider. We intercept a custom deep link—`torobank://sign-tx`—and instantly pop up a gorgeous transaction approval screen over any app on the phone.

*(Show Code Snippet)*
```dart
// Intercept the deep link like a ninja.
_deepLinkService.uriStream.listen((uri) {
  if (uri.scheme == 'torobank' && uri.host == 'sign-tx') {
    // Show the "Sign Transaction" Modal!
    showTransactionApprovalScreen(uri);
  }
});
```

**[1:20] THE WEB STORE CONNECTION**
On the website side, when a user clicks "Buy Now" on a pair of sneakers, the site generates that deep link payload. It specifies the amount, the recipient, and a callback URL. 

*(Show Code Snippet)*
```javascript
// Web Store triggering the Flutter App
const torobankUrl = `torobank://sign-tx?amount=50&currency=ToroG&recipient=${STORE_ADDRESS}&callback=${myStoreUrl}`;
window.location.href = torobankUrl;
```

**[1:30] CALLBACKS & CHECKOUT**
The user types in their PIN in the Flutter app, we sign the transaction, and then we kick them right back to the website with the transaction hash appended to the URL. The website verifies the `status=success` and shows a glorious checkout complete screen.

*(Show Code Snippet)*
```dart
// Yeet the user back to the Web Store
final callback = '${uri.queryParameters['callback']}?status=success&txHash=$txHash';
launchUrl(Uri.parse(callback));
```

You just built a decentralized wallet ecosystem, connected it to an e-commerce store, bypassed Apple Pay, and became a Web3 infrastructure provider. Grab the source code in the description. Hit like, subscribe, and I will see you in the next one.
