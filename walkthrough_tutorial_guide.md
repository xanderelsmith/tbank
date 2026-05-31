# Building a Web3 Banking App: Toronet SDK Integration Guide

This document is designed as a script and reference guide for a tutorial. It assumes you are starting with a visually complete **UI-only starter template** (no business logic) and need to wire up the core banking features using the Toronet SDK. 

By the end of this tutorial, the static UI will be transformed into a fully functional Web3 banking application.

---

## 1. Initializing the SDK

**UI Context:** The app boots up and needs to initialize the core client before rendering the first screen.

**SDK Implementation:**
You must instantiate the `ToronetClient` and configure it to point to the desired environment (Testnet or Mainnet) by supplying a custom RPC URL if necessary.

```dart
import 'package:toronet/toronet.dart';

// Initialize the client. By default, it targets the mainnet.
final toronetClient = ToronetClient();

// To override for a testnet environment:
// (You will pass this client instance into your controllers/repositories)
```

---

## 2. Onboarding (Wallet Creation & Import)

**UI Context:** The user is on the welcome screen and can either click **"Create New Wallet"** or **"Import Existing Wallet"** (via a mnemonic seed phrase).

**SDK Implementation:**
Toronet abstracts away the complexity of cryptography. Creating or importing a wallet returns a `Wallet` object containing the user's `address`, `privateKey`, and `mnemonic`.

```dart
// 1. Create a brand new wallet
final newWallet = await toronetClient.wallets.createWallet();
String myAddress = newWallet.address;
String mySeedPhrase = newWallet.mnemonic; // Important to save locally!

// 2. Import an existing wallet using a 12-word seed phrase
final importedWallet = await toronetClient.wallets.importWallet(
  mnemonic: "apple banana cherry dog elephant frog grape hat ice juice kite lemon"
);
```
> [!TIP]
> Always store the `mnemonic` securely on the device (e.g., using Flutter Secure Storage). The Toronet SDK does not manage local state for you.

---

## 3. Dashboard (Asset Balances)

**UI Context:** The user lands on the main dashboard. A grid or list needs to display their portfolio balances across various assets (ToroG, USD, NGN, ETH).

**SDK Implementation:**
Instead of polling each currency individually, Toronet's `getBalance` endpoint returns a single payload containing all asset balances for a given address.

```dart
final address = "0xYourWalletAddress...";

// Fetch all balances simultaneously
final balancesJson = await toronetClient.balance.getBalance(address: address);

// The response looks like:
// { "bal_toro": 150, "bal_dollar": 14400, "bal_naira": 1954000, "bal_eth": 0 ... }
```
You can then extract the `bal_*` keys and map them to your UI's balance cards.

---

## 4. Peer-to-Peer Transfers

**UI Context:** The user navigates to the "Transfer" screen, inputs a recipient address (`0x...`), an amount, selects a currency from a dropdown, and clicks **"Send"**.

**SDK Implementation:**
Use the `transfer` module to move tokens across the ledger.

```dart
final receipt = await toronetClient.transfer.transferToken(
  senderPrivateKey: myPrivateKey, // Sourced from local secure storage
  recipientAddress: "0xRecipientAddress...",
  amount: "50.00",
  currency: Currency.dollar, // using the Toronet Currency Enum
);

// Returns a receipt containing the 'transactionHash'
```

---

## 5. Funding the Wallet (Deposits)

**UI Context:** The user goes to the "Deposit" screen, inputs an amount of USD/NGN, and clicks **"Initiate Deposit"**. The app shows a Reference ID, and they click **"Confirm Settle Deposit"** after paying via a web gateway.

**SDK Implementation (Mainnet):**
On live networks, funding involves bridging real-world fiat.

```dart
// Step 1: Initiate the fiat intent
final depositResult = await toronetClient.payments.depositFunds(
  userAddress: myAddress,
  username: "user123",
  amount: "100",
  currency: Currency.dollar,
  admin: "0xAdminAddress...",
  adminpwd: "admin_password",
);

// Extract the payment ID from the result
final paymentId = depositResult['txid']; 

// Step 2: Confirm the deposit (after the user pays via gateway)
final confirmResult = await toronetClient.payments.confirmDeposit(
  currency: "USD",
  txid: paymentId,
  paymentType: "bank",
  admin: "0xAdminAddress...",
  adminpwd: "admin_password",
);
```

> [!NOTE]
> **Testnet Simulators:** For testing environments without real money, you can bypass the fiat gateway by making direct HTTP POST requests to the testnet nodes to instantly mint tokens (`/api/token/<token>/ad`) or import currency (`/api/currency/<fiat>/ad`).

---

## 6. Withdrawing to a Bank Account

**UI Context:** The user selects "Withdraw", chooses a destination bank from a dropdown, enters their account number, clicks "Verify Name", and finally clicks "Withdraw".

**SDK Implementation:**
Toronet provides endpoints to fetch available banks, verify KYC data, and execute the withdrawal.

```dart
// Step 1: Fetch Supported Banks
final banks = await toronetClient.payments.getBankListNGN();

// Step 2: Verify the Account Number (Resolves the account holder's name)
final accountName = await toronetClient.payments.verifyBankAccountNameNGN(
  destinationInstitutionCode: "058", // e.g., GTBank code
  accountNumber: "0123456789",
  admin: "0xAdmin...",
  adminpwd: "pwd",
);

// Step 3: Execute Withdrawal
final withdrawResult = await toronetClient.payments.withdrawFunds(
  senderPrivateKey: myPrivateKey,
  amount: "5000",
  currency: "NGN",
  destinationInstitutionCode: "058",
  accountNumber: "0123456789",
  accountName: accountName,
  admin: "0xAdmin...",
  adminpwd: "pwd",
);
```

---

## 7. Virtual Cards & Bridging (Advanced Features)

**UI Context:** The user clicks "Create Virtual Card" or "Bridge to Polygon" on the dashboard.

**SDK Implementation:**

**Virtual Cards:**
```dart
final virtualCardInfo = await toronetClient.payments.createVirtualAccount(
  address: myAddress,
  admin: "0xAdmin...",
  adminpwd: "pwd",
);
// Returns card details (PAN, CVV, Expiry) bound to the Toronet wallet.
```

**Cross-Chain Bridging:**
```dart
final bridgeTx = await toronetClient.bridge.bridgeToken(
  senderPrivateKey: myPrivateKey,
  tokenSymbol: "USDC",
  amount: "100",
  destinationChain: "Polygon",
  destinationAddress: "0xUserPolygonAddress...",
);
```

> [!WARNING]
> Virtual Cards and Cross-Chain Bridging may be restricted to Mainnet environments depending on the infrastructure provider. Ensure you catch and handle 404/400 errors gracefully if invoked on Testnet.

---

## 8. Transaction History

**UI Context:** The user views the "Recent Transactions" list on their dashboard, or clicks into the dedicated "History" screen to see a chronological log of all incoming and outgoing funds.

**SDK Implementation:**
Fetch the ledger history for a specific wallet address. The SDK provides structured JSON detailing the transaction hash, amount, block time, and whether it was a deposit or withdrawal.

```dart
// Fetch history
final historyData = await toronetClient.history.getTransactionHistory(
  address: "0xYourWalletAddress...",
);

// Iterate through the history
for (var tx in historyData) {
  print('Tx Hash: ${tx.txHash}');
  print('Amount: ${tx.amount} ${tx.currency}');
  print('Type: ${tx.type}'); // e.g., 'send', 'receive', 'deposit'
  print('Date: ${tx.timestamp}');
}
```
