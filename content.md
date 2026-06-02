# Fireship-Style Script: Build a Web3 Bank in 100 Seconds

**Tone:** Extremely fast-paced, punchy, slightly sarcastic, highly technical but accessible.

---

*(Fast zooms, glitch effects, hyper-energetic pacing)*

**[0:00] THE HOOK**
Building Web3 apps usually sucks. You have to learn Solidity, fight with MetaMask injections, pay outrageous gas fees to test a smart contract, and beg your users to write down a 12-word seed phrase on a napkin they'll inevitably lose. 

But what if you could build a gorgeous, decentralized fiat-and-crypto bank entirely in Flutter—without writing a single line of backend code?

**[0:15] THE SOLUTION**
Meet **ToroBank**. It's an open-source, production-ready Flutter template powered by the **Toronet Blockchain**. Toronet is an EVM-compatible chain designed specifically for real-world financial inclusivity. 

Today, we're going to wire up a complete banking backend... in 100 seconds. Let's go.

*(Timer sound effect starts tick-tick-ticking)*

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

**[0:35] WALLET CREATION**
Next, we need a wallet. Usually, this requires a PhD in cryptography. With the Toronet SDK, it's a single await call. It generates a secure address and mnemonic right on the device.

*(Show Code Snippet)*
```dart
// Look mom, I'm a cryptographer.
final wallet = await toronetClient.wallets.createWallet();
print('My Address: ${wallet.address}'); 
```

**[0:45] FETCHING BALANCES**
Now we need to show the user's money. On Ethereum, you have to query every ERC-20 token contract individually. That’s slow and expensive. Toronet aggregates this natively. One API call returns your Fiat (like USD and Naira) alongside your Crypto.

*(Show Code Snippet)*
```dart
// Give me all the money.
final balances = await toronetClient.balance.getBalance(
  address: wallet.address
);
// Returns: { "bal_toro": 150, "bal_dollar": 14400, "bal_naira": 1954000 }
```

**[0:55] TRANSACTIONS**
Time to move some value. We take our active wallet's private key, slap in the recipient's address, and fire the `transferToken` method. Boom. Peer-to-peer settlement in milliseconds.

*(Show Code Snippet)*
```dart
// Sending 50 bucks on the blockchain.
final txHash = await toronetClient.transfer.transferToken(
  senderPrivateKey: mySecureKey,
  toAddress: '0xChad...',
  amount: '50.00',
  currency: Currency.dollar,
);
```

**[1:05] THE PLOT TWIST (WALLET CONNECT)**
But wait... we didn't just build a consumer app. We built **Platform Infrastructure**. 

What if another developer wants to build a Toronet NFT Marketplace, but they *hate* building wallets? 

We use the `app_links` package to turn ToroBank into the central wallet provider for the entire OS. We intercept a custom deep link—`torobank://sign-tx`—and instantly pop up a gorgeous transaction approval screen over any app on the phone.

*(Show Code Snippet)*
```dart
// Intercept the deep link like a ninja.
_appLinks.uriLinkStream.listen((uri) {
  if (uri.scheme == 'torobank' && uri.host == 'sign-tx') {
    // Show the "Sign Transaction" Modal!
    showTransactionApprovalScreen(uri);
  }
});
```

**[1:20] CALLBACKS**
The user types in their PIN, we sign the transaction using the Toronet SDK, and then we use `url_launcher` to kick them right back to the marketplace with the transaction hash.

*(Show Code Snippet)*
```dart
// Yeet the user back to the dApp
final callback = '${uri.queryParameters['callback']}?status=success&txHash=$txHash';
launchUrl(Uri.parse(callback));
```

**[1:30] OUTRO**
You just built a decentralized banking ecosystem, bypassed Apple Pay, and became a Web3 infrastructure provider. 

Grab the ToroBank source code in the description. Hit like, subscribe, and I will see you in the next one.

*(Fireship outro music plays)*
