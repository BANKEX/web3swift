pragma solidity ^0.4.21;


contract Whisper {
    
    struct Friend {
        string flagData;
    }
    
    mapping (address => Friend) friends;
    
    function setFlagData(string data) public {
        friends[0].flagData = data;
    }
    
    function getFlagData() public view returns (string data) {
        return friends[0].flagData;
    }
    
}