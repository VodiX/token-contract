pragma solidity ^0.5.0;

import "../../contracts/controller/DataManager.sol";


contract MockDataManager is DataManager {

    constructor (address _dataCentreAddr) public
        DataManager(_dataCentreAddr)
    {

    }

    function getState() public view returns (bool) {
        return DataCentre(dataCentreAddr).getBool("VDX", "State");
    }

    function getOwner() public view returns (address) {
        return DataCentre(dataCentreAddr).getAddress("VDX", "Address(this)");
    }

    function setState(bool _state) public onlyAdmins {
        _setState(_state);
    }

    function setOwner(address _owner) public onlyAdmins {
        _setOwner(_owner);
    }

    function _setState(bool _state) internal {
        DataCentre(dataCentreAddr).setBool("VDX", "State", _state);
    }

    function _setOwner(address _owner) internal {
        DataCentre(dataCentreAddr).setAddress("VDX", "Address(this)", _owner);
    }

}
