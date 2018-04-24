//
//  ViewController.swift
//  MyWeb3
//
//  Created by Kevin on 2018/4/4.
//  Copyright © 2018年 Kevin. All rights reserved.
//

import UIKit
import web3swift
import BigInt
import Result
import secp256k1_ios
import CryptoSwift



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let sBtn = UIButton()
        sBtn.frame = CGRect.init(x:20,y:50,width:self.view.frame.size.width - 40,height:45)
        sBtn.backgroundColor = UIColor.blue
        sBtn.setTitle("存数据(saveData)", for:.normal)
        sBtn.addTarget(self, action:#selector(sBtnTap), for:.touchUpInside)
        self.view.addSubview(sBtn)
        
        let gBtn = UIButton()
        gBtn.frame = CGRect.init(x:20,y:110,width:self.view.frame.size.width - 40,height:45)
        gBtn.backgroundColor = UIColor.blue
        gBtn.setTitle("拿数据(getData)", for:.normal)
        gBtn.addTarget(self, action:#selector(gBtnTap), for:.touchUpInside)
        self.view.addSubview(gBtn)
        
        let tBtn = UIButton()
        tBtn.frame = CGRect.init(x:20,y:170,width:self.view.frame.size.width - 40,height:45)
        tBtn.backgroundColor = UIColor.blue
        tBtn.setTitle("转账(transfer)", for:.normal)
        tBtn.addTarget(self, action:#selector(tBtnTap), for:.touchUpInside)
        self.view.addSubview(tBtn)
        
        let bBtn = UIButton()
        bBtn.frame = CGRect.init(x:20,y:230,width:self.view.frame.size.width - 40,height:45)
        bBtn.backgroundColor = UIColor.blue
        bBtn.setTitle("区块(block)", for:.normal)
        bBtn.addTarget(self, action:#selector(bBtnTap), for:.touchUpInside)
        self.view.addSubview(bBtn)
        
        
        let dBtn = UIButton()
        dBtn.frame = CGRect.init(x:20,y:290,width:self.view.frame.size.width - 40,height:45)
        dBtn.backgroundColor = UIColor.blue
        dBtn.setTitle("发布(deploy)", for:.normal)
        dBtn.addTarget(self, action:#selector(dBtnTap), for:.touchUpInside)
        self.view.addSubview(dBtn)
        
        
        let qBtn = UIButton()
        qBtn.frame = CGRect.init(x:20,y:350,width:self.view.frame.size.width - 40,height:45)
        qBtn.backgroundColor = UIColor.blue
        qBtn.setTitle("签名(signature)", for:.normal)
        qBtn.addTarget(self, action:#selector(qBtnTap), for:.touchUpInside)
        self.view.addSubview(qBtn)
        
        
        let eBtn = UIButton()
        eBtn.frame = CGRect.init(x:20,y:410,width:self.view.frame.size.width - 40,height:45)
        eBtn.backgroundColor = UIColor.blue
        eBtn.setTitle("事件(event)", for:.normal)
        eBtn.addTarget(self, action:#selector(eBtnTap), for:.touchUpInside)
        self.view.addSubview(eBtn)
        
    

    }


  
    
    //存储数据 --- save Data
    @objc func sBtnTap()  {
        
       
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        let account = keystoreManager.addresses![0]
        print(account)
     
        
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        
        //合约地址
        let contractAddress = EthereumAddress("0x222913DD7D26a4798AA43a31e17586ffF0129091")
        
        let url = URL.init(string: "http://127.0.0.1:8545")
        let web3 = Web3.new(url!)
        web3?.provider.network = nil
        
        let contract = web3?.contract(abiString, at: contractAddress, abiVersion: 2)
        
        web3?.addKeystoreManager(keystoreManager)
        
        var options = Web3Options.defaultOptions()
        options.from = keystoreManager.addresses?.first
        
        let parameters = ["helloWeb10"] as [AnyObject]
        let intermediate = contract?.method("setFlagData",parameters: parameters, options: options)
        let result = intermediate!.send(options: options)
        
        print("set result")
        print(result)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
        }
        
        
        print("\n")
        
        
    }
    
    //拿数据  -- getData
    @objc func gBtnTap()  {
        
        
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        let account = keystoreManager.addresses![0]
        print(account)
        
    
        let abiString = "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        
       
        let contractAddress = EthereumAddress("0x222913DD7D26a4798AA43a31e17586ffF0129091")

        let url = URL.init(string: "http://127.0.0.1:8545")
        
        let web3 = Web3.new(url!)
        
        let contract = web3?.contract(abiString, at: contractAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = account
        
        let intermediate = contract?.method("getFlagData", options: options)

        let result = intermediate!.call(options: nil)
        print("get result")
        print(result)
        switch result {
        case .success(let payload):
            print(payload)
        case .failure(let error):
            print(error)
    
        }
        
        print("\n")

        
    }

    //转账 --- transfer
    @objc func tBtnTap()  {
        

        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        let account = keystoreManager.addresses![0]
        print(account)

        let url = URL.init(string: "http://127.0.0.1:8545")
        let web3 = Web3.new(url!)
        web3?.provider.network = nil
        web3?.addKeystoreManager(keystoreManager)
        
        let sendToAddress = EthereumAddress("0x7A5038D84Aafb05FE4a6cF8A3E13D0efCFDd9D96")
        let contract = web3?.contract(Web3.Utils.coldWalletABI, at: sendToAddress, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.value = Web3.Utils.parseToBigUInt("3.62", units: .eth)
       
        options.from = account
        let intermediate = contract?.method("fallback", options: options)
        guard let result = intermediate?.send(password: "") else {return print("result error")}
        switch result {
        case .success(let res):
            print(res)
            return
        case .failure(let error):
            print(error)
            
        }
        
        
    }
    
    
    
    //区块  ---block information
    @objc func bBtnTap()  {
        
        //执行人地址
       
        let coldWalletAddress = EthereumAddress("0x9d7c297261cdfa90e1f04fd4df58bf7961299bf8")
        
        let url = URL.init(string: "http://127.0.0.1:8545")
        let web3Main = Web3.new(url!)
        
        let blockNumber = web3Main?.eth.getBlockNumber()
        print("Block number:")
        print(blockNumber)
        
        
        let gasPrice = web3Main?.eth.getGasPrice()
        print("Gas price:")
        print(gasPrice)
        
        let balance =  web3Main?.eth.getBalance(address: coldWalletAddress)
        print("Block balance:")
        print(balance)
        
        
    }


    
    
    //发布 ---- deploy
      @objc func dBtnTap()  {
        
        
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        let account = keystoreManager.addresses![0]
        print(account)
        
        let web3 = Web3.new(URL.init(string: "http://127.0.0.1:8545")!)!
        web3.provider.network = nil
        web3.addKeystoreManager(keystoreManager)
        
        let abiString =  "[{\"constant\":true,\"inputs\":[],\"name\":\"getFlagData\",\"outputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"data\",\"type\":\"string\"}],\"name\":\"setFlagData\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]"
        
        guard let bytecode = Data.fromHex("6060604052341561000f57600080fd5b6103358061001e6000396000f30060606040526004361061004c576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063a16e94bf14610051578063a46b5b6b146100df575b600080fd5b341561005c57600080fd5b61006461013c565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100a4578082015181840152602081019050610089565b50505050905090810190601f1680156100d15780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b34156100ea57600080fd5b61013a600480803590602001908201803590602001908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509190505061020d565b005b610144610250565b6000808073ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000018054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156102035780601f106101d857610100808354040283529160200191610203565b820191906000526020600020905b8154815290600101906020018083116101e657829003601f168201915b5050505050905090565b806000808073ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600001908051906020019061024c929190610264565b5050565b602060405190810160405280600081525090565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106102a557805160ff19168380011785556102d3565b828001600101855582156102d3579182015b828111156102d25782518255916020019190600101906102b7565b5b5090506102e091906102e4565b5090565b61030691905b808211156103025760008160009055506001016102ea565b5090565b905600a165627a7a7230582017359d063cd7fdf56f19ca186a54863ce855c8f070acece905d8538fbbc4d1bf0029") else {return print("bytecode error")}
        
        let contract = web3.contract(abiString, at: nil, abiVersion: 2)
        var options = Web3Options.defaultOptions()
        options.from = account
        options.gasLimit = BigUInt(3000000)
        let intermediate = contract?.deploy(bytecode: bytecode, options: options)
    
        guard let result = intermediate?.send(password: "",options:options) else {return print("reslut error")}
    
        print("deploy result:")
        print(result)
        switch result {
        case .success(let res):
            let txHash = res["txhash"]!
            print("Transaction with hash " + txHash)
            Thread.sleep(forTimeInterval: 1.0)
            let receipt = web3.eth.getTransactionReceipt(txHash)
            print("receipt:")
            print(receipt)
            let details = web3.eth.getTransactionDetails(txHash)
            print("details:")
            print(details)
            return
        case .failure(let error):
            print(error)
           
        }
        
    }
    
    
    
    //签名 ---- signature
    @objc func qBtnTap()  {
      
        
     let abiString = "[{\"constant\":true,\"inputs\":[{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"},{\"name\":\"number\",\"type\":\"uint256\"}],\"name\":\"validate\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[],\"name\":\"kill\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":false,\"inputs\":[{\"name\":\"v\",\"type\":\"uint8\"},{\"name\":\"r\",\"type\":\"bytes32\"},{\"name\":\"s\",\"type\":\"bytes32\"},{\"name\":\"_stepsNumber\",\"type\":\"uint256\"}],\"name\":\"exchange\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"name\":\"_rate\",\"type\":\"uint256\"},{\"name\":\"_quota\",\"type\":\"uint256\"}],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"constructor\"}]"
        
        
        let contractAddress = EthereumAddress("0xa0d676f43d12555aad6b5660e7025f71216bc92c")
        let url = URL.init(string: "http://127.0.0.1:8545")
        //let url = URL.init(string: "http://192.168.82.77:8545")
        let web3 = Web3.new(url!)
  
        let testString = "1000"
        let personalMessage  = testString.data(using: String.Encoding.utf8)
        print(personalMessage)
        
        
        let tempKeystore = try! EthereumKeystoreV3(password: "")
        let keystoreManager = KeystoreManager([tempKeystore!])
        web3?.addKeystoreManager(keystoreManager)
        let account = keystoreManager.addresses![0]
        print(account)
        
        do {
        
            
            let signature = try Web3Signer.signPersonalMessage(personalMessage!, keystore: keystoreManager, account: account, password: "",useExtraEntropy: false)
           
            print(signature)
            
            if signature?.count != 65 { print("sign count error")}

            let rData = Data(signature![0..<32])
            let sData = Data(signature![32..<64])
            let vData = BigUInt(signature![64]) + BigUInt(27)
            print(rData)
            print(sData)
            print(vData)
            print(signature?.toHexString())
            
            
            //合约验签
            let contract = web3?.contract(abiString, at: contractAddress, abiVersion: 2)
            var options = Web3Options.defaultOptions()
            options.from = account
            
            let parameters = [vData,rData,sData,BigUInt(1000)] as [AnyObject]

            print("parameters:")
            print(parameters)
            let intermediate = contract?.method("validate",parameters: parameters, options: options)
            let result = intermediate!.call(options: options)

            print("v result")
            print(result)
            switch result {
            case .success(let payload):
                print(payload)
            case .failure(let error):
                print(error)

            }
            
    
            //验签
            let verifySender: EthereumAddress = Web3.Utils.personalECRecover(personalMessage!, signature: signature!)!
            print("verify sender:")
            print(verifySender)
           
            
            print("\n")
            
            
        }
        catch{
            print(error)
            
        }
 
    
        
    }
    
    
    //event -- event
    @objc func eBtnTap()  {
        
        
        let contractAddress = EthereumAddress("0x7376CF24b765234D5fE207EbB493cFC6e1142931")
        let jsonString = "[{\"constant\":false,\"inputs\":[{\"name\":\"_id\",\"type\":\"string\"}],\"name\":\"deposit\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"name\":\"_from\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"_id\",\"type\":\"string\"},{\"indexed\":true,\"name\":\"_value\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"}]"
        
        let web3 = Web3.new(URL.init(string: "http://127.0.0.1:8545")!)!
        let contract = web3.contract(jsonString, at: contractAddress, abiVersion: 2)
        guard let eventParser = contract?.createEventParser("Deposit", filter: nil) else {
            print("error")
            return }
        
        let present = eventParser.parseBlockByNumber(UInt64(6226))
        guard case .success(let pres) = present else {
            print("not success")
            return
        }
        print("pres:")
        print(pres)
        
        
        for p in pres {
            
            print("From " + (p.decodedResult["_from"] as! EthereumAddress).address + "\n")
            print("id:")
            print(p.decodedResult["_id"] as Any)
          
            print("Value " + String(p.decodedResult["_value"]as! BigUInt) + "\n")
        }
        print("\n")
        
    
    }
    
    
    
  
}

