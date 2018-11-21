# Using web3swift with remix
## Setting the private node
Best private node for testing is ganache its easy to setup and gives you mnemonics for all accounts.

![](https://raw.githubusercontent.com/BANKEX/web3swift/gh-pages/Resources/Remix1.png)

## Connecting

Now [open remix](http://remix.ethereum.org) and change address from https to http:

![](https://raw.githubusercontent.com/BANKEX/web3swift/gh-pages/Resources/Remix2.png) 

Open `Run` tab and change Environment to `Web3 Provider`

![](https://raw.githubusercontent.com/BANKEX/web3swift/gh-pages/Resources/Remix3.png)

## Deploying contract


Here is our code that we use for testing:

```
pragma solidity ^0.4.25;

contract SomeContract {
    uint256 value;
    function helloWorldMethod () public pure returns (string) {
        return 'helloWorld';
    }
    function setValue (uint256 _value) public returns (bool) {
        value = _value;
        return true;
    }
    function getValue () public view returns (uint256) {
        return value;
    }
    function generateHash(bytes _value) public pure returns (bytes32) {
        return keccak256(_value);
    }
}
```

Now deploy contract and copy its address:

![](https://raw.githubusercontent.com/BANKEX/web3swift/gh-pages/Resources/Remix4.png)

And here is our swift code:

```
// Set your contract address and ganache mnemonics
let contractAddress: Address = "0x2f6e1f8f7d528d45d564123282d3fe107b466339"
let mnemonics = try! Mnemonics("figure champion above popular hint clump palace movie false common donate arrive")

// Connecting to your ganache node
Web3.default = try! .local(port: 8545)

// Creating account with your mnemonics
let keystore = try! BIP32Keystore(mnemonics: mnemonics)
Web3.default.keystoreManager.append(keystore)
let address = keystore.addresses[0]

// Calling helloWorldMethod()
let helloWorld = try! contractAddress.call("helloWorldMethod()").wait().string()
print(helloWorld)

// Generating hash
let data = "some string".data
let hash = try! contractAddress.call("generateHash(bytes)", data).wait().uint256()
print("generated hash: 0x\(hash.solidityData.hex)")

// Sending transaction (setValue)
var options = Web3Options.default
options.from = address
let transaction = try! contractAddress.send("setValue(uint256)", 20, options: options).wait()
print("transaction hash:", transaction.hash)

// Calling getValue
let readedValue = try! contractAddress.call("getValue()").wait().uint256()
print(readedValue)
// should return 20 if previous transaction was completed
```
And it prints:

```
helloWorld
generated hash: 0x83c737ad570e9f3e71e0d2800958e44770d812e92db2c1758626613d1e6ba514
transaction hash: 0x09c49d00e7f387a48ac48b0074b1f91721e81fb308038e6aa8b2a483140c7946
20
```