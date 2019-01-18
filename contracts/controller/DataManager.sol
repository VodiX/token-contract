pragma solidity ^0.5.0;

import "../token/DataCentre.sol";
import "../ownership/Pausable.sol";


contract DataManager is Pausable {

    // satelite contract addresses
    address public dataCentreAddr;

    constructor (address _dataCentreAddr) public {
        dataCentreAddr = _dataCentreAddr;
    }

    // Constant Functions
    function balanceOf(address _owner) public view returns (uint256) {
        return DataCentre(dataCentreAddr).getBalanace("VDX", _owner);
    }

    function totalSupply() public view returns (uint256) {
        return DataCentre(dataCentreAddr).getValue("VDX", "totalSupply");
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return DataCentre(dataCentreAddr).getConstraint("VDX", _owner, _spender);
    }

    function _setTotalSupply(uint256 _newTotalSupply) internal {
        DataCentre(dataCentreAddr).setValue("VDX", "totalSupply", _newTotalSupply);
    }

    function _setBalanceOf(address _owner, uint256 _newValue) internal {
        DataCentre(dataCentreAddr).setBalanace("VDX", _owner, _newValue);
    }

    function _setAllowance(address _owner, address _spender, uint256 _newValue) internal {
        DataCentre(dataCentreAddr).setConstraint("VDX", _owner, _spender, _newValue);
    }

}
