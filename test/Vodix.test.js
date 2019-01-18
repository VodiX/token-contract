const { BN, constants, expectEvent, shouldFail } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;
const { shouldBehaveLikeERC20Burnable } = require('./behaviors/ERC20Burnable.behavior');

const VodiX = artifacts.require('VodiX');
const DataCentre = artifacts.require('DataCentre');
const Controller = artifacts.require('Controller');

contract('VodiX', function ([owner, recipient, anotherAccount, ...otherAccounts]) {
  const initialSupply = new BN(1e11).muln(1e6).muln(1e6).muln(1e4);
  beforeEach(async function () {
    this.token = await VodiX.new({ from: owner });
    this.dataCentre = await DataCentre.new({ from: owner });
    this.controller = await Controller.new(this.token.address, this.dataCentre.address, { from: owner });
    await this.token.transferOwnership(this.controller.address), { from: owner };
    await this.dataCentre.transferOwnership(this.controller.address, { from: owner });
    await this.controller.unpause({ from: owner });
    await this.controller.mint(owner, initialSupply, { from: owner });
  });

  describe('ERC20Detailed', function () {
    const _name = 'Vodi X';
    const _symbol = 'VDX';
    const _decimals = new BN(18);

    it('has a name', async function () {
      (await this.token.name()).should.be.equal(_name);
    });

    it('has a symbol', async function () {
      (await this.token.symbol()).should.be.equal(_symbol);
    });

    it('has an amount of decimals', async function () {
      (await this.token.decimals()).should.be.bignumber.equal(_decimals);
    });
  });


  describe('total supply', function () {
    it('returns the total amount of tokens', async function () {
      (await this.token.totalSupply()).should.be.bignumber.equal(initialSupply);
    });
  });

  describe('balanceOf', function () {
    describe('when the requested account has no tokens', function () {
      it('returns zero', async function () {
        (await this.token.balanceOf(anotherAccount)).should.be.bignumber.equal('0');
      });
    });

    describe('when the requested account has some tokens', function () {
      it('returns the total amount of tokens', async function () {
        (await this.token.balanceOf(owner)).should.be.bignumber.equal(initialSupply);
      });
    });
  });

  describe('transfer', function () {
    describe('when the recipient is not the zero address', function () {
      const to = recipient;

      describe('when the sender does not have enough balance', function () {
        const amount = initialSupply.addn(1);

        it('reverts', async function () {
          await shouldFail.reverting(this.token.transfer(to, amount, { from: owner }));
        });
      });

      describe('when the sender has enough balance', function () {
        const amount = initialSupply;

        it('transfers the requested amount', async function () {
          await this.token.transfer(to, amount, { from: owner });
          (await this.token.balanceOf(owner)).should.be.bignumber.equal('0');

          (await this.token.balanceOf(to)).should.be.bignumber.equal(amount);
        });

        it('emits a transfer event', async function () {
          const { logs } = await this.token.transfer(to, amount, { from: owner });

          expectEvent.inLogs(logs, 'Transfer', {
            from: owner,
            to: to,
            value: amount,
          });
        });
      });
    });

      describe('when the recipient is the zero address', function () {
        const to = ZERO_ADDRESS;

        it('reverts', async function () {
          await shouldFail.reverting(this.token.transfer(to, initialSupply, { from: owner }));
        });
      });
    });

    describe('approve', function () {
      describe('when the spender is not the zero address', function () {
        const spender = recipient;

        describe('when the sender has enough balance', function () {
          const amount = initialSupply;

          it('emits an approval event', async function () {
            const { logs } = await this.token.approve(spender, amount, { from: owner });

            expectEvent.inLogs(logs, 'Approval', {
              owner: owner,
              spender: spender,
              value: amount,
            });
          });

          describe('when there was no approved amount before', function () {
            it('approves the requested amount', async function () {
              await this.token.approve(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount);
            });
          });

          describe('when the spender had an approved amount', function () {
            beforeEach(async function () {
              await this.token.approve(spender, new BN(1), { from: owner });
            });

            it('approves the requested amount and replaces the previous one', async function () {
              await this.token.approve(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount);
            });
          });
        });

        describe('when the sender does not have enough balance', function () {
          const amount = initialSupply.addn(1);

          it('emits an approval event', async function () {
            const { logs } = await this.token.approve(spender, amount, { from: owner });

            expectEvent.inLogs(logs, 'Approval', {
              owner: owner,
              spender: spender,
              value: amount,
            });
          });

          describe('when there was no approved amount before', function () {
            it('approves the requested amount', async function () {
              await this.token.approve(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount);
            });
          });

          describe('when the spender had an approved amount', function () {
            beforeEach(async function () {
              await this.token.approve(spender, new BN(1), { from: owner });
            });

            it('approves the requested amount and replaces the previous one', async function () {
              await this.token.approve(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount);
            });
          });
        });
      });

      describe('when the spender is the zero address', function () {
        const amount = initialSupply;
        const spender = ZERO_ADDRESS;

        it('reverts', async function () {
          await shouldFail.reverting(this.token.approve(spender, amount, { from: owner }));
        });
      });
    });

    describe('transfer from', function () {
      const spender = recipient;

      describe('when the recipient is not the zero address', function () {
        const to = anotherAccount;

        describe('when the spender has enough approved balance', function () {
          beforeEach(async function () {
            await this.token.approve(spender, initialSupply, { from: owner });
          });

          describe('when the initial holder has enough balance', function () {
            const amount = initialSupply;

            it('transfers the requested amount', async function () {
              await this.token.transferFrom(owner, to, amount, { from: spender });

              (await this.token.balanceOf(owner)).should.be.bignumber.equal('0');

              (await this.token.balanceOf(to)).should.be.bignumber.equal(amount);
            });

            it('decreases the spender allowance', async function () {
              await this.token.transferFrom(owner, to, amount, { from: spender });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal('0');
            });

            it('emits a transfer event', async function () {
              const { logs } = await this.token.transferFrom(owner, to, amount, { from: spender });

              expectEvent.inLogs(logs, 'Transfer', {
                from: owner,
                to: to,
                value: amount,
              });
            });

            it('emits an approval event', async function () {
              const { logs } = await this.token.transferFrom(owner, to, amount, { from: spender });

              expectEvent.inLogs(logs, 'Approval', {
                owner: owner,
                spender: spender,
                value: await this.token.allowance(owner, spender),
              });
            });
          });

          describe('when the initial holder does not have enough balance', function () {
            const amount = initialSupply.addn(1);

            it('reverts', async function () {
              await shouldFail.reverting(this.token.transferFrom(owner, to, amount, { from: spender }));
            });
          });
        });

        describe('when the spender does not have enough approved balance', function () {
          beforeEach(async function () {
            await this.token.approve(spender, initialSupply.subn(1), { from: owner });
          });

          describe('when the initial holder has enough balance', function () {
            const amount = initialSupply;

            it('reverts', async function () {
              await shouldFail.reverting(this.token.transferFrom(owner, to, amount, { from: spender }));
            });
          });

          describe('when the initial holder does not have enough balance', function () {
            const amount = initialSupply.addn(1);

            it('reverts', async function () {
              await shouldFail.reverting(this.token.transferFrom(owner, to, amount, { from: spender }));
            });
          });
        });
      });

      describe('when the recipient is the zero address', function () {
        const amount = initialSupply;
        const to = ZERO_ADDRESS;

        beforeEach(async function () {
          await this.token.approve(spender, amount, { from: owner });
        });

        it('reverts', async function () {
          await shouldFail.reverting(this.token.transferFrom(owner, to, amount, { from: spender }));
        });
      });
    });

    describe('decrease allowance', function () {
      describe('when the spender is not the zero address', function () {
        const spender = recipient;

        function shouldDecreaseApproval (amount) {
          describe('when there was no approved amount before', function () {
            it('reverts', async function () {
              await shouldFail.reverting(this.token.decreaseAllowance(spender, amount, { from: owner }));
            });
          });

          describe('when the spender had an approved amount', function () {
            const approvedAmount = amount;

            beforeEach(async function () {
              ({ logs: this.logs } = await this.token.approve(spender, approvedAmount, { from: owner }));
            });

            it('emits an approval event', async function () {
              const { logs } = await this.token.decreaseAllowance(spender, approvedAmount, { from: owner });

              expectEvent.inLogs(logs, 'Approval', {
                owner: owner,
                spender: spender,
                value: new BN(0),
              });
            });

            it('decreases the spender allowance subtracting the requested amount', async function () {
              await this.token.decreaseAllowance(spender, approvedAmount.subn(1), { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal('1');
            });

            it('sets the allowance to zero when all allowance is removed', async function () {
              await this.token.decreaseAllowance(spender, approvedAmount, { from: owner });
              (await this.token.allowance(owner, spender)).should.be.bignumber.equal('0');
            });

            it('reverts when more than the full allowance is removed', async function () {
              await shouldFail.reverting(
                this.token.decreaseAllowance(spender, approvedAmount.addn(1), { from: owner })
              );
            });
          });
        }

        describe('when the sender has enough balance', function () {
          const amount = initialSupply;

          shouldDecreaseApproval(amount);
        });

        describe('when the sender does not have enough balance', function () {
          const amount = initialSupply.addn(1);

          shouldDecreaseApproval(amount);
        });
      });

      describe('when the spender is the zero address', function () {
        const amount = initialSupply;
        const spender = ZERO_ADDRESS;

        it('reverts', async function () {
          await shouldFail.reverting(this.token.decreaseAllowance(spender, amount, { from: owner }));
        });
      });
    });

    describe('increase allowance', function () {
      const amount = initialSupply;

      describe('when the spender is not the zero address', function () {
        const spender = recipient;

        describe('when the sender has enough balance', function () {
          it('emits an approval event', async function () {
            const { logs } = await this.token.increaseAllowance(spender, amount, { from: owner });

            expectEvent.inLogs(logs, 'Approval', {
              owner: owner,
              spender: spender,
              value: amount,
            });
          });

          describe('when there was no approved amount before', function () {
            it('approves the requested amount', async function () {
              await this.token.increaseAllowance(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount);
            });
          });

          describe('when the spender had an approved amount', function () {
            beforeEach(async function () {
              await this.token.approve(spender, new BN(1), { from: owner });
            });

            it('increases the spender allowance adding the requested amount', async function () {
              await this.token.increaseAllowance(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount.addn(1));
            });
          });
        });

        describe('when the sender does not have enough balance', function () {
          const amount = initialSupply.addn(1);

          it('emits an approval event', async function () {
            const { logs } = await this.token.increaseAllowance(spender, amount, { from: owner });

            expectEvent.inLogs(logs, 'Approval', {
              owner: owner,
              spender: spender,
              value: amount,
            });
          });

          describe('when there was no approved amount before', function () {
            it('approves the requested amount', async function () {
              await this.token.increaseAllowance(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount);
            });
          });

          describe('when the spender had an approved amount', function () {
            beforeEach(async function () {
              await this.token.approve(spender, new BN(1), { from: owner });
            });

            it('increases the spender allowance adding the requested amount', async function () {
              await this.token.increaseAllowance(spender, amount, { from: owner });

              (await this.token.allowance(owner, spender)).should.be.bignumber.equal(amount.addn(1));
            });
          });
        });
      });

      describe('when the spender is the zero address', function () {
        const spender = ZERO_ADDRESS;

        it('reverts', async function () {
          await shouldFail.reverting(this.token.increaseAllowance(spender, amount, { from: owner }));
        });
      });

      describe('ERC20Burnable', function () {

        shouldBehaveLikeERC20Burnable(owner, initialSupply, otherAccounts);
      });
  });
});
