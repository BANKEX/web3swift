# Calling custom Smart Contract methods guide

## Test contract code
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
We deployed this contract at address:
`0x9eed12f85b8faedc97fc815f874d0f350220b3c7`

## Reading the Smart Contract methods
```
let readedValue = try! contractAddress.call("getValue()").wait().uint256()
```

To read method with some input:

```
let result = try contractAddress.call("yourMethod(uint256,address,string)", 123, Address("0x9eed12f85b8faedc97fc815f874d0f350220b3c7"), "your string")
```

if your result is type of uint256 you can read it like that

```
let value = try result.uint256()
```

if you have multiple values in your result like `(uint256, string)` you need to get them in the same order:

```
let value = try result.uint256()
let string = try result.string()
```

## Sending transactions

```
var options = Web3Options.default
options.from = yourAddress
let transaction = try! contractAddress.send("setValue(uint256)", 20, options: options).wait()
```

## Full code

```
Web3.default = try! .local(port: 8545)
let mnemonics = try! Mnemonics("figure champion above popular hint clump palace movie false common donate arrive")
let keystore = try! BIP32Keystore(mnemonics: mnemonics)
Web3.default.keystoreManager.append(keystore)
let address = keystore.addresses[0]

let contractAddress: Address = "0x9eed12f85b8faedc97fc815f874d0f350220b3c7"

let helloWorld = try! contractAddress.call("helloWorldMethod()").wait().string()
print(helloWorld)

let data = "some string".data
let hash = try! contractAddress.call("generateHash(bytes)", data).wait().uint256()
print("generated hash: 0x\(hash.solidityData.hex)")

var options = Web3Options.default
options.from = address
let transaction = try! contractAddress.send("setValue(uint256)", 20, options: options).wait()
print("transaction hash:", transaction.hash)

let readedValue = try! contractAddress.call("getValue()").wait().uint256()
print(readedValue)
// should return 20 if previous transaction was completed
```

Logs should look like:

```
helloWorld
generated hash: 0x83c737ad570e9f3e71e0d2800958e44770d812e92db2c1758626613d1e6ba514
transaction hash: 0x02c68664c813ded03666e5a9edd19db508e4259d9a153bf3b838b51936a10ab7
20
```