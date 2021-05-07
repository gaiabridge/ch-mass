// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ChainHorizonMassInterface.sol";

contract ChainHorizonMass is ChainHorizonMassInterface {

    string constant private NAME = "Chain Horizon Mass";
    string constant private SYMBOL = "CHM";
    uint8 constant private DECIMALS = 18;
    address constant private ORACLE = 0x67aaB54e9F81d35B2d9Ad7Bc3b6505095618aeB0;
	uint256 constant private INITIAL_SUPPLY = 10000000 * (10 ** uint(DECIMALS));
    
    uint256 private _totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    
    struct BurnRecord {
        address owner;
        uint256 toChainId;
        uint256 amount;
    }
    BurnRecord[] public burnHistory;
    
    struct MintRecord {
        address owner;
        uint256 fromChainId;
        uint256 burnId;
        uint256 amount;
    }
    MintRecord[] public mintHistory;
    
    constructor() {
		balances[msg.sender] = INITIAL_SUPPLY;
		_totalSupply = INITIAL_SUPPLY;
	}

    function name() external pure override returns (string memory) { return NAME; }
    function symbol() external pure override returns (string memory) { return SYMBOL; }
    function decimals() external pure override returns (uint8) { return DECIMALS; }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function balanceOf(address user) external view override returns (uint256 balance) {
        return balances[user];
    }

    function transfer(address to, uint256 amount) public override returns (bool success) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool success) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address user, address spender) external view override returns (uint256 remaining) {
        return allowed[user][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool success) {
        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function burn(uint256 toChainId, uint256 amount) public override returns (uint256) {
        
        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        uint256 burnId = burnHistory.length;
        burnHistory.push(BurnRecord({
            owner: msg.sender,
            toChainId: toChainId,
            amount: amount
        }));
        
        emit Burn(msg.sender, amount);
        return burnId;
    }

    function mint(uint256 fromChainId, uint256 burnId, uint256 amount, bytes memory signature) public override {
        require(signature.length == 65, "invalid signature length");
        
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, fromChainId, burnId, amount));
        hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "invalid signature version");
        
        require(ecrecover(hash, v, r, s) == ORACLE);
        
        balances[msg.sender] += amount;
        _totalSupply += amount;
        
        mintHistory.push(MintRecord({
            owner: msg.sender,
            fromChainId: fromChainId,
            burnId: burnId,
            amount: amount
        }));
        
        emit Mint(msg.sender, amount);
    }
}