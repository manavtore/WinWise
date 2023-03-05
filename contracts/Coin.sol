// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.8.19;

contract Lottery{
    address public Manager;//used to store address of the manager
    address payable[] public Participant;
    bool public execution;
    //functions that receive ether are marked as payable
    //The keyword payable allows someone to send ether to a contract and run code to account for this deposit.

    constructor(){
        Manager=msg.sender;
        //msg.sender is a global variable that represents the address of the account that calls a function in a smart contract
        /*The msg.sender is the address that has called or initiated a function or created a transaction. 
        Now, this address could be of a contract or even a person like you and me*/
    }

    receive() external payable{
        //the receive function is a function which is automatically called when ethers are transferred to it
        //external is often marked to the functions that can only be called from outside
        //payable is refered to a function where it is automatically called when ether is transferred
        require(msg.value==2 ether,"Kya re aee bhikmangya");
        Participant.push(payable(msg.sender));
        //here we push the address to the array people whoever have tranferred ether to the account
        /*The receive() function is a special function in Solidity that is automatically called when 
        a contract receives Ether without any data attached to the transaction. It is marked as 
        external, which means it can only be called from outside the contract, and payable,
         which means it can receive Ether along with the function call.*/
    }
    
    function Participants() public view returns(uint){
        return Participant.length;
    }

    function getbalance() public view onlyOwner returns(uint){
        /*the getbalance is a fuction that returns the balance in the format of wei that is 
        the smallest unit of ether*/

       // require(msg.sender== Manager,"Manager nhi hai tu lavde");
        return address(this).balance;

        /*The this keyword refers to the current contract, and address() is used to convert 
        it to an address type to access the balance property. The balance property retrieves
         the current balance of the contract in wei.*/


    }

    event Declare_winner(address Winner);

    function random() public view onlyOwner returns(address payable){

        uint256 randomno=uint256(keccak256(abi.encode(block.difficulty,block.timestamp,Participant.length)));
     /*block.difficulty is a variable that represents the difficulty level of
      the block in which the transaction is included. It is a measure of how hard it is to mine the block.
        */

        /*block.timestamp is a variable that represents the timestamp of the block in which the transaction is included. 
        It is a Unix timestamp (seconds since the Unix epoch) indicating when the block was mined.
        */
        address payable Winner = Participant[randomno % Participant.length];

        

        return Winner;
           
        
    }
    
    modifier onlyOwner()
    {
            require(msg.sender == Manager,'Only The Manager can do this ');
            _;
        }

  
    function SelectWinner() public  onlyOwner returns(address){

       require(Participant.length>0);
      
       uint256 contractBalance= address(this).balance;


       address finalWinner = random();
       
       require(contractBalance>0,'Contract balance is Zero');
       
       (bool Success,)=finalWinner.call { value:contractBalance-1 ether} ("");
        
        require(Success,"Transfer to winner failed");

       execution=true;

       return finalWinner;
       
         
    }
    

    function generate_profit() public onlyOwner returns(uint256){

           require(execution,'firstly you have to declare winner');

            uint256 contractBalance=address(this).balance;

          require(contractBalance==1 ether,'No balance is left');
      

           (bool Success,)=Manager.call { value:contractBalance} ("");

       require(Success,"Transfer to manager failed");
       
      return contractBalance;
       


    }



  }

