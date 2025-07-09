// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Semver - 简单版本信息管理合约
contract Semver {
    string public version;

    constructor(uint256 major, uint256 minor, uint256 patch) {
        version = string(
            abi.encodePacked(
                toString(major), ".", toString(minor), ".", toString(patch)
            )
        );
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

/// @title NonMintableToken - NonMintableToken
contract NonMintableToken is ERC20, Ownable, Semver {
    constructor(
        string memory _name,
        string memory _symbol,
        address _initialHolder,
        uint256 _initialSupply
    )
        ERC20(_name, _symbol)
        Ownable(_initialHolder)
        Semver(1, 0, 0)
    {
        require(_initialHolder != address(0), "Invalid initial holder");
        require(_initialSupply > 0, "Initial supply must be > 0");

        _mint(_initialHolder, _initialSupply);
    }
}
