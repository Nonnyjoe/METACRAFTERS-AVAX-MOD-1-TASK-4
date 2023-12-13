// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {

    mapping(uint256 storeItemId => mapping(address => uint256)) private storeItemBalances;
    mapping(uint256 storeItemId => uint256 itemPrice) public storeItemPrice;
    mapping(uint256 storeItemId => string itemName) public storeItemName;
    mapping(uint256 storeItemId => bool) public isListed;
    uint256 allItems;

    event itemListed(string indexed itemName, uint256 indexed itemId, uint256 indexed ItemPrice);
    event itemPurchased(address buyer, uint256 itemId, uint256 amount);

    constructor() ERC20("Degen", "DGN") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        require(amount <= balanceOf(msg.sender), "Insufficient Degen Tokens");
        _burn(msg.sender, amount);
    }

    function getDegenBalance(address account) external view returns (uint256) {
       return super.balanceOf(account);
    }

    function getItemName(uint256 itemId) external view returns (string memory) {
        return storeItemName[itemId];
    }

    function listItem(uint256 ItemPrice, string memory ItemName) public onlyOwner {
        allItems +=1;
        storeItemName[allItems] = ItemName;
        storeItemPrice[allItems] = ItemPrice;
        isListed[allItems] = true;
        emit itemListed(ItemName, allItems, ItemPrice);
    }

    function redeemToken(uint256 itemId, uint256 quantity) external {
        uint256 price = quantity * storeItemPrice[itemId];
        require(isListed[itemId] == true, "Invalid itemId");
        require(super.balanceOf(msg.sender) >= price, "Insufficent Degen Tokens");
        _burn(msg.sender, price);
        storeItemBalances[itemId][msg.sender] += quantity;
        emit itemPurchased(msg.sender, itemId, quantity);
    }

    function getStoreItemBalance(uint256 itemID, address account) external view returns (uint256) {
        return storeItemBalances[itemID][account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        return super.transfer(to, amount);
    }
}
