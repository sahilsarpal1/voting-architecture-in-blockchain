pragma solidity ^0.4.11;

contract TestVote {

    /* Map votes to parties */
    mapping (string => int) votingResult;
    
    /* Create the  vote manager and define the address of the main authentication Manager address. */
    function TestVote() {}

    /* Handle receiving vote in voting phase */
    function vote(string _party) {
        
        // apply vote logic here
        votingResult[_party] = votingResult[_party]++;
    }
    
    /* Check the results */
    function getVotes(string _party) constant returns (int) {
        return votingResult[_party];
    }
}