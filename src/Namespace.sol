// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Namespace is ERC721, ERC721Enumerable, Ownable {
    uint256 private _nextTokenId = 1;

    mapping(uint256 => string) public tokenIdToNamespace;
    mapping(string => uint256) public namespaceToTokenId;

    constructor(address initialOwner) ERC721("Namespace Token", "NS") Ownable(initialOwner) {}

    function safeMint(string memory nameSpace) public onlyOwner {
        address to = _msgSender();
        require(bytes(nameSpace).length > 0, "Namespace cannot be empty");
        require(namespaceToTokenId[nameSpace] == 0, "Namespace is already taken");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        tokenIdToNamespace[tokenId] = nameSpace;
        namespaceToTokenId[nameSpace] = tokenId;
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
