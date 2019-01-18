const MockDataManager = artifacts.require('MockDataManager');
const DataCentre = artifacts.require('DataCentre');

contract('DataManager', (accounts) => {
  let dataManager;
  let dataCentre;

  beforeEach(async () => {
    dataCentre = await DataCentre.new();
    dataManager = await MockDataManager.new(dataCentre.address);
    await dataCentre.transferOwnership(dataManager.address);
  });

  it('should allow owner to setState', async () => {

    await dataManager.setState(true);
    const state = await dataManager.getState.call();

    assert.equal(state, true);
  });

  it('should allow owner to setOwner', async () => {

    await dataManager.setOwner(accounts[0]);
    const owner = await dataManager.getOwner.call();

    assert.equal(owner, accounts[0]);
  });

})
