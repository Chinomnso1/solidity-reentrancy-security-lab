# Smart Contract Security Finding

## Finding
Reentrancy Vulnerability in VulnerableBank.withdraw()

## Vulnerability Classification
CWE-841: Improper Enforcement of Behavioral Workflow

SWC-107: Reentrancy

## Severity
High potential severity (preliminary assessment)

## Affected Contract
src/VulnerableBank.sol

## Description
The withdraw() function transfers ETH to the caller before
updating the caller's recorded balance.

This allows a malicious contract to re-enter withdraw()
through its receive() function before the balance is reset.

## Impact
An attacker can repeatedly withdraw funds and potentially
drain ETH deposited by other users.

## Proof of Concept
A Foundry test successfully demonstrated the vulnerability.

The attacker deposited 1 ETH and drained 10 ETH belonging
to another depositor.

## Remediation
Apply the Checks-Effects-Interactions pattern.

Update the user's balance before making the external ETH transfer.

Consider adding a reentrancy guard as additional protection.

## Validation
- Foundry exploit test: PASS
- Foundry secure-contract test: PASS
- Slither vulnerable contract: reentrancy-eth detected
- Slither secure contract: reentrancy-eth not detected
