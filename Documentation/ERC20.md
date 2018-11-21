# ERC20 Guide

## Before we start

As token address we will use BKX Token:
`0x45245bc59219eeaaf6cd3f382e078a461ff9de7b`

And we have some token holder:
`0x6a6a0b4aaa60E97386F94c5414522159b45DEdE8 `

## Getting token name and symbol

```
let token = ERC20("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
let name = try token.name()
let symbol = try token.symbol()
```

## Getting someones balance
```
let address: Address = "0x6a6a0b4aaa60E97386F94c5414522159b45DEdE8"
let token = ERC20("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
let symbol = try token.symbol()
let balance = try token.balance(of: address)
let naturalBalance = try token.naturalBalance(of: address)

// balance in wei
print(balance, "wei")
// prints: 39824500000000000000000000 wei

// human readable balance
print(naturalBalance, symbol)
// prints: 39824500 BKX
```

## Sending some tokens
To send tokens you need to have some ether balance on your account.

```
let address: Address = "0x6a6a0b4aaa60E97386F94c5414522159b45DEdE8"
let token = ERC20("0x45245bc59219eeaaf6cd3f382e078a461ff9de7b")
let from: Address = Web3.default.keystoreManager.addresses[0]
let to: Address = "0x6a6a0b4aaa60E97386F94c5414522159b45DEdE8"

// Sending 0.05 BKX
let amount = NaturalUnits("0.05")

token.options.from = from
let transaction = try token.transfer(to: to, amount: amount)
print(transaction.hash)
```
> Note: this example will not work if you don't have enough token and ether balance

If you set amount as `BigUInt` it will send it as wei
> In BKX token: 1000000000000000000 wei == 1 BKX

## List of tokens
You can check them [here](https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json) or [here](https://github.com/ethereum-lists/tokens/tree/master/tokens/eth).

## Token icons
Token doesn't have images or urls but you can use some other services like [this repository](https://github.com/MyEtherWallet/ethereum-lists) to check for more token information. 
#### [Here is our token](https://github.com/MyEtherWallet/ethereum-lists/blob/8a687d403155103f7739d503e8919758e1d5f47c/src/tokens/eth/0x45245bc59219eeaaf6cd3f382e078a461ff9de7b.json) where you can get its icon url
