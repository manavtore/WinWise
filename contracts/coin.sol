// SPDX-License-Identifier: GPL-3.0

pragma solidity>0.8.0 <=0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract Mytoken is ERC20{
    constructor() ERC20("Nonsense","Chapli")
    {
       _mint(msg.sender,100*(10**uint(decimals())));
    }
}
