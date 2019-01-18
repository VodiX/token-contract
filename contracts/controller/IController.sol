pragma solidity ^0.5.0;


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
