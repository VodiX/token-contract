pragma solidity ^0.5.0;

import "../../zeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";

/**
 * @title WhitelistedRoleExtended
 * @dev Extending parent contract with bulk addition and removal functionalities
 */
contract WhitelistedRoleExtended is WhitelistedRole {
    function addWhitelistedBulk(address[] memory accounts) public onlyWhitelistAdmin {
        for (uint16 i = 0; i < accounts.length; i++) {
            _addWhitelisted(accounts[i]);
        }
    }

    function removeWhitelistedBulk(address[] memory accounts) public onlyWhitelistAdmin {
        for (uint16 i = 0; i < accounts.length; i++) {
            _removeWhitelisted(accounts[i]);
        }
    }
}
