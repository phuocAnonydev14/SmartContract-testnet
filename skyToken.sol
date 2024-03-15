// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SkyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Sky", "SK") {
        _mint(msg.sender, initialSupply);
    }
}