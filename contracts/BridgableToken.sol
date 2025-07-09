// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ILegacyMintableERC20 {
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;

    function l1Token() external view returns (address);
    function l2Bridge() external view returns (address);
}

interface IOptimismMintableERC20 {
    function remoteToken() external view returns (address);
    function bridge() external view returns (address);
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
}

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

/// @title AIHIToken - 支持 Optimism Mint/Burn 的 L2 代币
contract BridgableToken is ERC20, Ownable, Semver, IOptimismMintableERC20, ILegacyMintableERC20 {
    address public immutable _bridge;
    address public immutable _remoteToken;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    modifier onlyBridge() {
        require(msg.sender == _bridge, "AIHIToken: only bridge can call this");
        _;
    }

    constructor(
        address bridge_,
        address remoteToken_,
        string memory _name,
        string memory _symbol,
        address _initialHolder,
        uint256 _initialSupply
    )
        ERC20(_name, _symbol)
        Ownable(_initialHolder)
        Semver(1, 0, 0)
    {
        require(bridge_ != address(0), "Bridge address is zero");
        require(remoteToken_ != address(0), "Remote token address is zero");
        require(_initialHolder != address(0), "Invalid initial holder");

        _bridge = bridge_;
        _remoteToken = remoteToken_;

        if (_initialSupply > 0) {
            _mint(_initialHolder, _initialSupply);
            emit Mint(_initialHolder, _initialSupply);
        }
    }

    function mint(address to, uint256 amount)
        external
        override(IOptimismMintableERC20, ILegacyMintableERC20)
        onlyBridge
    {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(address from, uint256 amount)
        external
        override(IOptimismMintableERC20, ILegacyMintableERC20)
        onlyBridge
    {
        _burn(from, amount);
        emit Burn(from, amount);
    }

    function remoteToken() external view override returns (address) {
        return _remoteToken;
    }

    function bridge() external view override returns (address) {
        return _bridge;
    }

    function l1Token() external view override returns (address) {
        return _remoteToken;
    }

    function l2Bridge() external view override returns (address) {
        return _bridge;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IOptimismMintableERC20).interfaceId ||
            interfaceId == type(ILegacyMintableERC20).interfaceId;
    }
}
