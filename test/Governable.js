
const { shouldFail } = require('openzeppelin-test-helpers');

const Governable = artifacts.require('Governable')

contract('Governable', function (accounts) {

  beforeEach(async function () {
    this.governable = await Governable.new({from: accounts[0]})
  })


  it('should not allow to add admin by non admin', async function () {
    await shouldFail.reverting(this.governable.addAdmin(accounts[1], {from: accounts[1]}));
  })

  it('should not allow to add admin by if already admin', async function () {
    await shouldFail.reverting(this.governable.addAdmin(accounts[0], {from: accounts[0]}));
  })

  it('should not allow to remove non admi', async function () {
    await shouldFail.reverting(this.governable.removeAdmin(accounts[1], {from: accounts[0]}));
  })

  it('should not allow to add more than 10 admins', async function () {
    await this.governable.addAdmin(accounts[1], {from: accounts[0]})
    await this.governable.addAdmin(accounts[2], {from: accounts[0]})
    await this.governable.addAdmin(accounts[3], {from: accounts[0]})
    await this.governable.addAdmin(accounts[4], {from: accounts[0]})
    await this.governable.addAdmin(accounts[5], {from: accounts[0]})
    await this.governable.addAdmin(accounts[6], {from: accounts[0]})
    await this.governable.addAdmin(accounts[7], {from: accounts[0]})
    await this.governable.addAdmin(accounts[8], {from: accounts[0]})
    await this.governable.addAdmin(accounts[9], {from: accounts[0]});
    await shouldFail.reverting(this.governable.addAdmin("0x06ec11c59c1af941cde8f9d89fe6765199f41d09", {from: accounts[0]}));
  })

  it('should allow to add and remove admin by admin', async function () {
    await this.governable.addAdmin(accounts[1], {from: accounts[0]})
    await this.governable.addAdmin(accounts[2], {from: accounts[0]})

    await this.governable.removeAdmin(accounts[1], {from: accounts[0]})
    await this.governable.removeAdmin(accounts[2], {from: accounts[0]})
  })
})
