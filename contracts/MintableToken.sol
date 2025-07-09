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

/// @title MintableToken - MintableToken
contract MintableToken is ERC20, Ownable, Semver {
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

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

        if (_initialSupply > 0) {
            _mint(_initialHolder, _initialSupply);
            emit Mint(_initialHolder, _initialSupply);
        }
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
        emit Burn(from, amount);
    }
}
