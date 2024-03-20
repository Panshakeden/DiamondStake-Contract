// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibStakeAppStorage {

    // stake info storage
    struct StakeInfo {
        uint256 amountStaked;
        uint256 timeStaked;
        uint256 reward;
    }

    // stake storage
    struct StakeStorage {
        address stakeToken;
        address rewardToken;
        uint8 rewardRate;
        mapping(address => StakeInfo) stakes;
    }
}