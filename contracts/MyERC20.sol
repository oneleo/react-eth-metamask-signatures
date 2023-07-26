// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// If using Hardhat, you need to import the package through the command "pnpm install @openzeppelin/contracts".
// 如果使用 Hardhat 需透過 pnpm install @openzeppelin/contracts 指令來匯入套件。
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// If using Remix, you can directly import the package through the GitHub URL.
// Remix website: https://remix.ethereum.org/
// 如果使用 Remix 可直接透過 GitHub 網址來匯入套件。
// Remix 網站：https://remix.ethereum.org/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/utils/math/SafeMath.sol";

contract CHTToken is ERC20 {
    using SafeMath for uint256;

    address public owner;
    string private constant _name = "Chunghwa Telecom Token";
    string private constant _symbol = "CHT";
    uint256 public constant price = 0.0000001 ether; // Price to mint this token

    constructor(uint256 _initialSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply.mul(10 ** 18));
    }

    function mint() external payable {
        require(msg.value >= price, "Value must be greater than price.");
        // Transfer the minting fee to the token owner.
        // 將鑄造費轉給 Token 擁有者。
        (bool success, bytes memory result) = payable(owner).call{
            value: msg.value
        }("");
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
        _mint(msg.sender, msg.value.div(price));
    }
}
