pragma solidity ^0.4.11;

/* The party manager details parties that have access to certain priviledges and keeps a permanent ledger of who has and has had these rights. */
contract PartyManager {
   
    /* Map name of party to parties */
    mapping (string => bool) parties;

    /* Details of all parties that have ever existed */
    address[] partyAudit;

    /* Fired whenever an party is added to the contract. */
    event partyAdded(address addedBy, string party);

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) revert();
        _;
    }

    /* Create the  party manager and define the address of the main authentication Manager address. */
    PartyManager(address _authenticationManagerAddress) {
        
        /* Setup access to our other contracts */
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);
    }

    /* Gets whether or not the specified name is currently an party */
    function isCurrentParty(string _party) constant returns (bool) {
        return parties[_party];
    }

    /* Gets whether or not the specified party has ever been an valid party */
    function isCurrentOrPastParty(string _party) constant returns (bool) {
        for (uint256 i = 0; i < partyAudit.length; i++)
            if (partyAudit[i] == _party)
                return true;
        return false;
    }

    /* Adds a party to our list of parties */
    function addParty(string _party) adminOnly {

        // Fail if this account is already party
        if (parties[_add_partyress])
            revert();
        
        // Add the party
        parties[_party] = true;
        partyAdded(msg.sender, _party);
        partyAudit.length++;
        partyAudit[partyAudit.length - 1] = _party;
    }

    /* Removes a party from our list of parties but keeps them in the history audit */
    function removeparty(string _party) adminOnly {
                
        // Fail if this account is already non-party
        if (!parties[_party])
            revert();

        /* Remove this party user */
        parties[_party] = false;
        partyRemoved(msg.sender, _party);
    }
}