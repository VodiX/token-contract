pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";

/**
 * @title AllocateEther
 * @dev Extension of Crowdsale where funds are kept in the crowdsale
 * contract until finalize is called.
 */
contract AllocateEther is FinalizableCrowdsale {
    // send ether to the fund collection wallet
  // called when owner calls finalize()
  function _finalization() internal {
    super._forwardFunds();
    super._finalization();
  }

  // overriding to keep funds in contract
  function _forwardFunds() internal {

  }
}

