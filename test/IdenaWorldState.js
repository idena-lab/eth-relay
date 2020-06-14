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

  describe("> verify", async () => {
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
        console.debug("Gas cost: " + gasCost);
      });
    }
  });

  // check state results
  const checkState = async checks => {
    (await this.idenaWorld.initialized()).should.equal(true);
    (await this.idenaWorld.height()).should.eq.BN(new BN(checks.height));
    (await this.idenaWorld.population()).should.eq.BN(new BN(checks.population));

    // first, middle, last
    let idAddrs = [
      await this.idenaWorld.identityByIndex(0),
      await this.idenaWorld.identityByIndex(Math.floor(checks.population / 2)),
      await this.idenaWorld.identityByIndex(checks.population - 1)
    ];
    let checkIds = [checks.firstId, checks.middleId, checks.lastId];
    for (let i = 0; i < checkIds.length; i++) {
      let addr = idAddrs[i].toLowerCase();
      addr.should.equal(checkIds[i].address);
      (await this.idenaWorld.isIdentity(addr)).should.equal(true);
      const st = await this.idenaWorld.stateOf(addr);
      // console.debug(st);
      st.pubX.should.eq.BN(new BN(checkIds[i].blsPub1[0].substr(2), 16));
      st.pubY.should.eq.BN(new BN(checkIds[i].blsPub1[1].substr(2), 16));
    }

    (await this.idenaWorld.root()).should.eq.BN(new BN(checks.root.substr(2), 16));
  };

  describe.only("> Initialization --------------------------------------------", async () => {
    const initData = stateData.init;
    const height = new BN(initData.height);
    it("init should failed by non-owner", async () => {
      const nonOwner = accounts[3];
      await this.idenaWorld
        .submitInitState(initData.identities, initData.blsPub1s.slice(0, 100), {
          from: nonOwner
        })
        .should.be.rejectedWith(h.EVMRevert);
      await this.idenaWorld
        .finishInit(height, initData.root, {
          from: nonOwner
        })
        .should.be.rejectedWith(h.EVMRevert);
    });

    // valid init
    describe(stateData.init.comment, async () => {
      const owner = deployer;
      // split data to call init
      const batchSize = 100;
      const total = initData.identities.length;
      let batch = 1;
      for (let i = 0; i < total; i += batchSize, batch++) {
        let size = i + batchSize > total ? total - i : batchSize;
        it(`Init batch ${batch}: submitting ${i + size}/${total} identities`, async () => {
          let tx = await this.idenaWorld.submitInitState(
            initData.identities.slice(i, i + size),
            initData.blsPub1s.slice(i, i + size),
            {
              from: owner
            }
          ).should.be.fulfilled;
          console.debug(`Gas cost: ${tx.receipt.cumulativeGasUsed}, tx: ${tx.tx}`);
          // let txInfo = await web3.eth.getTransaction(tx.tx);
          // console.debug(`Tx data: ${txInfo.input}`);
        });
      }
      it(`Finish init of block ${height} with root ${initData.root}`, async () => {
        let tx = await this.idenaWorld.finishInit(height, initData.root, { from: owner }).should.be.fulfilled;
        console.debug(`Gas cost: ${tx.receipt.cumulativeGasUsed}, tx: ${tx.tx}`);
        // let txInfo = await web3.eth.getTransaction(tx.tx);
        // console.debug(`Tx data: ${txInfo.input}`);
        await checkState(initData.checks);
      });
    });
  });

  describe.only("> Updates --------------------------------------------", async () => {
    // we can select sender randomly because anyone can call update
    const randSender = () => accounts[_.random(0, accounts.length - 1)];
    const data = stateData.updates;
    for (const [i, d] of data.entries()) {
      it(d.comment, async () => {
        const height = new BN(d.height);
        let p = this.idenaWorld.update(
          height,
          d.newIdentities,
          d.newBlsPub1s,
          d.removeFlags,
          d.removeCount,
          d.signFlags,
          d.signature,
          d.apk2,
          {
            from: randSender()
          }
        );
        if (d.checks.valid) {
          let tx = await p.should.be.fulfilled;
          console.debug(`Gas cost: ${tx.receipt.cumulativeGasUsed}, tx: ${tx.tx}`);
          // let txInfo = await web3.eth.getTransaction(tx.tx);
          // console.debug(`Tx data: ${txInfo.input}`);
        } else {
          let err = await p.should.be.rejectedWith(h.EVMRevert);
          console.log(`Reverted as expected, reason: ${err.reason}`);
        }
        await checkState(d.checks);
      });
    }
  });
});
