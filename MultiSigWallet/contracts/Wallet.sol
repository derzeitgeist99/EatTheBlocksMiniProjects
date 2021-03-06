pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet{
    address [] public approvers;
    uint public quorum;

    //Struct Transfer
    struct Transfer {
        uint id;
        address payable to;
        uint amount;
        uint approvals;
        bool sent;
    }
    Transfer[] public transfers;
    mapping(address => mapping (uint => bool)) public approvals;
    

    constructor(address [] memory _approvers, uint _quorum) public {
        approvers = _approvers;
        quorum = _quorum;
    }

    function getApprovers() external view returns(address[] memory){
        return approvers;
    }


    function getTransfers() external view returns(Transfer[] memory){
        return transfers;
    }

    // function createTransfer. creates transer object
    function createTransfer (uint amount, address payable to) external onlyApprover(){
        transfers.push(Transfer(
            transfers.length, to, amount, 0, false));
        
    }

    function approveTransfer(uint id) external onlyApprover() {
        require(transfers[id].sent ==false, "Transfer already sent");
        require(approvals[msg.sender][id] == false, "Transfer already approved");
        approvals[msg.sender][id] = true;
        transfers[id].approvals++;
        if(transfers[id].approvals >= quorum){
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount);
        }
    }

    receive() external payable{}

    modifier onlyApprover(){
        bool allowed = false;
        for (uint i = 0; i <approvers.length; i++){
            if(approvers[i]== msg.sender){
                allowed = true;
            }
        }
        require(allowed == true, "Only Approved Addresses");
        _;
    } 
}
