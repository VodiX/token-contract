pragma solidity 0.5.0;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Governable {

    // list of admins, council at first spot
    address[] public admins;

    constructor () public {
        admins.length = 1;
        admins[0] = msg.sender;
    }

    modifier onlyAdmins() {
        (bool adminStatus, ) = isAdmin(msg.sender);
        require(adminStatus == true);
        _;
    }

    function addAdmin(address _admin) public onlyAdmins {
        (bool adminStatus, ) = isAdmin(_admin);
        require(!adminStatus);
        require(admins.length < 10);
        admins[admins.length++] = _admin;
    }

    function removeAdmin(address _admin) public onlyAdmins {
        (bool adminStatus, uint256 pos) = isAdmin(_admin);
        require(adminStatus);
        // if not last element, switch with last
        if (pos < admins.length - 1) {
            admins[pos] = admins[admins.length - 1];
        }
        // then cut off the tail
        admins.length--;
    }

    function isAdmin(address _addr) internal view returns (bool isAdmin, uint256 pos) {
        isAdmin = false;
        for (uint256 i = 0; i < admins.length; i++) {
            if (_addr == admins[i]) {
                isAdmin = true;
                pos = i;
            }
        }
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Governable {

    event Pause();
    event Unpause();
    bool public paused = true;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused(address _to) {
        (bool adminStatus, ) = isAdmin(_to);
        require(!paused || adminStatus);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused(address _to) {
        (bool adminStatus, ) = isAdmin(_to);
        require(paused || adminStatus);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyAdmins whenNotPaused(msg.sender) {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyAdmins whenPaused(msg.sender) {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract DataCentre is Ownable {
    struct Container {
        mapping(bytes32 => uint256) values;
        mapping(bytes32 => address) addresses;
        mapping(bytes32 => bool) switches;
        mapping(address => uint256) balances;
        mapping(address => mapping (address => uint)) constraints;
    }

    mapping(bytes32 => Container) containers;

    // Constant Functions
    function getValue(bytes32 _container, bytes32 _key) external view returns(uint256) {
        return containers[_container].values[_key];
    }

    function getAddress(bytes32 _container, bytes32 _key) external view returns(address) {
        return containers[_container].addresses[_key];
    }

    function getBool(bytes32 _container, bytes32 _key) external view returns(bool) {
        return containers[_container].switches[_key];
    }

    function getBalanace(bytes32 _container, address _key) external view returns(uint256) {
        return containers[_container].balances[_key];
    }

    function getConstraint(bytes32 _container, address _source, address _key) external view returns(uint256) {
        return containers[_container].constraints[_source][_key];
    }

    // Owner Functions
    function setValue(bytes32 _container, bytes32 _key, uint256 _value) external onlyOwner {
        containers[_container].values[_key] = _value;
    }

    function setAddress(bytes32 _container, bytes32 _key, address _value) external onlyOwner {
        containers[_container].addresses[_key] = _value;
    }

    function setBool(bytes32 _container, bytes32 _key, bool _value) external onlyOwner {
        containers[_container].switches[_key] = _value;
    }

    function setBalanace(bytes32 _container, address _key, uint256 _value) external onlyOwner {
        containers[_container].balances[_key] = _value;
    }

    function setConstraint(bytes32 _container, address _source, address _key, uint256 _value) external onlyOwner {
        containers[_container].constraints[_source][_key] = _value;
    }

}


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


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title ControlCentreInterface
 * @dev ControlCentreInterface is an interface for providing commonly used function
 * signatures to the ControlCentre
 */
interface IController {

    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);

    function approve(address owner, address spender, uint256 value) external returns (bool);
    function transfer(address owner, address to, uint value) external returns (bool);
    function transferFrom(address owner, address from, address to, uint256 amount) external returns (uint256);
    function mint(address _to, uint256 _amount)  external returns (bool);

    function increaseAllowance(address owner, address spender, uint256 addedValue) external returns (uint256);
    function decreaseAllowance(address owner, address spender, uint256 subtractedValue) external returns (uint256);

    function burn(address owner, uint value) external returns (bool);
    function burnFrom(address spender, address from, uint value) external returns (uint256);
}


contract ERC20 is Ownable, IERC20 {

    event Mint(address indexed to, uint256 amount);
    event Log(address to);
    event MintToggle(bool status);
    
    // Constant Functions
    function balanceOf(address _owner) public view returns (uint256) {
        return IController(owner()).balanceOf(_owner);
    }

    function totalSupply() public view returns (uint256) {
        return IController(owner()).totalSupply();
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return IController(owner()).allowance(_owner, _spender);
    }

    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function mintToggle(bool status) public onlyOwner returns (bool) {
        emit MintToggle(status);
        return true;
    }

    // public functions
    function approve(address _spender, uint256 _value) public returns (bool) {
        IController(owner()).approve(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        uint256 allowed = IController(owner()).increaseAllowance(msg.sender, spender, addedValue);
        emit Approval(msg.sender, spender, allowed);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 allowed = IController(owner()).decreaseAllowance(msg.sender, spender, subtractedValue);
        emit Approval(msg.sender, spender, allowed);
        return true;
    }

    function transfer(address to, uint value) public returns (bool) {
        IController(owner()).transfer(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        uint256 allowed = IController(owner()).transferFrom(msg.sender, _from, _to, _amount);
        emit Approval(_from, msg.sender, allowed);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function burn(uint256 value) public returns (bool) {
        IController(owner()).burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    function burnFrom(address from, uint256 value) public returns (bool) {
        uint256 allowed = IController(owner()).burnFrom(msg.sender, from, value);
        emit Approval(from, msg.sender, allowed);
        emit Transfer(from, address(0), value);
        return true;
    }
}


contract CrowdsaleControl is SimpleControl {
    
    using SafeMath for uint;

    // not necessary to store in data centre
    bool public mintingFinished = false;

    modifier canMint(bool status, address _to) {
        (bool adminStatus, ) = isAdmin(_to);
        require(!mintingFinished == status || adminStatus);
        _;
    }

    constructor (address _satellite, address _dataCentreAddr) public
        SimpleControl(_satellite, _dataCentreAddr)
    {

    }

    function mint(address _to, uint256 _amount) whenNotPaused(_to) canMint(true, msg.sender) onlyAdmins public returns (bool) {
        _setTotalSupply(totalSupply().add(_amount));
        _setBalanceOf(_to, balanceOf(_to).add(_amount));
        ERC20(satellite).mint(_to, _amount);
        return true;
    }

    function startMinting() public onlyAdmins returns (bool) {
        mintingFinished = false;
        ERC20(satellite).mintToggle(mintingFinished);
        return true;
    }

    function finishMinting() public onlyAdmins returns (bool) {
        mintingFinished = true;
        ERC20(satellite).mintToggle(mintingFinished);
        return true;
    }

}


/**
 Simple Token based on OpenZeppelin token contract
 */
contract Controller is CrowdsaleControl {

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor (address _satellite, address _dataCentreAddr) public
        CrowdsaleControl(_satellite, _dataCentreAddr)
    {

    }

    // Owner Functions
    function setContracts(address _satellite, address _dataCentreAddr) public onlyAdmins whenPaused(msg.sender) {
        dataCentreAddr = _dataCentreAddr;
        satellite = _satellite;
    }

    function kill(address payable _newController) public onlyAdmins whenPaused(msg.sender) {
        if (dataCentreAddr != address(0)) { 
            Ownable(dataCentreAddr).transferOwnership(msg.sender); 
        }

        if (satellite != address(0)) { 
            Ownable(satellite).transferOwnership(msg.sender); 
        }

        selfdestruct(_newController);
    }

}
