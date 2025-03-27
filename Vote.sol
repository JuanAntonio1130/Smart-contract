// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public admin;
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public authorizedVoters;
    Candidate[] public candidates;

    event CandidateAdded(string name);
    event VoterAuthorized(address voter);
    event Voted(address indexed voter, uint256 candidateIndex);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Seul l'admin peut executer cette action !");
        _;
    }

    constructor(string[] memory candidateNames) {
        admin = msg.sender;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidates.push(Candidate({name: _name, voteCount: 0}));
        emit CandidateAdded(_name);
    }

    function authorizeVoter(address _voter) public onlyAdmin {
        authorizedVoters[_voter] = true;
        emit VoterAuthorized(_voter);
    }

    function vote(uint _candidateIndex) public {
        require(authorizedVoters[msg.sender], "Vous n'etes pas autorise a voter !");
        require(!hasVoted[msg.sender], "Vous avez deja vote !");
        require(_candidateIndex < candidates.length, "Candidat invalide !");

        candidates[_candidateIndex].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _candidateIndex);
    }

    function getCandidatesCount() public view returns (uint) {
        return candidates.length;
    }

    function getVotes(uint _candidateIndex) public view returns (uint256) {
        require(_candidateIndex < candidates.length, "Candidat invalide !");
        return candidates[_candidateIndex].voteCount;
    }

    function getWinner() public view returns (string memory winnerName, uint256 winnerVotes) {
        require(candidates.length > 0, "Pas de candidats disponibles !");
        
        uint256 highestVotes = 0;
        uint256 winnerIndex = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > highestVotes) {
                highestVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
            // Note : En cas d'égalité, le premier candidat ajouté avec le plus de votes gagne.
        }

        return (candidates[winnerIndex].name, candidates[winnerIndex].voteCount);
    }
}
