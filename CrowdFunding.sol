// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.7.0 <= 0.9.0;

contract CrowdFunding{
    struct Request{
        string description;
        uint value;
        address payable recipient;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(address=>uint) public contributors;
    mapping(uint=>Request) public requests;
    uint public numRequests;
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public traget;
    uint public noOfContributors;
    uint public raisedAmt;

    constructor(uint _target, uint _deadline){
        traget = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        manager = msg.sender;     
    }
    modifier onlyManager(){
        require(msg.sender == manager,'Only manager can call this function');
        _;
    }
    function createRequest(string calldata _description, address payable _recipient, uint _value) public onlyManager {
       Request storage newRequest = requests[numRequests];
       numRequests++;
       newRequest.description = _description;
       newRequest.recipient = _recipient;
       newRequest.value = _value;
        newRequest.completed = false;
      newRequest.noOfVoters = 0;
    }
    function contribution() public payable{
        require(block.timestamp < deadline, 'Deadline has passed'); 
        require(msg.value >=minContribution, "Minimum Contribution not met");

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmt+=msg.value;
    }
    function getContractBalance()public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp > deadline && raisedAmt < traget, 'Cannot refund now');
        require(contributors[msg.sender] > 0 ,'You str not elgiible for refund');
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    function voteRequest(uint _reqNo) public{
       require(contributors[msg.sender] > 0 , 'You are not a contributor');
       Request storage thisRequest = requests[_reqNo];
       require(thisRequest.voters[msg.sender]==false, 'You have already voted');
       thisRequest.voters[msg.sender] = true;
       thisRequest.noOfVoters++;
    }
    function reqPayment(uint _reqNo) public onlyManager{
        require(raisedAmt >= traget,'Target not met');
        Request storage thisRequest = requests[_reqNo];
        require(thisRequest.completed == false, 'Request already completed');
        require(thisRequest.noOfVoters > noOfContributors/2, 'Not enough votes');
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}