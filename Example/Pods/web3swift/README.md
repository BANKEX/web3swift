# We just released web3swift 2.0 [check it out](https://github.com/BANKEX/web3swift/releases/tag/2.0.0)
### also check our [Discord Channel](https://discord.gg/3ETv2ST)
<p align="right">
<a href="https://brianmacdonald.github.io/Ethonate/address#0x47FC2e245b983A92EB3359F06E31F34B107B6EF6" target="_blank">
<img src="https://brianmacdonald.github.io/Ethonate/svg/eth-support-blue.svg" alt="Support">
</a>
<a href="https://stackoverflow.com/questions/tagged/web3swift" target="_blank">
<img src="https://img.shields.io/badge/stackoverflow-ask-blue.svg" alt="Stackoverflow">
</a>
<a href="https://discord.gg/3ETv2ST" target="_blank">
<img src="https://img.shields.io/badge/discord-join%20chat-blue.svg" alt="Join Discord">
</a>
</p>

![bkx-foundation-github-swift](https://user-images.githubusercontent.com/3356474/34412791-5b58962c-ebf0-11e7-8460-5592b12e6e9d.png)

<p align="center">
<a href="https://developer.apple.com/swift/" target="_blank">
<img src="https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat" alt="Swift 4.2">
</a>
<a href="https://developer.apple.com/swift/" target="_blank">
<img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms iOS | macOS">
</a>
<a target="_blank">
<img src="https://img.shields.io/badge/Supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM%20-orange.svg?style=flat" alt="Compatible">
</a>
<a target="_blank">
<img src="https://img.shields.io/badge/Supports-Objective%20C-blue.svg?style=flat" alt="Compatible">
</a>
</p>


# web3swift
- Swift implementation of [web3.js](https://github.com/ethereum/web3.js/) functionality :zap:
- Interaction with remote node via JSON RPC :thought_balloon:
- Smart-contract ABI parsing :book:
- ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- RLP encoding
- Interactions (read/write to Smart contracts) :arrows_counterclockwise:
- Local keystore management (geth compatible)
- Literally following the standards:
-  [BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) HD Wallets: Deterministic Wallet
-  [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) (Seed phrases)
-  [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) (Key generation prefixes)
-  [EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) (Replay attacks protection) *_enforced!_*


## Requirements
Web3swift requires Swift 4.2 and deploys to `macOS 10.10`, `iOS 9`, `watchOS 2` and `tvOS 9` and `linux`.

Don't forget to set the iOS version in a Podfile, otherwise you get an error if the deployment target is less than the latest SDK.

## Installation

- **Swift Package Manager:**
  Although the Package Manager is still in its infancy, web3swift provides full support for it.
  Add this to the dependency section of your `Package.swift` manifest:

    ```Swift
    .package(url: "https://github.com/BANKEX/web3swift.git", from: "2.0.0")
    ```

- **CocoaPods:** Put this in your `Podfile`:

    ```Ruby
    pod 'web3swift', :git => 'https://github.com/bankex/web3swift.git'
    ```

- **Carthage:** Put this in your `Cartfile`:

    ```
    github "BANKEX/web3swift" ~> 2.0
    ```


## Documentation

> Hi. We spend a lot of time working on documentation. If you have some questions after reading it just [open an issue](https://github.com/bankex/web3swift/issues) or ask in our [discord channel](https://discord.gg/3ETv2ST). We would be happy to answer you.

Most of the classes are documented and have some examples on how to use it. 

### [Read documentation in using Xcode](https://bankex.github.io/web3swift/read-documentation-using-xcode.html)
### [Github Pages](https://bankex.github.io/web3swift)

#### We would appreciate it if you translate our documentation into another language, and will be happy to provide you with all the necessary information on how to do this. We will compensate you for translations that will be included in the master branch.

## Check this out
- Private key and transaction were created directly on an iOS device and sent directly to [Infura](https://infura.io) node
- Native API
- Security (as cool as a hard wallet! Right out-of-the-box! :box: )
- No unnecessary dependencies
- Possibility to work with all existing smart contracts
- Referencing the newest features introduced in Solidity

## Design decisions
- Not every JSON RPC function is exposed yet, priority is given to the ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on the device to send raw transactions to Ethereum network
- Requirements for password input on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for private key export is exposed for user convenience, but marked as UNSAFE_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

### Here it is
[https://rinkeby.etherscan.io/tx/0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056](https://rinkeby.etherscan.io/tx/0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056)

```
Transaction
Nonce: 35
Gas price: 5000000000
Gas limit: 21000
To: 0x6394b37Cf80A7358b38068f0CA4760ad49983a1B
Value: 1000000000000000
Data: 0x
v: 43
r: 73059897783840535708732471549376620878882680550447969052675399628060606060727
s: 12280625377431973240236065453692843538037349746280474092545114784968542260859
Intrinsic chainID: Optional(4)
Infered chainID: Optional(4)
sender: Optional(web3swift.Address(_address: "0x855adf524273c14b7260a188af0ae30e82e91959"))


["id": 1514485925, "result": 0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056, "jsonrpc": 2.0]
On Rinkeby TXid = 0xc6eca60ecac004a1501a4323a10edb7fa4cd1a0896675f6b51704c84dedad056
```

## Example
You can try it yourself by running the example project:

- Clone the repo
-  `cd Example/web3swiftExample`
- run `pod install` from the `Example/web3swiftExample` directory.
-  `open ./web3swiftExample.xcworkspace`

## Communication
- if you ****need help****, use [Stack Overflow](https://stackoverflow.com/questions/tagged/web3swift) (tag 'web3swift')
- If you'd like to ****ask a general question****, use [Stack Overflow](https://stackoverflow.com/questions/tagged/web3swift).
- If you ****found a bug****, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you ****have a feature request****, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you ****want to contribute****, [submit a pull request](https://github.com/BANKEX/web3swift/pulls).

## Features
- [x] Create Account
- [x] Import Account
- [x] Sign transactions
- [x] Send transactions, call functions of smart-contracts, estimate gas costs
- [x] Serialize and deserialize transactions and results to native Swift types
- [x] Convenience functions for chain state: block number, gas price
- [x] Check transaction results and get receipt
- [x] Parse event logs for transaction
- [x] Manage user's private keys through encrypted keystore abstractions
- [x] Batched requests in concurrent mode, checks balances of 580 tokens (from the latest MyEtherWallet repo) over 3 seconds

## Global plans
- Full reference `web3js` functionality
- Light Ethereum subprotocol (LES) integration

## [Apps using this library](https://github.com/BANKEX/web3swift/wiki/Apps-using-web3swift)
If you've used this project in a live app, please let us know!
>_If you are using_ `web3swift` _in your app or know of an app that uses it, please add it to_ [_this_](https://github.com/BANKEX/web3swift/wiki/Apps-using-web3swift) _list._*

## Special thanks to

- Gnosis team and their library [Bivrost-swift](https://github.com/gnosis/bivrost-swift) for inspiration for the ABI decoding approach
- [Trust iOS Wallet](https://github.com/TrustWallet/trust-wallet-ios) for the collaboration and discussion of the initial idea
- Official Ethereum and Solidity docs, everything was written from ground truth standards


## Contribution
For the latest version, please check [develop](https://github.com/BANKEX/web3swift/tree/develop) branch.

Changes made to this branch will be merged into the [master](https://github.com/BANKEX/web3swift/tree/master) branch at some point.

- If you want to contribute, submit a [pull request](https://github.com/BANKEX/web3swift/pulls) against a development `develop` branch.
- If you found a bug, [open an issue](https://github.com/BANKEX/web3swift/issues).
- If you have a feature request, [open an issue](https://github.com/BANKEX/web3swift/issues).

## Appreciation
When using this pod, references to this repo, [BANKEX](https://bankex.com) and [BANKEX Foundation](https://new.bankexfoundation.org/) are appreciated.

## License
web3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/BankEx/web3swift/blob/master/LICENSE.md) file for more info.
