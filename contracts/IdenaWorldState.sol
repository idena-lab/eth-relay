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
    address[] private _identities;
    uint256 _population;
    // identity keys
    mapping(address => IdState) private _states;
    // prev state hash
    uint256 private _root;

    bool private _initialized;

    event NewEpoch(uint256 epoch, uint256 population);

    constructor() public {}

    /**
     * @dev Initialize `epoch` and identities with pubkeys
     *
     * Emits a {NewEpoch} event.
     */
    function init(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys
    ) public onlyOwner {
        require(!_initialized, "Initialization can only be called once.");
        require(
            identities.length == pubkeys.length,
            "Array length not match for identities and pubkeys."
        );

        _initialized = true;
        _epoch = epoch;
        address addr;
        uint256[2] memory pubkey;
        for (uint256 i = 0; i < identities.length; i++) {
            addr = identities[i];
            pubkey = pubkeys[i];
            require(_states[addr].pubX == 0, "Duplicated identity");
            _states[addr] = IdState(pubkey[0], pubkey[1]);
            _identities.push(addr);
        }

        // todo: calculate root hash

        _population = _identities.length;
        emit NewEpoch(_epoch, _population);
    }

    /**
     * @dev Update identities
     *
     * `identities` are the new identities.
     * `removeflags` are the indexes of identities to remove in previous state world.
     * `signflags` are the indexes of singers in previous state world.
     * 
     * Emits a {NewEpoch} event if the epoch increases.
     */
    function update(
        uint256 epoch,
        address[] memory identities,
        uint256[2][] memory pubkeys,
        bytes memory removeFlags,
        bytes memory signFlags,
        uint256[4] memory signature
    ) public {
        require(
            identities.length == pubkeys.length,
            "Array length not match"
        );
        require(_epoch <= epoch, "epoch can not decrease");

        address addr;
        uint256[2] memory pubkey;
        for (uint256 i = 0; i < identities.length; i++) {
            addr = identities[i];
            pubkey = pubkeys[i];
            require(_states[addr].pubX == 0, "Duplicated identity");
            _states[addr] = IdState(pubkey[0], pubkey[1]);
            _identities.push(addr);
        }

        // todo: calculate root hash

        // todo: check signature satisfy the 2/3

        // todo: update _identities, _states, _population

        if (epoch > _epoch) {
            _epoch = epoch;
            emit NewEpoch(_epoch, _population);
        }
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
