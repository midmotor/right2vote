// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0; //version of solidity

contract Ballot {
   
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson; //adress of chairperson, public meaning that i can view this variable both within 
                                //the contract as well as from outside the contract

    mapping(address => Voter) public voters; //we have a voters variable and the key of the voter is going to be the adress
                                             //and the values is going to be voter
    Proposal[] public proposals;


    constructor(bytes32[] memory proposalNames) { //initial state of the contract
        chairperson = msg.sender;
        voters[chairperson].weight = 1;  

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    
    function giveRightToVote(address voter) public {// as an admin or as a chairperson we want to pass in an address and let them right to vote
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted, //make sure that voter.voted boolean is false  (the initialize value of boolean is false)
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function givevotearray(address[] memory a) public {
    
        for(uint i=0; i< a.length; i++) {
            giveRightToVote(a[i]);
        }
    }
  
    function delegate(address to) public { //to delegate your vote
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) { // If the delegate already voted, directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;

        } else { // If the delegate did not vote yet,  add to her weight.
           
            delegate_.weight += sender.weight;
        }
    }

    
    function vote(uint proposal) public { //Give your vote
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

   
    function winningProposal() public view //to get the index of the winner contained in the proposals array 
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }


    function winnerName() public view //the name of the winner
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}
