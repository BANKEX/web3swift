pragma solidity ^0.4.0;

contract ClientReceipt {
    
    event Deposit(
        address indexed _from,
        string _id,
        uint indexed _value
    );

    function deposit(string _id) public  payable {

        emit Deposit(msg.sender, _id, msg.value);
    }
    
}