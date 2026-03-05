// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address user) external view returns (uint256);
}

contract TokenVesting {
    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable releaseTime;

    event Funded(uint256 amount);
    event Released(uint256 amount);

    constructor(address tokenAddress, address beneficiaryAddress, uint256 releaseTimeUnix) {
        require(tokenAddress != address(0), "ZERO_TOKEN");
        require(beneficiaryAddress != address(0), "ZERO_BENEF");
        require(releaseTimeUnix > block.timestamp, "TIME_IN_PAST");

        token = IERC20(tokenAddress);
        beneficiary = beneficiaryAddress;
        releaseTime = releaseTimeUnix;
    }

    function fund(uint256 amount) external {
        require(amount > 0, "AMOUNT_ZERO");
        bool ok = token.transferFrom(msg.sender, address(this), amount);
        require(ok, "TRANSFER_FROM_FAIL");
        emit Funded(amount);
    }

    function release() external {
        require(block.timestamp >= releaseTime, "NOT_RELEASE_TIME");
        uint256 bal = token.balanceOf(address(this));
        require(bal > 0, "NOTHING_TO_RELEASE");

        bool ok = token.transfer(beneficiary, bal);
        require(ok, "TRANSFER_FAIL");
        emit Released(bal);
    }

    function contractTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
