// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/VulnerableBank.sol";
import "../src/SecureBank.sol";
import "../src/ReentrancyAttacker.sol";

contract ReentrancyTest is Test {
    VulnerableBank vulnerableBank;
    SecureBank secureBank;

    ReentrancyAttacker attacker;

    function setUp() public {
        vulnerableBank = new VulnerableBank();
        secureBank = new SecureBank();

        attacker = new ReentrancyAttacker(address(vulnerableBank));

        vm.deal(address(this), 20 ether);
        vm.deal(address(attacker), 0);
    }

    function testReentrancyExploit() public {
        // Victim deposits 10 ETH
        vulnerableBank.deposit{value: 10 ether}();

        // Attacker deposits 1 ETH and triggers withdrawal
        attacker.attack{value: 1 ether}();

        // Attacker should drain the bank
        assertEq(address(vulnerableBank).balance, 0);

        assertEq(address(attacker).balance, 11 ether);
    }

    function testSecureBankBlocksReentrancy() public {
        // Deploy an attacker targeting the secure bank
        ReentrancyAttacker secureAttacker = new ReentrancyAttacker(address(secureBank));

        // Victim deposits 10 ETH
        secureBank.deposit{value: 10 ether}();

        // Attacker attempts to deposit 1 ETH and drain the bank
        vm.expectRevert();
        secureAttacker.attack{value: 1 ether}();

        // The secure bank must retain the victim's 10 ETH
        assertEq(address(secureBank).balance, 10 ether);

        // Attacker's attempted transaction must have reverted
        assertEq(address(secureAttacker).balance, 0);
    }
}
