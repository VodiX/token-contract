const DataCentre = artifacts.require('DataCentre');
const Controller = artifacts.require('Controller');
const Token = artifacts.require('./token/ERC20.sol');

const { shouldFail, constants } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;

contract('Controller', (accounts) => {
  let token;
  let dataCentre;
  let controller;

  beforeEach(async () => {
    token = await Token.new();
    dataCentre = await DataCentre.new();
    controller = await Controller.new(token.address, dataCentre.address)
    await token.transferOwnership(controller.address);
    await dataCentre.transferOwnership(controller.address);
    await controller.unpause();
  });

  it('should allow start Minting after stopping', async () => {
    await controller.finishMinting();
    await controller.startMinting();
    const mintStatus = await controller.mintingFinished.call();
    assert.equal(mintStatus, false);
  });

  it('should allow to set new contracts', async () => {
    await controller.pause();
    const dataCentre = await DataCentre.new();
    token = await Token.new();
    await dataCentre.transferOwnership(controller.address);
    await controller.setContracts(token.address, dataCentre.address);
    const dataCentreSet = await controller.dataCentreAddr.call();
    assert.equal(dataCentreSet, dataCentre.address);
  });

  it('should allow to kill', async () => {
    await controller.pause();
    const dataCentreOld = await controller.dataCentreAddr.call();
    const controllerNew = await Controller.new(token.address, dataCentreOld);
    await controller.kill(controllerNew.address);
    const dataCentreSet = await controllerNew.dataCentreAddr.call();
    const tokenSet = await controllerNew.satellite.call();
    assert.equal(dataCentreSet, dataCentreOld);
    assert.equal(tokenSet, token.address);
  });

  it('should allow to kill even if satellite not set', async () => {
    token = await Token.new();
    controller = await Controller.new(token.address, ZERO_ADDRESS);
    await token.transferOwnership(controller.address);

    const controllerNew = await Controller.new(token.address, ZERO_ADDRESS);
    await controller.kill(controllerNew.address);
    const tokenSet = await controllerNew.satellite.call();
    assert.equal(tokenSet, token.address);
  });

  it('should allow to kill even if dataCentre not set', async () => {
    dataCentre = await DataCentre.new();
    controller = await Controller.new(ZERO_ADDRESS, dataCentre.address)
    await dataCentre.transferOwnership(controller.address);

    const dataCentreOld = await controller.dataCentreAddr.call();
    const controllerNew = await Controller.new(ZERO_ADDRESS, dataCentreOld);
    await controller.kill(controllerNew.address);
    const dataCentreSet = await controllerNew.dataCentreAddr.call();
    assert.equal(dataCentreSet, dataCentreOld);
  });

  it('should not allow scammer to use onlyToken functions', async () => {
    const INVESTOR = accounts[0];
    const SCAMMER = accounts[4];
    const BENEFICIARY = accounts[5];

    await shouldFail.reverting(controller.approve(INVESTOR, BENEFICIARY, "10000000000000", {from: SCAMMER}));
  });
});
