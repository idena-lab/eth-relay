pragma solidity >=0.5.3 <0.7.0;


// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// More information at https://gist.github.com/chriseth/f9be9d9391efc5beb9704255a8e2989d

library Pairing {
    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256[2] x;
        uint256[2] y;
    }

    /**
     * @return the generator of G1
     */
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    /**
     * @return the generator of G2
     */
    function P2() internal pure returns (G2Point memory) {
        return
            G2Point(
                [
                    11559732032986387107991004021392285783925812861821192530917403151452391805634,
                    10857046999023057135944570762232829481370756359578518086990519993285655852781
                ],
                [
                    4082367875863433681332203403145435568316851327593401208105741076214120093531,
                    8495653923123431417604973247489272438418190587263600148770280649306958101930
                ]
            );
    }

    /**
     * @return the product of a point on G1 and a scalar, i.e.
     */
    function scalarMult(G1Point memory p, uint256 s)
        internal
        view
        returns (G1Point memory)
    {
        uint256[3] memory input;
        input[0] = p.x;
        input[1] = p.x;
        input[2] = s;
        bool success;
        G1Point memory result;
        assembly {
            // 0x07     id of precompiled bn256ScalarMul contract
            // 0        since we have an array of fixed length, our input starts in 0
            // 96       size of call parameters, i.e. 96 bytes total (256 bit for x, 256 bit for y, 256 bit for scalar)
            // 64       size of call return value, i.e. 64 bytes / 512 bit for a BN256 curve point
            success := staticcall(not(0), 0x07, input, 96, result, 64)
        }
        require(success, "elliptic curve multiplication failed");
        return result;
    }

    /**
     * @dev Checks if e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *
     * @return the result of computing the pairing check
     */
    function check(G1Point[] memory p1, G2Point[] memory p2)
        internal
        view
        returns (bool)
    {
        require(p1.length == p2.length, "EC pairing p1 length != p2 length");
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].x;
            input[i * 6 + 1] = p1[i].y;
            input[i * 6 + 2] = p2[i].x[0];
            input[i * 6 + 3] = p2[i].x[1];
            input[i * 6 + 4] = p2[i].y[0];
            input[i * 6 + 5] = p2[i].y[1];
        }
        uint256[1] memory out;
        uint256[1] memory result;
        bool success;
        assembly {
            // 0x08     id of precompiled bn256Pairing contract (checking the elliptic curve pairings)
            // add(input, 0x20) since we have an unbounded array, the first 256 bits refer to its length
            // mul(inputSize, 0x20) size of call parameters, each word is 0x20 bytes
            // 32       size of result (one 32 byte boolean!)
            success := staticcall(
                not(0),
                0x08,
                add(input, 0x20),
                mul(inputSize, 0x20),
                result,
                32
            )
        }
        require(success, "elliptic curve pairing failed");
        return result[0] == 1;
    }

    /**
     * @dev Convenience method for a pairing check for two pairs.
     */
    function check2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return check(p1, p2);
    }

    /**
     * @dev Convenience method for a pairing check for three pairs.
     */
    function check3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return check(p1, p2);
    }
}
