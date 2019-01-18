pragma solidity ^0.5.0;


import "../ownership/Pausable.sol";


// mock class using Pausable
contract PausableMock is Pausable {
    bool public drasticMeasureTaken;
    uint256 public count;

    constructor () public {
        drasticMeasureTaken = false;
        paused = false;
        count = 0;
    }

    function normalProcess() external whenNotPaused(msg.sender) {
        count++;
    }

    function drasticMeasure() external whenPaused(msg.sender) {
        drasticMeasureTaken = true;
    }

}