const chai = require("chai");
const BN = require("bn.js");
const bnChai = require("bn-chai");
const _ = require("lodash");

const HexChars = "0123456789ABCDEF";

module.exports = {
  EVMRevert: "revert",
  EVMThrow: "invalid opcode",
  ether: function(x) {
    return new BN(web3.utils.toWei(x, "ether"));
  },
  should: chai
    .use(bnChai(BN))
    .use(require("chai-as-promised"))
    .should(),
  randHex: len => {
    let ret = "";
    for (let i = 0; i < len; ++i) {
      ret += HexChars[_.random(0, HexChars.length - 1)];
    }
    return ret;
  },
  logTx: async (tx, prefix) => {
    console.info(`${prefix} Gas cost: ${tx.receipt.cumulativeGasUsed}, tx: ${tx.tx}`);
    // let txInfo = await web3.eth.getTransaction(tx.tx);
    // console.log(txInfo);
    // console.debug(`Tx data: ${txInfo.input}`);
  }
};
