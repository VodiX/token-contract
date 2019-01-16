const { shouldBehaveLikePublicRole } = require('../zeppelin-solidity/test/access/roles/PublicRole.behavior');
const WhitelistedRoleExtendedMock = artifacts.require('WhitelistedRoleExtendedMock');

contract('WhitelistedRoleExtended', function ([_, whitelisted, otherWhitelisted, whitelistAdmin, ...otherAccounts]) {
  beforeEach(async function () {
    this.contract = await WhitelistedRoleExtendedMock.new({ from: whitelistAdmin });
    await this.contract.addWhitelisted(whitelisted, { from: whitelistAdmin });
    await this.contract.addWhitelisted(otherWhitelisted, { from: whitelistAdmin });
  });

  shouldBehaveLikePublicRole(whitelisted, otherWhitelisted, otherAccounts, 'whitelisted', whitelistAdmin);

  it('add whitelisted in bulk', async function () {
    await this.contract.addWhitelistedBulk(otherAccounts, { from: whitelistAdmin });
    for (let i = 0; i < otherAccounts.length; i++) {
      (await this.contract.isWhitelisted(otherAccounts[i])).should.equal(true);
    }
  });

  it('remove whitelisted in bulk', async function () {
    const whitelistedAccounts = [whitelisted, otherWhitelisted];
    await this.contract.removeWhitelistedBulk(whitelistedAccounts, { from: whitelistAdmin });
    for (let i = 0; i < whitelistedAccounts.length; i++) {
      (await this.contract.isWhitelisted(whitelistedAccounts[i])).should.equal(false);
    }
  });
});
