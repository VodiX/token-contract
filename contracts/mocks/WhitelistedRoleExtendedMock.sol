pragma solidity ^0.5.0;

import "../crowdsale/WhitelistedRoleExtended.sol";

contract WhitelistedRoleExtendedMock is WhitelistedRoleExtended {
    function onlyWhitelistedMock() public view onlyWhitelisted {
        // solhint-disable-previous-line no-empty-blocks
    }
}
