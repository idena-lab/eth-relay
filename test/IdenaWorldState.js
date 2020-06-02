const h = require("./helper");
const BN = require("bn.js");

const IdenaWorldState = artifacts.require("IdenaWorldState");
const IdenaWorldStateMock = artifacts.require("IdenaWorldStateMock");
const verifyData = require("./data/verify.json");
const stateData = require("./data/state.json");

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

  describe.skip("> verify", async () => {
    for (const [i, d] of verifyData.cases.entries()) {
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

  const checkState = async checks => {
    (await this.idenaWorld.initialized()).should.equal(true);
    (await this.idenaWorld.epoch()).should.eq.BN(new BN(checks.epoch));
    (await this.idenaWorld.population()).should.eq.BN(new BN(checks.population));

    // first, middle, last
    let idAddrs = [
      await this.idenaWorld.identityByIndex(0),
      await this.idenaWorld.identityByIndex(checks.population / 2),
      await this.idenaWorld.identityByIndex(checks.population - 1)
    ];
    let checkIds = [checks.firstId, checks.middleId, checks.lastId];
    for (let i = 0; i < checkIds.length; i++) {
      let addr = idAddrs[i].toLowerCase();
      addr.should.equal(checkIds[i].address);
      (await this.idenaWorld.isIdentity(addr)).should.equal(true);
      const st = await this.idenaWorld.stateOf(addr);
      // console.log(st);
      st.pubX.should.eq.BN(new BN(checkIds[i].pubKey[0].substr(2), 16));
      st.pubY.should.eq.BN(new BN(checkIds[i].pubKey[1].substr(2), 16));
    }

    (await this.idenaWorld.root()).should.eq.BN(new BN(checks.root.substr(2), 16));
  };

  describe.only("> initialize", async () => {
    const initData = stateData.init;
    const epoch = new BN(initData.epoch);
    it("init should failed by non-owner", async () => {
      const nonOwner = accounts[3];
      await this.idenaWorld
        .init(epoch, initData.identities, initData.pubKeys, {
          from: nonOwner
        })
        .should.be.rejectedWith(h.EVMRevert);
    });
    it(stateData.init.comment, async () => {
      const owner = deployer;
      let tx = await this.idenaWorld.init(epoch, initData.identities, initData.pubKeys, {
        from: owner
      }).should.be.fulfilled;
      console.log(`Gas used: ${tx.receipt.cumulativeGasUsed}, tx: ${tx.tx}`);
      await checkState(initData.checks);
    });
  });

  describe("> update", async () => {
    // todo
  });
});
