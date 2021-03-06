pragma solidity ^0.4.18;
import "./interfaces/IProxyStorage.sol";
import "./interfaces/IPoaNetworkConsensus.sol";

contract ProxyStorage is IProxyStorage {
    address poaConsensus;
    address keysManager;
    address votingToChangeKeys;
    address votingToChangeMinThreshold;
    address votingToChangeProxy;
    address ballotsStorage;
    bool public mocInitialized;
    uint8 public contractVersion = 1;

    enum ContractTypes {
        Invalid,
        KeysManager,
        VotingToChangeKeys,
        VotingToChangeMinThreshold,
        VotingToChangeProxy,
        BallotsStorage, 
        PoaConsensus
    }

    event ProxyInitialized(
        address keysManager,
        address votingToChangeKeys,
        address votingToChangeMinThreshold,
        address votingToChangeProxy,
        address ballotsStorage);

    event AddressSet(uint256 contractType, address contractAddress);

    modifier onlyVotingToChangeProxy() {
        require(msg.sender == votingToChangeProxy);
        _;
    }

    function ProxyStorage(address _poaConsensus) public {
        poaConsensus = _poaConsensus;
    }

    function getKeysManager() public view returns(address) {
        return keysManager;
    }

    function getVotingToChangeKeys() public view returns(address) {
        return votingToChangeKeys;
    }

    function getVotingToChangeMinThreshold() public view returns(address) {
        return votingToChangeMinThreshold;
    }

    function getVotingToChangeProxy() public view returns(address) {
        return votingToChangeProxy;
    }

    function getPoaConsensus() public view returns(address) {
        return poaConsensus;
    }

    function getBallotsStorage() public view returns(address) {
        return ballotsStorage;
    }

    function initializeAddresses(
        address _keysManager,
        address _votingToChangeKeys,
        address _votingToChangeMinThreshold,
        address _votingToChangeProxy,
        address _ballotsStorage
    ) public 
    {
        require(isValidator(msg.sender));
        require(!mocInitialized);
        keysManager = _keysManager;
        votingToChangeKeys = _votingToChangeKeys;
        votingToChangeMinThreshold = _votingToChangeMinThreshold;
        votingToChangeProxy = _votingToChangeProxy;
        ballotsStorage = _ballotsStorage;
        mocInitialized = true;
        ProxyInitialized(
            keysManager,
            votingToChangeKeys,
            votingToChangeMinThreshold,
            votingToChangeProxy,
            ballotsStorage);
    }

    function setContractAddress(uint256 _contractType, address _contractAddress) public onlyVotingToChangeProxy {
        require(_contractAddress != address(0));
        if (_contractType == uint8(ContractTypes.KeysManager)) {
            keysManager = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.VotingToChangeKeys)) {
            votingToChangeKeys = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.VotingToChangeMinThreshold)) {
            votingToChangeMinThreshold = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.VotingToChangeProxy)) {
            votingToChangeProxy = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.BallotsStorage)) {
            ballotsStorage = _contractAddress;
        } else if (_contractType == uint8(ContractTypes.PoaConsensus)) {
            poaConsensus = _contractAddress;
        }
        AddressSet(_contractType, _contractAddress);
    }

    function isValidator(address _validator) public view returns(bool) {
        IPoaNetworkConsensus poa = IPoaNetworkConsensus(poaConsensus);
        return poa.isValidator(_validator);
    }
}