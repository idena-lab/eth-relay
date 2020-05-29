const h = require("./helper")
const BN = require("bn.js")

const PairingMock = artifacts.require("PairingMock")
const data = require("./data/Pairing.json")

contract("Pairing", (accounts) => {
  let pairing

  before(async () => {
    pairing = await PairingMock.new()
  })

  describe("> multiplication", async () => {
    for (const [i, d] of data.multiplication.valid.entries()) {
      it(`should scalarMult G1 point (${i + 1})`, async () => {
        const ret = await pairing.scalarMult.call([d.input.x,
          d.input.y
        ], d.input.k)
        ret.x.should.eq.BN(new BN(d.output.x.substr(2), 16))
        ret.y.should.eq.BN(new BN(d.output.y.substr(2), 16))
      })
    }
  })

  describe("> pairing", async () => {
    for (const [i, d] of data.pairing.valid.entries()) {
      it(`check pairing (${i + 1})`, async () => {
        const ret = await pairing.check.call([d.input.x1_g1,
          d.input.y1_g1
        ], [d.input.x1_re_g2,
          d.input.x1_im_g2,
          d.input.y1_re_g2,
          d.input.y1_im_g2
        ], [d.input.x2_g1,
          d.input.y2_g1
        ], [d.input.x2_re_g2,
          d.input.x2_im_g2,
          d.input.y2_re_g2,
          d.input.y2_im_g2
        ])
        ret.should.equal(d.output.success)
      })
    }
  })
})
