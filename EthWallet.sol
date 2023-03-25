// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract EthWallet{
    address payable public owner;
    constructor(){
        owner = payable(msg.sender);
    }

    function withdraw(uint _amt) external{
        require(msg.sender==owner,"not owner");
        payable(msg.sender).transfer(_amt);
    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }
}
//compiled in remix