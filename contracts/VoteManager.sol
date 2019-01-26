pragma solidity ^0.4.11;

import "./AuthenticationManager.sol";
import "./PartyManager.sol";
import "./VoterManager.sol";
import "./SafeMath.sol";

contract VoteManager {
    using SafeMath for uint256;
    
    /* Defines whether or not the  Voter Manager Contract address has yet been set.  */
    bool public voterManagerContractDefined = false;

    /* Defines whether or not the  Party Manager Contract address has yet been set.  */
    bool public partyManagerContractDefined = false;

    /* Defines whether or not we are in the Voting phase */
    bool public votingPhase = false;

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* Defines the voter contract we interface with for credentails. */
    VoterManager voterManager;

    /* Defines the party contract we interface with for credentails. */
    PartyManager partyManager;

    /* Defines our event fired when the Voting is closed */
    event VotingClosed();

    /* Defines our event fired when the Voting is reopened */
    event VotingStarted();


    /* Map votes to parties */
    mapping (string => int) votingResult;
    
    /* Ensures that once the Sale is over this contract cannot be used until the point it is destructed. */
    modifier onlyDuringVoting {

        if ( (!voterManagerContractDefined) || (!partyManagerContractDefined) || ( !votingPhase) ) revert();
        _;
    }

    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) revert();
        _;
    }

    /* This modifier allows a method to only be called by current voters */
    modifier voterOnly {
        if (!voterManager.isCurrentVoter(msg.sender)) revert();
        _;
    }

    /* Create the  vote manager and define the address of the main authentication Manager address. */
    function VoteManager(address _authenticationManagerAddress) {        
                
        /* Setup access to our authentication manager contracts */
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);
    }

    /* Set the VoterManager contract address as a one-time operation.  
     This happens after all the contracts are created and no other functionality can be used until this is set. */
    function setVoterManagerContractAddress(address _voterManagerContract) adminOnly {
        /* This can only happen once in the lifetime of this contract */
        if (voterManagerContractDefined)
            revert();

        /* Setup access to our voter manager */
        voterManager = VoterManager(_voterManagerContract);

        voterManagerContractDefined = true;
    }

    /* Set the Token contract address as a one-time operation.  This happens after all the contracts are created and no
       other functionality can be used until this is set. */
    function setPartyManagerContractDefined(address _partyManagerContract) adminOnly {
        /* This can only happen once in the lifetime of this contract */
        if (partyManagerContractDefined)
            revert();

        /* Setup access to our party manager */
        partyManager = PartyManager(_partyManagerContract);

        partyManagerContractDefined = true;
    }


    /* Handle receiving vote in voting phase */
    function vote(string _party) onlyDuringVoting voterOnly {

        require(validParty(_party));
        
        // apply vote logic here
        votingResult[_party] = ++votingResult[_party];
    }

    // @return true if the transaction can buy tokens
    function validParty(string _party) internal constant returns (bool) {

        // implement valid party implementation here
        bool isValidParty = partyManager.isCurrentParty(_party);
        return isValidParty;
    }

      /* Close the voting phase and transition to execution phase */
    function close() adminOnly onlyDuringVoting {

        // Close the Voting
        votingPhase = false;
        VotingClosed();

        // Withdraw funds if any to the caller
        // in case someone donated to the voting management
        if (!msg.sender.send(this.balance))
            revert();
    }

    /* Open the voting phase*/
    function openVoting() adminOnly {
        votingPhase = true;
        VotingStarted();
    }

    /* Check the results */
    function getVotes(string _party) constant returns (int) {
        return votingResult[_party];
    }
}