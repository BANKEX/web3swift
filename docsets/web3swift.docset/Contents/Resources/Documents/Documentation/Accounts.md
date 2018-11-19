# How to create or import an account

If you need to get your account from metamask, ganache, EtherWallet or some other wallet, you need to know its mnemonics or private key. Or you can create account in web3swift and export it.

## Create account

```
let mnemonics = Mnemonics()
let keystore = try! BIP32Keystore(mnemonics: mnemonics)
print(mnemonics.string)
Web3.default.keystoreManager = KeystoreManager([keystore])
```
> Note: Save your mnemonics if you want to use this mnemonics later. You cannot get them later from the keystore

## Import account

```
let mnemonicsString = "nation tornado double since increase orchard tonight left drip talk sand mad"
let mnemonics = try Mnemonics(mnemonicsString)
let keystore = try! BIP32Keystore(mnemonics: mnemonics)
Web3.default.keystoreManager = KeystoreManager([keystore])
```

## Export account

> Note: You cannot get your mnemonics from your private key or keystore

```
let privateKey: Data = try keystore.UNSAFE_getPrivateKeyData(password: "", account: keystore.addresses[0])
```

## Use your account in web3swift
Setup your Web3.default manager

Then import your keystoreManger

```
Web3.default.keystoreManager = KeystoreManager([keystore])
```

Now you can send transactions using your account:

```
let recepient: Address // recepient address
var options = Web3Options.default
options.from = Web3.default.keystoreManager!.addresses[0]
let transaction = try Web3.default.eth.sendETH(to: recepient, amount: BigUInt("0.01", units: .eth)!).send(options: options)
```