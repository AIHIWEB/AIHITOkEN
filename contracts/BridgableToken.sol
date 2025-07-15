// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

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

    constructor(uint256 major, uint256 minor, uint256 patch) {
        version = string(
            abi.encodePacked(toString(major), ".", toString(minor), ".", toString(patch))
        );
    }
}

contract BridgableToken is IOptimismMintableERC20, ILegacyMintableERC20, ERC20, Semver {
    address public immutable REMOTE_TOKEN;
    address public immutable BRIDGE;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);

    modifier onlyBridge() {
        require(msg.sender == BRIDGE, "MyCustomL2Token: only bridge can mint and burn");
        _;
    }

    constructor(
        address _bridge,
        address _remoteToken,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) Semver(1, 0, 0) {
        REMOTE_TOKEN = _remoteToken;
        BRIDGE = _bridge;
    }

    function mint(address _to, uint256 _amount)
        external
        override(IOptimismMintableERC20, ILegacyMintableERC20)
        onlyBridge
    {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount)
        external
        override(IOptimismMintableERC20, ILegacyMintableERC20)
        onlyBridge
    {
        _burn(_from, _amount);
        emit Burn(_from, _amount);
    }

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        bytes4 iface1 = type(IERC165).interfaceId;
        bytes4 iface2 = type(ILegacyMintableERC20).interfaceId;
        bytes4 iface3 = type(IOptimismMintableERC20).interfaceId;
        return _interfaceId == iface1 || _interfaceId == iface2 || _interfaceId == iface3;
    }

    function l1Token() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    function l2Bridge() public view override returns (address) {
        return BRIDGE;
    }

    function remoteToken() public view override returns (address) {
        return REMOTE_TOKEN;
    }

    function bridge() public view override returns (address) {
        return BRIDGE;
    }
}

