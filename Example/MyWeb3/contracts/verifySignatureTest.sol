pragma solidity ^0.4.17;

contract BBQ {

//验签数据入口函数
function validate(uint8 v,bytes32 r,bytes32 s,uint number) view returns (address,bool){

    string memory message = uint2str(number);
    string memory lengths = uint2str(bytes(message).length);
    string memory prefix = strConcat("\u0019Ethereum Signed Message:\n",lengths);
    bytes32 data = sha3(bytes(prefix),bytes(uint2str(number)));
    address endecodedAddress = ecrecover(data, v, r, s);

    return (endecodedAddress,msg.sender == endecodedAddress);
}

function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    
    while (j != 0){
        length++;
        j /= 10;
    }
    
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}

// 连接两个string
function strConcat(string _a, string _b) internal returns (string){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);

    string memory abcde = new string(_ba.length + _bb.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

    return string(babcde);
}
}

