# Security tips

## Keeping sensitive information

You can store passwords, mnemonics and private keys in your keychain

To securely store data on your drive use:

```
try data.write(to: url, options: .completeFileProtection)
```
> Note: Data Protection should be enabled in your project

![](/Users/dimas/Desktop/web3swift/Documentation/Resources/Security1.png)

#### This is not a good idea to send mnemonics or private keys to your server.

## Jailbroken device
For jailbroken devices there is no place to hide. Virus can read data from your keystore, sandbox directory, core data and app memory. And they also can call and edit your functions. But hacker needs a lot of time to do that.

You don't really need to care about jailbroken devices.