// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ChainHorizonMassInterface {

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Burn(address indexed owner, uint256 amount);
    event Mint(address indexed owner, uint256 amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address to, uint256 amount) external returns (bool success);
    function transferFrom(address from, address to, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    function burn(uint256 toChain, uint256 amount) external returns (uint256 burnId);
    function burnCount(uint256 toChain) external view returns (uint256);
    function mint(uint256 fromChain, uint256 burnId, uint256 amount, bytes memory signature) external;
    function checkMinted(uint256 fromChain, uint256 burnId) external view returns (bool);
}