// SPDX-License-Identifier: MIT




pragma solidity ^0.8.26;




contract Vote {


    struct Voter {
        string name;
        uint age;
        Gender gender;
        uint voterId;
        uint voteCandidateId;
        address voterAddress;
    }


    struct Candidate {
        string name;
        string party;
        uint age;
        Gender gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }


    address electionCommission;
    string public winner;
    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;
    uint endTime;
    bool stopVoting;


    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;


    enum VotingStatus {NotStarted, InProgress, Ended}
    enum Gender {NotSpecified, Male, Female, Other}


    constructor() {
        electionCommission=msg.sender;
    }


    modifier isVotingOver() {
        require(block.timestamp < endTime && stopVoting==false,"Voting Over");
      _;
    }


    modifier onlyCommissioner() {
        require(msg.sender==electionCommission,"Not Authorized");
        _;
    }


    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    ) external {
        require(isCandidateNotRegistered(msg.sender),"Already Registered");
        require(_age>=18,"Under Age");
        require(msg.sender!=electionCommission,"Not Allowed");
        candidateDetails[nextCandidateId]=Candidate(_name,_party,_age,_gender,nextCandidateId,msg.sender,0);
        nextCandidateId++;
    }


    function isCandidateNotRegistered(address _person) internal view returns (bool) {
           for(uint i=1;i<nextCandidateId;i++){
                if(candidateDetails[i].candidateAddress==_person){
                    return false;
                }
           }
           return true;
    }


    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](nextCandidateId-1);
        for(uint i=0;i<candidateList.length;i++){
            candidateList[i]=candidateDetails[i+1];
        }
        return candidateList;
    }


    function isVoterNotRegistered(address _person) internal view returns (bool) {
            for(uint i=1;i<nextCandidateId;i++){
                if(voterDetails[i].voterAddress==_person){
                    return false;
                }
           }
           return true;
    }


    function registerVoter(
        string calldata _name,
        uint _age,
        Gender _gender
    ) external {
        require(isVoterNotRegistered(msg.sender),"Already Registered");
        require(_age>=18,"Under Age");
        voterDetails[nextVoterId]=Voter(_name,_age,_gender,nextVoterId,0,msg.sender);
        nextVoterId++;
    }


    function getVoterList() public view returns (Voter[] memory) {
        Voter[] memory VoterList = new Voter[](nextCandidateId-1);
        for(uint i=0;i<VoterList.length;i++){
            VoterList[i]=voterDetails[i+1];
        }
        return VoterList;
    }


    function castVote(uint _voterId, uint _id) external {
        require(voterDetails[_voterId].voteCandidateId==0,"Already Voted");
        require(voterDetails[_voterId].voterAddress==msg.sender,"Not Authorized");
        require(startTime<=block.timestamp,"Voting has not Staerted Yet");
        require(_id>0,"Not Registered");
        voterDetails[_voterId].voteCandidateId=_id;
        candidateDetails[_id].votes++;
    }


    function setVotingPeriod(uint _startTime, uint _endTime) external onlyCommissioner() {
        require(_startTime<_endTime,"Voting Time Error");
        startTime=block.timestamp+_startTime;
        endTime=startTime+_endTime;
    }


    function getVotingStatus() public view returns (VotingStatus) {
        if(startTime==0) return VotingStatus.NotStarted;
        else if(endTime>block.timestamp && stopVoting==false) return VotingStatus.InProgress;
        else return VotingStatus.Ended;
    }


    function announceVotingResult() external onlyCommissioner() {
        uint max=0;
        for(uint i=0;i<nextCandidateId-1;i++){
            if(candidateDetails[i].votes>max){
                max=candidateDetails[i].votes;
                winner=candidateDetails[i].name;
            }
        }
        stopVoting=true;
    }


    function emergencyStopVoting() public onlyCommissioner() {
       stopVoting=true;
    }
}












