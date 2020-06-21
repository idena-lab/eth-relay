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

    struct StateKey {
        uint64 height;
        // the flow order index of the height, starting from 1
        uint32 flowId;
        address identity;
    }

    uint256 private _height;
    // state root hash
    uint256 private _root;
    // Newbie, Verified, Human are identities, while others(Unknown, Killed, Suspended, Candidate) are not
    StateKey[] private _identities;
    // identity => key of _allStates
    mapping(address => StateKey) private _validStates;
    // not all states in _allStates are valid
    // key => state, key = height(64bits) + flowId(32bits) + address
    mapping(uint256 => IdState) private _allStates;

    bool private _initialized;

    // FlowCache holds the data for update flow
    struct FlowData {
        bool verified;
        address creator;
        address[] newIdentities;
        bytes32 idHash;
        uint256 newRoot;
    }
    // height => FlowData[]
    mapping(uint256 => FlowData[]) private _updateFlows;
    struct Updating {
        // height is set to non-zero when flow verified and reset to zero after submission
        uint256 height;
        uint256 flowId;
        uint256 addCount;
        uint256 headPos;
        uint256 tailPos;
        bool waitFilling;
    }
    Updating private _updating;

    event PrepareUpdate(uint256 indexed height, uint256 flowId);
    event UpdateVerified(uint256 indexed height, uint256 flowId);
    event StateChanged(uint256 indexed height, uint256 population, uint256 root);

    constructor() public {}

    /**
     * @dev Submit initial identities
     *
     *  Due to the gas limitation, this function may require multiple calls to submit
     *  all data. During multiple submissions, the order of the identities and pubkeys
     *  must strictly match the original order in idena.
     *
     * `height` is the specific height of the initial state.
     * `identities` are the identities in idena relay state.
     * `pubkeys` are the G1 bls pubkeys matching the identities.
     */
    function prepareInit(
        uint256 height,
        address[] memory identities,
        uint256[2][] memory pubkeys
    ) public onlyOwner {
        require(!_initialized, "initialization can only be performed once.");
        require(identities.length == pubkeys.length, "array length not match for identities and pubkeys.");
        if (_height == 0) {
            _height = height;
        }
        require(_height == height, "height not match.");

        uint256 flowId = 1;
        uint256 keyPrefix = (height << 192) + (flowId << 160);
        uint256[2] memory pk;
        for (uint256 i = 0; i < identities.length; i++) {
            address addr = identities[i];
            uint256 key = keyPrefix + uint256(addr);
            pk = pubkeys[i];
            require(_allStates[key].pubX == 0, "duplicated identity");
            _allStates[key] = IdState(pk[0], pk[1]);
            StateKey memory sk = StateKey({ height: uint64(height), flowId: uint32(flowId), identity: addr });
            _identities.push(sk);
            _validStates[addr] = sk;
        }
    }

    /**
     * @dev End the initialization operation
     *
     *   After initialization, the contract's state of identities should be consistent
     *   with the idena blockchain state at `_height`.
     *
     * `root` is the relay-state root in idena blockchain.
     */
    function finishInit(uint256 root) public onlyOwner {
        require(!_initialized, "initialization can only be performed once.");
        _initialized = true;
        _root = root;
        emit StateChanged(_height, _identities.length, root);
    }

    /**
     * @dev Update state in one call when there is only little change.
     *
     * `height` is the idena blockchain height corresponding to this update.
     * `identities` are the new identities added.
     * `pubkeys` are the new bls pubkeys of the identities.
     * `removeFlags` are the indexes of identities to remove in previous state world.
     * `signFlags` are the indexes of singers in previous state world.
     * `signature` is the signature of this update.
     * `apk2` is the aggregated G2 pubkeys.
     *
     * Emits a {StateChanged} event if update successfully.
     */
    function quickUpdate(
        uint256 height,
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags,
        bytes memory signFlags,
        uint256[2] memory signature,
        uint256[4] memory apk2
    ) public {
        uint256 flowId = prepareUpdate(height, 0, identities, pubkeys);
        verifyUpdate(height, flowId, removeFlags, signFlags, signature, apk2);
        submitUpdate(height, flowId, removeFlags, 0);
    }

    /**
     * @dev Upload identities and save it to flow data first.
     *
     *  `prepareUpdate` must be called at least once regardless of whether there are new identities for a flow-way update.
     *  Anyone can create his own update flow for specific height by calling `prepareUpdate`.
     *  It can be called multiple times for one update flow by creator only.
     *  The data(identities, pubkeys) provided must in the original order during multiple calls.
     *
     * `height` is the idena blockchain height corresponding to this update.
     * `flowId` is the flow to operate. If it is 0 or flowLength+1, a new flow will be created.
     * `identities` are the new identities added.
     * `pubkeys` are the new bls pubkeys of the identities.
     *
     * Emits a {FlowCreated} event a new update flow is created.
     *
     * @return the flow id of this operation.
     */
    function prepareUpdate(
        uint256 height,
        uint256 flowId,
        address[] memory identities,
        uint256[2][] memory pubkeys
    ) public returns (uint256) {
        require(_initialized, "contract has not initialized.");
        require(height < (1 << 64), "invalid height");
        require(flowId < (1 << 32), "invalid flowId");
        require(identities.length == pubkeys.length, "array length not match");
        FlowData storage fd;
        if (flowId == 0 || flowId == _updateFlows[height].length + 1) {
            fd = _updateFlows[height].push();
            fd.creator = msg.sender;
            flowId = _updateFlows[height].length;
            emit PrepareUpdate(height, flowId);
        } else {
            fd = _updateFlows[height][flowId - 1];
            require(!fd.verified, "can not prepare after verification");
            require(fd.creator == msg.sender, "only the creator can prepare data to the flow");
        }
        bytes32 hIds = fd.idHash;
        uint256 keyPrefix = (height << 192) + (flowId << 160);
        uint256[2] memory pk;
        for (uint256 i = 0; i < identities.length; i++) {
            address addr = identities[i];
            pk = pubkeys[i];
            fd.newIdentities.push(addr);
            uint256 key = keyPrefix + uint256(addr);
            require(_allStates[key].pubX == 0, "duplicated identity");
            _allStates[key] = IdState(pk[0], pk[1]);
            hIds = keccak256(abi.encodePacked(hIds, addr, pk[0], pk[1]));
        }
        fd.idHash = hIds;
        return flowId;
    }

    /**
     * @dev Verify flow data for one update.
     *
     *  After preparing, verification is required to check the update flow is valid or not.
     *  Only the flow creator can call this function to make his update flow verified.
     *
     * `height` is the idena blockchain height corresponding to this update.
     * `flowId` is the flow to operate.
     * `removeFlags` are the indexes of identities to remove in previous state world.
     * `signFlags` are the indexes of singers in previous state world.
     * `signature` is the signature of this update.
     * `apk2` is the aggregated G2 pubkeys.
     *
     * Emits a {UpdateVerified} event.
     */
    function verifyUpdate(
        uint256 height,
        uint256 flowId,
        bytes memory removeFlags,
        bytes memory signFlags,
        uint256[2] memory signature,
        uint256[4] memory apk2
    ) public {
        require(_initialized, "contract has not initialized.");
        require(_updating.height == 0, "can not verify during updating");
        FlowData storage fd = _updateFlows[height][flowId - 1];
        require(!fd.verified, "this flow has already been verified");
        require(fd.creator == msg.sender, "only the creator can verify the flow");

        require(_height < height, "blockchain height must increase");
        uint256 oldPop = _identities.length;
        require(removeFlags.length == (oldPop + 7) / 8, "invalid remove flags");

        (uint256 count, Pairing.G1Point memory apk1) = _buildAPK1(signFlags);
        // verify signature
        require(count > oldPop.mul(2).div(3), "not enough signatures");
        fd.newRoot = uint256(keccak256(abi.encodePacked(_root, height, fd.idHash, keccak256(removeFlags))));
        _verify(apk1, apk2, abi.encodePacked(fd.newRoot), signature);

        fd.verified = true;
        _updating = Updating({
            height: height,
            flowId: flowId,
            addCount: 0,
            headPos: 0,
            tailPos: oldPop - 1,
            waitFilling: false
        });
        emit UpdateVerified(height, flowId);
    }

    /**
     * @dev Submit update data to state
     *
     * Anyone can call this function to submit the update flow after verification, not just the flow creator.
     *
     * `height` is the idena blockchain height corresponding to this update.
     * `flowId` is the flow to operate.
     * `removeFlags` are the indexes of identities to remove in previous state world.
     * `reserveGas` is the amount of gas reserved to prevent the transaction beging reverted with out-of-gas.
     *    When gas is close to the reserved value, it will stop continuing to submit and save the state.
     *
     * Emits a {StateChanged} event if update successfully.
     */
    function submitUpdate(
        uint256 height,
        uint256 flowId,
        bytes memory removeFlags,
        uint256 reserveGas
    ) public {
        require(_updating.height > 0, "not updating period");
        require(_updating.height == height && _updating.flowId == flowId, "flow not match");
        FlowData storage fd = _updateFlows[height][flowId - 1];
        // this should never happen
        require(fd.verified, "flow has not been verified");

        Updating memory u = _updating;
        // uint256 keyPrefix = (height << 192) + (flowId << 160);

        // used to check parameter removeCount
        uint256 totalAdd = fd.newIdentities.length;
        while (u.headPos <= u.tailPos && gasleft() > reserveGas) {
            if (!u.waitFilling) {
                uint8 flag = (uint8(removeFlags[u.headPos / 8]) & uint8(0x1 << (u.headPos % 8)));
                if (flag == 0) {
                    u.headPos++;
                    continue;
                }
                address rmAddr = _identities[u.headPos].identity;
                u.waitFilling = true;
                delete _validStates[rmAddr];
                // todo: delete _allStates[key] or save as gas token
            }
            // filling removed slot
            if (u.addCount < totalAdd) {
                // insert
                address addr = fd.newIdentities[u.addCount];
                StateKey memory stateKey = StateKey({ height: uint64(height), flowId: uint32(flowId), identity: addr });
                _identities[u.headPos] = stateKey;
                _validStates[addr] = stateKey;
                u.addCount++;
                u.headPos++;
                u.waitFilling = false;
            } else {
                uint8 flag = uint8(removeFlags[u.tailPos / 8]) & uint8(0x1 << (u.tailPos % 8));
                if (flag == 0) {
                    // move to fill
                    _identities[u.headPos] = _identities[u.tailPos];
                    u.headPos++;
                    u.waitFilling = false;
                }
                u.tailPos--;
                _identities.pop();
            }
        }
        if (u.headPos > u.tailPos) {
            // try append remaining new identities to end
            while (u.addCount < totalAdd && gasleft() > reserveGas) {
                address addr = fd.newIdentities[u.addCount];
                StateKey memory stateKey = StateKey({ height: uint64(height), flowId: uint32(flowId), identity: addr });
                _identities.push(stateKey);
                _validStates[addr] = stateKey;
                u.addCount++;
            }
        }

        if (u.headPos > u.tailPos && u.addCount >= totalAdd) {
            // submit finished
            _height = height;
            u.height = 0;
            _updating.height = 0;
            _root = fd.newRoot;
            emit StateChanged(height, _identities.length, _root);
        } else {
            _updating = u;
        }
    }

    /**
     * @dev aggregate public keys in G1
     * 
     * `signFlags` are the indexes of singers in previous state world.
     * 
     * @return number of signers and the aggregated public keys
     */
    function _buildAPK1(bytes memory signFlags) internal view returns (uint256, Pairing.G1Point memory) {
        uint256 oldPop = _identities.length;
        require(signFlags.length == (oldPop + 7) / 8, "invalid sign flags");
        bool success;
        uint256 count;
        uint256[4] memory apk;
        for (uint256 i = 0; i < oldPop; i++) {
            if (uint8(signFlags[i / 8]) & uint8(1 << (i % 8)) != 0) {
                count++;
                // aggregate pubkeys
                uint256 key = buildStateKey(_identities[i]);
                IdState storage state = _allStates[key];
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
     * @dev Verify keys and signatures
     */
    function _verify(
        Pairing.G1Point memory apk1,
        uint256[4] memory apk2,
        bytes memory m,
        uint256[2] memory signature
    ) internal view {
        Pairing.G2Point memory apk2Point = Pairing.G2Point([apk2[0], apk2[1]], [apk2[2], apk2[3]]);
        Pairing.G1Point[] memory p1 = new Pairing.G1Point[](2);
        Pairing.G2Point[] memory p2 = new Pairing.G2Point[](2);
        // check apk2: e(apk1, g2) == e(g1, apk2)
        p1[0] = apk1;
        p2[0] = Pairing.g2();
        p1[1] = Pairing.g1();
        p2[1] = apk2Point;
        require(Pairing.check(p1, p2), "validate apk2 failed");

        // check signature: e(S, g2) == e(H(m), apk2)
        Pairing.G1Point memory sigPoint = Pairing.G1Point(signature[0], signature[1]);
        p1[0] = sigPoint;
        p2[0] = Pairing.g2();
        p1[1] = Pairing.hashToG1(m);
        p2[1] = apk2Point;
        require(Pairing.check(p1, p2), "validate signature failed");
    }

    function initialized() public view returns (bool) {
        return _initialized;
    }

    function isUpdating() public view returns (bool) {
        return _updating.height > 0;
    }

    function updatingInfo() public view returns (Updating memory) {
        return _updating;
    }

    function getFlowData(uint256 height, uint256 flowId) public view returns (FlowData memory) {
        return _updateFlows[height][flowId - 1];
    }

    function root() public view returns (uint256, bool) {
        return (_root, isUpdating());
    }

    function height() public view returns (uint256, bool) {
        return (_height, isUpdating());
    }

    function population() public view returns (uint256, bool) {
        return (_identities.length, isUpdating());
    }

    function identities(bool canUpdating) public view returns (address[] memory, bool) {
        bool updating = isUpdating();
        if (updating && !canUpdating) {
            return (new address[](0), updating);
        }
        uint256 pop = _identities.length;
        address[] memory result = new address[](pop);
        for (uint256 i = 0; i < pop; i++) {
            result[i] = _identities[i].identity;
        }
        return (result, updating);
    }

    function identityByIndex(uint256 i) public view returns (address, bool) {
        return (_identities[i].identity, isUpdating());
    }

    function stateOf(address addr) public view returns (IdState memory, bool) {
        uint256 key = buildStateKey(_validStates[addr]);
        return (_allStates[key], isUpdating());
    }

    function isIdentity(address addr) public view returns (bool, bool) {
        uint256 key = buildStateKey(_validStates[addr]);
        return (_allStates[key].pubX != 0, isUpdating());
    }

    function buildStateKey(StateKey memory sk) public pure returns (uint256) {
        return (uint256(sk.height) << 192) + (uint256(sk.flowId) << 160) + uint256(sk.identity);
    }
}
