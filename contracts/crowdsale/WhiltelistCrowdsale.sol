pragma solidity ^0.5.0;
import "openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "./WhitelistedRoleExtended.sol";


/**
 * @title WhitelistCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistCrowdsale is WhitelistedRoleExtended, Crowdsale {
    /**
    * @dev Extend parent behavior requiring beneficiary to be whitelisted. Note that no
    * restriction is imposed on the account sending the transaction.
    * @param _beneficiary Token beneficiary
    * @param _weiAmount Amount of wei contributed
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(isWhitelisted(_beneficiary));
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
