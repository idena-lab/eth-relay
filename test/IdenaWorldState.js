const h = require("./helper");
const BN = require("bn.js");

const IdenaWorldState = artifacts.require("IdenaWorldState");
const IdenaWorldStateMock = artifacts.require("IdenaWorldStateMock");
const idenaData = require("./data/verify.json");

contract("IdenaWorldState", accounts => {
  const deployer = accounts[0];
  const owner = deployer;
  let mock;

  before(async () => {
    this.idenaWorld = await IdenaWorldState.deployed();
    this.idenaWorld.should.exist;
    mock = await IdenaWorldStateMock.new();
  });

  it("owner should be deployer", async () => {
    it("owner", async () => {
      (await this.idenaWorld.owner()).should.equal(deployer);
    });
  });

  describe("> verify", async () => {
    for (const [i, d] of idenaData.cases.entries()) {
      it(`check verify (${i + 1}): keys=${d.keys}, message=${d.message}`, async () => {
        // bad message
        await mock.verify
          .estimateGas(d.apk1, d.apk2, d.message + "bad", d.signature)
          .should.be.rejectedWith(h.EVMRevert);
        // bad apk1
        let badApk1 = [d.apk1[0], "0x4444444444444444444444444444444444444444444444444444444444444444"];
        await mock.verify.estimateGas(badApk1, d.apk2, d.message, d.signature).should.be.rejectedWith(h.EVMRevert);
        // bad apk2
        let badApk2 = [
          d.apk2[0],
          d.apk2[1],
          d.apk2[2],
          "0x4444444444444444444444444444444444444444444444444444444444444444"
        ];
        await mock.verify.estimateGas(d.apk1, badApk2, d.message, d.signature).should.be.rejectedWith(h.EVMRevert);
        // bad signature
        let basSignature = [d.signature[0], "0x4444444444444444444444444444444444444444444444444444444444444444"];
        await mock.verify.estimateGas(d.apk1, d.apk2, d.message, basSignature).should.be.rejectedWith(h.EVMRevert);

        // await mock.verify(d.apk1, d.apk2, d.message, d.signature).should.be.fulfilled
        // gas cost: 600000 - 650000
        let gasCost = await mock.verify.estimateGas(d.apk1, d.apk2, d.message, d.signature).should.be.fulfilled;
        console.log("  Gas cost: " + gasCost);
      });
    }
  });

  describe("> initialize", async () => {
    const epoch = new BN(40);
    const identities = [accounts[1], accounts[2]];
    const pubkeys = [
      [new BN(h.randHex(64), 16), new BN(h.randHex(64), 16)],
      [new BN(h.randHex(64), 16), new BN(h.randHex(64), 16)]
    ];
    it("init should failed by non-owner", async () => {
      const nonOwner = accounts[3];
      await this.idenaWorld
        .init(epoch, identities, pubkeys, {
          from: nonOwner
        })
        .should.be.rejectedWith(h.EVMRevert);
    });
    it("init should succ by owner", async () => {
      const owner = deployer;
      await this.idenaWorld.init(epoch, identities, pubkeys, {
        from: owner
      }).should.be.fulfilled;
    });
    it("check states after init", async () => {
      (await this.idenaWorld.initialized()).should.equal(true);
      (await this.idenaWorld.epoch()).should.eq.BN(epoch);
      (await this.idenaWorld.population()).should.eq.BN(new BN(identities.length));
      const cIdentities = await this.idenaWorld.identities();
      for (let i = 0; i < cIdentities.length; i++) {
        cIdentities[i].toLowerCase().should.equal(identities[i].toLowerCase());
        const cState = await this.idenaWorld.stateOf(identities[i]);
        // console.log(cState);
        cState.pubX.should.eq.BN(pubkeys[i][0]);
        cState.pubY.should.eq.BN(pubkeys[i][1]);
        (await this.idenaWorld.isIdentity(identities[i])).should.equal(true);
      }
    });
  });

  describe("> update", async () => {
    // todo
  });
});
