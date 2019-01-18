pragma solidity ^0.5.0;

import "./DataManager.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract SimpleControl is DataManager {
   
    using SafeMath for uint;
    
    // not necessary to store in data centre  address public satellite;

    address public satellite;

    modifier onlyToken {
        require(msg.sender == satellite);
        _;
    }

    constructor (address _satellite, address _dataCentreAddr) public
        DataManager(_dataCentreAddr)
    {
        satellite = _satellite;
    }

    // public functions
    function approve(address _owner, address _spender, uint256 _value) external onlyToken whenNotPaused(_owner) returns (bool) {
        _approve(_owner, _spender, _value);
        return true;
    }

    function transfer(address _from, address _to, uint256 _amount) external onlyToken whenNotPaused(_from) returns (bool) {
        return _transfer(_from, _to, _amount);
    }

    function transferFrom(address _sender, address _from, address _to, uint256 _amount) external onlyToken whenNotPaused(_sender) returns (uint256) {
        uint256 allowedNew = allowance(_from, _sender).sub(_amount);
        _setAllowance(_from, _sender, allowedNew);
        _transfer(_from, _to, _amount);
        return allowedNew;
    }
    
    function _transfer(address _from, address _to, uint256 _amount) internal returns (bool) {
        require(_to != address(this));
        require(_to != address(0));
        require(_amount > 0);
        require(_from != _to);
        _setBalanceOf(_from, balanceOf(_from).sub(_amount));
        _setBalanceOf(_to, balanceOf(_to).add(_amount));
        return true;
    }

    function increaseAllowance(address owner, address spender, uint256 addedValue) public returns (uint256) {
        uint256 allowed = allowance(owner, spender).add(addedValue);
        _approve(owner, spender, allowed);
        return allowed;
    }
    
    function decreaseAllowance(address owner, address spender, uint256 subtractedValue) public returns (uint256) {
        uint256 allowed = allowance(owner, spender).sub(subtractedValue);
        _approve(owner, spender, allowed);
        return allowed;
    }

    function burn(address owner, uint256 value) external onlyToken whenNotPaused(owner) returns (bool) {
        return _burn(owner, value);
    }


    function burnFrom(address spender, address from, uint256 value) external onlyToken whenNotPaused(spender) returns (uint256) {
        uint256 allowedNew = allowance(from, spender).sub(value);
        _setAllowance(from, spender, allowedNew);
        _burn(from, value);
        return allowedNew;
    }

    function _burn(address owner, uint256 value) internal returns (bool) {
        require(owner != address(0));
        _setTotalSupply(totalSupply().sub(value));
        _setBalanceOf(owner, balanceOf(owner).sub(value));
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _value) internal {
        require(_spender != address(0));
        _setAllowance(_owner, _spender, _value);
    }
}
