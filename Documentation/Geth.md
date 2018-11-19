# How to use web3swift with private geth node


> Note: We are recommending you to use web3swift generated accounts or imported from mnemonics or private key. 

> Also we recommending to use Ganache instead of geth cause its much easier

[Generate or import your account](Accounts.md)

```
let mnemonics = Mnemonics()
print(mnemonics.string, BIP32Keystore(mnemonics: mnemonics).addresses[0])
```

#### Save that mnemonics and address

```swift
let mnemonicsString = "nation tornado double since increase orchard tonight left drip talk sand mad"
let address: Address = "0xDf2bC70175311A6807F085e54881Fc4931359dBF"
```

### Starting geth and sending some ether to your account

Start your geth

```
geth --rpc --rpccorsdomain '*' --rpcapi 'eth,web3,personal,net,miner,admin,debug,txpool' --nodiscover --dev --rpcport 8545 --rpcaddr 0.0.0.0
```

Now send some ether to your web3swift account.

To do this run this code in your get console:

```
eth.sendTransaction({from:eth.coinbase, to: "0xDf2bC70175311A6807F085e54881Fc4931359dBF", value: web3.toWei(100, "ether")})
```
> Dont forget to change recepient address

### Almost done
now we have some ether in our account. So just lets use it:

```
let mnemonicsString = "nation tornado double since increase orchard tonight left drip talk sand mad"
let address: Address = "0xDf2bC70175311A6807F085e54881Fc4931359dBF"

Web3.default = try .local(port: 8545) 
Web3.default.keystoreManager = try KeystoreManager([BIP32Keystore(mnemonics: mnemonics)])

let balance = try Web3.default.eth.getBalance(address: address)

print("you have \(balance.string(units: .eth)) ether")
// should print "you have 100 ether"
```

# Now you ready to send some real transactions!