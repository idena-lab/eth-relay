pragma solidity >=0.5.8 <0.7.0;
pragma experimental ABIEncoderV2;

import "../../contracts/Pairing.sol";


contract PairingMock {
    function scalarMult(uint256[2] memory p, uint256 s)
        public
        view
        returns (Pairing.G1Point memory)
    {
        return Pairing.scalarMult(Pairing.G1Point(p[0], p[1]), s);
    }

    function check(
        uint256[2] memory a1,
        uint256[4] memory a2,
        uint256[2] memory b1,
        uint256[4] memory b2
    ) public view returns (bool) {
        return
            Pairing.check2(
                Pairing.G1Point(a1[0], a1[1]),
                Pairing.G2Point([a2[0], a2[1]], [a2[2], a2[3]]),
                Pairing.G1Point(b1[0], b1[1]),
                Pairing.G2Point([b2[0], b2[1]], [b2[2], b2[3]])
            );
    }
}
