pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Pairing.sol";


contract IdenaWorldState is Ownable {
    using SafeMath for uint256;
    using Pairing for *;

    struct IdState {
        uint256 pubX;
        uint256 pubY;
    }

    uint256 private _epoch;
    // Identities of latest epoch, the array size only grows, size is controlled by _populcation
    // Newbie, Verified, Human are identities, while others(Unknown, Killed, Suspended, Candidate) are not
    // todo: consider to use linked list instead of array and map
    address[] private _identities;
    uint256 _population;
    // identity keys
    mapping(address => IdState) private _states;
    // state hash
    uint256 private _root;

    bool private _initialized;

    event Updated(uint256 epoch, uint256 population);

    constructor() public {}

    /**
     * @dev Initialize `epoch` and identities with pubkeys
     *
     * Emits an {Updated} event.
     */
    function init(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys
    ) public onlyOwner {
        require(!_initialized, "initialization can only be called once.");
        require(
            identities.length == pubkeys.length,
            "array length not match for identities and pubkeys."
        );

        _initialized = true;
        _epoch = epoch;
        address addr;
        uint256[2] memory pubkey;
        for (uint256 i = 0; i < identities.length; i++) {
            addr = identities[i];
            pubkey = pubkeys[i];
            require(_states[addr].pubX == 0, "duplicated identity");
            _states[addr] = IdState(pubkey[0], pubkey[1]);
            _identities.push(addr);
        }

        // todo: calculate root hash

        _population = _identities.length;
        emit Updated(_epoch, _population);
    }

    /**
     * @dev Update identities
     *
     * `identities` are the new identities.
     * `pubkeys` are the new pubkeys to add.
     * `removeFlags` are the indexes of identities to remove in previous state world.
     * `removeCount` is total count of pubkeys to remove in previous state world.
     * `signFlags` are the indexes of singers in previous state world.
     * `signature` is the signature of this update.
     * `apk2` is the aggregated G2 pubkeys.
     *
     * Emits an {Updated} event.
     */
    function update(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags,
        uint256 removeCount,
        bytes memory signFlags,
        uint256[2] memory signature,
        uint256[4] memory apk2
    ) public {
        require(_initialized, "contract has not initialized.");
        require(_epoch <= epoch, "epoch can not decrease");

        (uint256 count, Pairing.G1Point memory apk1) = buildAPK1(signFlags);
        // verify signature
        require(count > _identities.length.mul(2).div(3), "signature count less than 2/3");
        bytes memory m = prepareMsg(epoch, identities, pubkeys, removeFlags);
        verify(apk1, apk2, m, signature);

        // update _identities, _states, _population
        updateStates(identities, pubkeys, removeFlags, removeCount);

        if (epoch > _epoch) {
            _epoch = epoch;
        }
        emit Updated(_epoch, _population);
    }

    /**
     * @dev aggregate public keys in G1
     */
    function buildAPK1(bytes memory signFlags)
    internal
    view
    returns (uint256, Pairing.G1Point memory)
    {
        uint256 oldPop = _population;
        require(signFlags.length == (oldPop + 7) / 8, "invalid remove flags");
        bool success;
        uint256 count;
        uint256[4] memory apk;
        for (uint256 i = 0; i < oldPop; i++) {
            if (uint8(signFlags[i / 8]) & uint8(1 << (i % 8)) != 0) {
                count++;
                // aggregate pubkeys
                IdState storage state = _states[_identities[i]];
                if (apk[0] == 0) {
                    apk[0] = state.pubX;
                    apk[1] = state.pubY;
                } else {
                    apk[2] = state.pubX;
                    apk[3] = state.pubY;
                    // addPoints directly
                    assembly {
                        success := staticcall(not(0), 0x06, apk, 128, apk, 64)
                    }
                    require(success, "bn256 addition failed");
                }
            }
        }
        return (count, Pairing.G1Point(apk[0], apk[1]));
    }

    /**
     * @return the message to sign
     */
    function prepareMsg(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags
    ) internal view returns (bytes memory) {
        return abi.encode(_root, epoch, keccak256(removeFlags), identities, pubkeys);
    }

    /**
     * @dev Verify
     */
    function verify(
        Pairing.G1Point memory apk1,
        uint256[4] memory apk2,
        bytes memory m,
        uint256[2] memory signature
    ) internal view {
        Pairing.G2Point memory apk2Point = Pairing.G2Point(
            [apk2[0], apk2[1]],
            [apk2[2], apk2[3]]
        );
        Pairing.G1Point[] memory p1 = new Pairing.G1Point[](2);
        Pairing.G2Point[] memory p2 = new Pairing.G2Point[](2);
        // check apk2: e(apk1, g2) == e(g1, apk2)
        p1[0] = apk1;
        p2[0] = Pairing.g2();
        p1[1] = Pairing.g1();
        p2[1] = apk2Point;
        require(Pairing.check(p1, p2), "invalid apk2");

        // check signature: e(S, g2) == e(H(m), apk2)
        Pairing.G1Point memory sigPoint = Pairing.G1Point(
            signature[0],
            signature[1]
        );
        p1[0] = sigPoint;
        p2[0] = Pairing.g2();
        p1[1] = Pairing.hashToG1(m);
        p2[1] = apk2Point;
        require(Pairing.check(p1, p2), "invalid signature");
    }

    /**
     * @dev Update the world state of idena.
     */
    function updateStates(
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags,
        uint256 removeCount
    ) internal {
        require(identities.length == pubkeys.length, "array length not match");
        uint256 oldPop = _population;
        require(removeFlags.length == (oldPop + 7) / 8, "invalid remove flags");
        uint256 newPop = oldPop.sub(removeCount).add(identities.length);

        uint256[] memory moveIndexes;
        uint256 movePushed = 0;
        if (newPop < oldPop) {
            moveIndexes = new uint256[](oldPop - newPop);
        }

        uint8 rf;
        uint256 insertCount = 0;
        // used to check parameter removeCount
        uint256 realRemoved = 0;
        address addr;
        uint256[2] memory pubkey;
        for (uint256 i = 0; i < oldPop;) {
            rf = uint8(removeFlags[i / 8]);
            for (uint256 j = i + 8; i < j; i++) {
                if ((rf & 0x1 != 1)) {
                    realRemoved++;
                    // clear removed identity's state
                    delete _states[_identities[j]];
                    // insert or move
                    if (insertCount < identities.length) {
                        addr = identities[insertCount];
                        // insert new identity
                        pubkey = pubkeys[insertCount];
                        require(_states[addr].pubX == 0, "duplicated identity");
                        _states[addr] = IdState(pubkey[0], pubkey[1]);
                        _identities[i] = addr;
                        ++insertCount;
                    } else {
                        // save index to move
                        moveIndexes[movePushed] = i;
                        movePushed++;
                    }
                }
                rf >>= 1;
            }
        }
        require(realRemoved == removeCount, "wrong remove count supplied");

        // todo: if (insertCount < identities.length) {
        // todo: if movePushed > 0

        _population = newPop;
    }

    function initialized() public view returns (bool) {
        return _initialized;
    }

    function epoch() public view returns (uint256) {
        return _epoch;
    }

    function population() public view returns (uint256) {
        return _population;
    }

    function identities() public view returns (address[] memory) {
        address[] memory result = new address[](_population);
        for (uint256 i = 0; i < _population; i++) {
            result[i] = _identities[i];
        }
        return result;
    }

    function stateOf(address addr) public view returns (IdState memory) {
        return _states[addr];
    }

    function isIdentity(address addr) public view returns (bool) {
        return _states[addr].pubX != 0;
    }
}
