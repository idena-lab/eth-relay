pragma solidity >=0.4.25 <0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract IdenaWorldState is Ownable {
    using SafeMath for uint256;

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
     * Emits a {Updated} event.
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
     * `removeflags` are the indexes of identities to remove in previous state world.
     * `signflags` are the indexes of singers in previous state world.
     *
     * Emits a {Updated} event.
     */
    function update(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags,
        bytes memory signFlags,
        uint256 removeCount,
        uint256[4] memory signature
    ) public {
        require(_epoch <= epoch, "epoch can not decrease");

        (uint256 count, uint256[2] memory apk) = buildAPK(signFlags);
        // verify signature
        require(
            count > _identities.length.mul(2).div(3),
            "signature count less than 2/3"
        );
        bytes32 hm = prepareHash(epoch, identities, pubkeys, removeFlags);
        require(verify(apk, uint256(hm), signature), "invalid signature");

        // update _identities, _states, _population
        updateStates(identities, pubkeys, removeFlags, removeCount);

        if (epoch > _epoch) {
            _epoch = epoch;
        }
        emit Updated(_epoch, _population);
    }

    function buildAPK(bytes memory signFlags)
        internal
        returns (uint256, uint256[2] memory)
    {
        uint256 pop = _population;
        require(signFlags.length == (pop + 7) / 8, "invalid remove flags");
        uint8 sf;
        bool success;
        uint256 count;
        uint256[4] memory apk;
        for (uint256 i = 0; i < pop; ) {
            sf = uint8(signFlags[i / 8]);
            for (uint256 j = i + 8; i < j; i++) {
                if ((sf & 0x1) == 1) {
                    count++;
                    // aggregate signers
                    IdState storage state = _states[_identities[j]];
                    if (apk[0] == 0) {
                        apk[0] = state.pubX;
                        apk[1] = state.pubY;
                    } else {
                        apk[2] = state.pubX;
                        apk[3] = state.pubY;
                        assembly {
                            success := call(not(0), 0x06, 0, apk, 128, apk, 64)
                        }
                        require(success, "bn256 addition failed");
                    }
                }
                sf >>= 1;
            }
        }
        return (count, [apk[0], apk[1]]);
    }

    function prepareHash(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags
    ) internal returns (bytes32) {
        // todo: use better encoding?
        return
            keccak256(
                abi.encode(
                    _root,
                    keccak256(bytes32(epoch)),
                    keccak256(removeFlags),
                    identities,
                    pubkeys
                )
            );
    }

    function verify(
        uint256[2] memory apk,
        uint256 hm,
        uint256[4] memory signature
    ) public pure returns (bool) {
        //todo:
        return true;
    }

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
        for (uint256 i = 0; i < oldPop; ) {
            rf = uint8(removeFlags[i / 8]);
            for (uint256 j = i + 8; i < j; i++) {
                if ((rf & 0x1 == 1)) {
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

        for (uint256 i = 0; i < identities.length; i++) {
            addr = identities[i];
            pubkey = pubkeys[i];
            require(_states[addr].pubX == 0, "duplicated identity");
            _states[addr] = IdState(pubkey[0], pubkey[1]);
            _identities.push(addr);
        }

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
