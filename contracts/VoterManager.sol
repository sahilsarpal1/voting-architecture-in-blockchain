pragma solidity ^0.4.11;

import "./AuthenticationManager.sol";

/* The voter manager details voters that have access to certain priviledges and keeps a permanent ledger of who has and has had these rights. */
contract VoterManager {
   
    /* Map addresses to voters */
    mapping (address => bool) voterAddresses;

    /* Details of all voters that have ever existed */
    address[] voterAudit;

    /* Fired whenever an voter is added to the contract. */
    event VoterAdded(address addedBy, address voter);

    /* Fired whenever an voter is removed to the contract. */
    event VoterRemoved(address addedBy, address voter);

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
        _;
    }

    /* Create the  voter manager and define the address of the main authentication Manager address. */
    function VoterManager(address _authenticationManagerAddress) {
        
        /* Setup access to our other contracts */
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);
    }

    /* Gets whether or not the specified address is currently an voter */
    function isCurrentVoter(address _address) constant returns (bool) {
        return voterAddresses[_address];
    }

    /* Gets whether or not the specified address has ever been an voter */
    function isCurrentOrPastVoter(address _address) constant returns (bool) {
        for (uint256 i = 0; i < voterAudit.length; i++)
            if (voterAudit[i] == _address)
                return true;
        return false;
    }

    /* Adds a voter to our list of voters */
    function addVoter(address _address) adminOnly {

        // Fail if this account is already voter
        if (voterAddresses[_address])
            revert();
        
        // Add the voter
        voterAddresses[_address] = true;
        VoterAdded(msg.sender, _address);
        voterAudit.length++;
        voterAudit[voterAudit.length - 1] = _address;
    }

    /* Removes a voter from our list of voters but keeps them in the history audit */
    function removeVoter(address _address) adminOnly {
        
        
        // Fail if this account is already non-voter
        if (!voterAddresses[_address])
            revert();

        /* Remove this voter user */
        voterAddresses[_address] = false;
        VoterRemoved(msg.sender, _address);
    }
}