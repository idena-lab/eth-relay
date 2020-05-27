const h = require("./helper");
const BN = require("bn.js");

const IdenaWorldState = artifacts.require("IdenaWorldState");

contract("IdenaWorldState", (accounts) => {
  const deployer = accounts[0];
  const owner = deployer;

  before(async () => {
    this.idenaWorld = await IdenaWorldState.deployed();
    this.idenaWorld.should.exist;
  });

  it("owner should be deployer", async () => {
    it("owner", async () => {
      (await this.idenaWorld.owner()).should.equal(deployer);
    });
  });

  describe("call init()", async () => {
    const epoch = new BN(40);
    const identities = [accounts[1], accounts[2]];
    const pubkeys = [
      [new BN(h.randHex(64), 16), new BN(h.randHex(64), 16)],
      [new BN(h.randHex(64), 16), new BN(h.randHex(64), 16)],
    ];
    const states = [new BN((4 << 8) + 1), new BN((10 << 8) + 1)];
    it("init should failed by non-owner", async () => {
      const nonOwner = accounts[3];
      await this.idenaWorld
        .init(epoch, identities, pubkeys, states, {
          from: nonOwner,
        })
        .should.be.rejectedWith(h.EVMRevert);
    });
    it("init should succ by owner", async () => {
      const owner = deployer;
      await this.idenaWorld.init(epoch, identities, pubkeys, states, {
        from: owner,
      }).should.be.fulfilled;
    });
    it("check states after init", async () => {
      (await this.idenaWorld.initialized()).should.equal(true);
      (await this.idenaWorld.epoch()).should.eq.BN(epoch);
      (await this.idenaWorld.population()).should.eq.BN(
        new BN(identities.length)
      );
      const cIdentities = await this.idenaWorld.identities();
      for (let i = 0; i < cIdentities.length; i++) {
        cIdentities[i].toLowerCase().should.equal(identities[i].toLowerCase());
        const cState = await this.idenaWorld.stateOf(identities[i]);
        // console.log(cState);
        cState.pubX.should.eq.BN(pubkeys[i][0]);
        cState.pubY.should.eq.BN(pubkeys[i][1]);
        cState.birth.should.eq.BN(states[i].shrn(8));
        cState.state.should.eq.BN(states[i].mod(new BN(1<<8)));
      }
    });
  });
});
