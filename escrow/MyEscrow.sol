// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyEscrow {
    address public constant tokenToEscrow = 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359;
    IERC20 public escrowToken = IERC20(tokenToEscrow);

    address public buyerAddress = address(0);
    address public sellerAddress = address(0);
    address public mediatorAddress = address(0);
    uint256 public amountToEscrow = 0;

    constructor() {}

    function openEscrow(address escrowSeller, address escrowMediator, uint256 escrowAmount) public {
        require(buyerAddress == address(0), "Escrow already in use.");

        buyerAddress = msg.sender;
        sellerAddress = escrowSeller;
        mediatorAddress = escrowMediator;
        amountToEscrow = escrowAmount;

        require(escrowToken.transferFrom(msg.sender, address(this), amountToEscrow), "Token transfer failed");
    }

    function paySeller() public {
        require(msg.sender == mediatorAddress, "Only the mediator can release funds to seller.");
        require(escrowToken.transfer(sellerAddress, amountToEscrow), "Payment to seller failed");
        _resetEscrow();
    }

    function returnFunds() public {
        require(msg.sender == mediatorAddress, "Only the mediator can return funds to buyer.");
        require(escrowToken.transfer(buyerAddress, amountToEscrow), "Return to buyer failed");
        _resetEscrow();
    }

    function _resetEscrow() internal {
        buyerAddress = address(0);
        sellerAddress = address(0);
        mediatorAddress = address(0);
        amountToEscrow = 0;
    }
}
