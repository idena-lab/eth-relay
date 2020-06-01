pragma solidity >=0.5.8 <0.7.0;
pragma experimental ABIEncoderV2;

import "../../contracts/IdenaWorldState.sol";
import "../../contracts/Pairing.sol";


contract IdenaWorldStateMock is IdenaWorldState {
	function verify(
		uint256[2] memory apk1,
		uint256[4] memory apk2,
		string memory m,
		uint256[2] memory signature
	) public view {
		IdenaWorldState._verify(Pairing.G1Point(apk1[0], apk1[1]), apk2, bytes(m), signature);
	}
}
