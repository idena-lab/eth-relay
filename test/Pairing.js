const h = require("./helper")
const BN = require("bn.js")

const PairingMock = artifacts.require("PairingMock")
const pairingData = require("./data/Pairing.json")

contract("Pairing", (accounts) => {
  let pairing

  before(async () => {
    pairing = await PairingMock.new()
  })

  describe("> multiplication", async () => {
    for (const [i, d] of pairingData.multiplication.valid.entries()) {
      it(`should scalarMult G1 point (${i + 1})`, async () => {
        const ret = await pairing.scalarMult.call([d.input.x,
          d.input.y
        ], d.input.k)
        ret.x.should.eq.BN(new BN(d.output.x.substr(2), 16))
        ret.y.should.eq.BN(new BN(d.output.y.substr(2), 16))
      })
    }
  })

  describe("> hashToG1", async () => {
    for (const [i, d] of pairingData.hashToG1.valid.entries()) {
      it(`check hash (${i + 1})`, async () => {
        const ret = await pairing.hashToG1.call(d.input)
        ret.x.should.eq.BN(new BN(d.output.x.substr(2), 16))
        ret.y.should.eq.BN(new BN(d.output.y.substr(2), 16))
      })
    }
  })

  describe("> pairing", async () => {
    for (const [i, d] of pairingData.pairing.valid.entries()) {
      it(`check pairing (${i + 1})`, async () => {
        let pl = d.input.points
        const ret = await pairing.check2.call(pl.slice(0, 2), pl.slice(2, 6), pl.slice(6, 8), pl.slice(8))
        // console.log(ret)
        ret.should.equal(d.output.success)
      })
    }
  })
})
