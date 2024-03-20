// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {IERC20} from "../interfaces/IERC20.sol";
import {LibStakeAppStorage} from "../libraries/LibStakeAppStorage.sol";

contract StakingFacet {
    
    LibStakeAppStorage.StakeStorage s;

    // custom errors
    error ADDRESS_ZERO();
    error INVALID_AMOUNT();
    error INSUFFICIENT_AMOUNT();
    error USER_HAS_NO_STAKE();
    error NO_REWARD_TO_CLIAM();

    // events
    event stakingSuccessful(address _staker, uint256 _amount);
    event claimSuccessful(address _staker, uint256 _amount);
    event unStakeSuccessful(address _staker, uint256 _amount);

    // stake function
    function stake(uint256 _amount) external {

        if (msg.sender == address(0)) {
            revert ADDRESS_ZERO();
        }

        if (_amount <= 0) {
            revert INVALID_AMOUNT();
        }

        if (IERC20(s.stakeToken).balanceOf(msg.sender) < _amount) {
            revert INSUFFICIENT_AMOUNT();
        }

        require(
            IERC20(s.stakeToken).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "failed to transfer"
        );

        s.stakes[msg.sender] = LibStakeAppStorage.StakeInfo(_amount, block.timestamp, 0);

        emit stakingSuccessful(msg.sender, _amount);
    }

    // function unstake
    function unStake() external {
        if (msg.sender == address(0)) {
            revert ADDRESS_ZERO();
        }

        if (s.stakes[msg.sender].amountStaked <= 0) {
            revert USER_HAS_NO_STAKE();
        }

        LibStakeAppStorage.StakeInfo memory _staker = s.stakes[msg.sender];
        uint256 _reward = _staker.reward + calculateReward();

        s.stakes[msg.sender].reward = 0;
        s.stakes[msg.sender].timeStaked = 0;
        s.stakes[msg.sender].amountStaked = 0;

        IERC20(s.rewardToken).transfer(
            msg.sender,
            _staker.amountStaked + _reward
        );

        emit unStakeSuccessful(msg.sender, _staker.amountStaked + _reward);
    }

    // cliam reward function
    function cliamReward() external {

        if (s.stakes[msg.sender].amountStaked <= 0) {
            revert NO_REWARD_TO_CLIAM();
        }

        uint256 _reward = s.stakes[msg.sender].reward + calculateReward();

        s.stakes[msg.sender].reward = 0;
        s.stakes[msg.sender].timeStaked = block.timestamp;

        IERC20(s.rewardToken).transfer(msg.sender, _reward);
    
        emit claimSuccessful(msg.sender, _reward);
    }

    // calculateReward function
    function calculateReward() public view returns (uint256) {

        uint256 _callerStake = s.stakes[msg.sender].amountStaked;

        if (_callerStake <= 0) {
            revert USER_HAS_NO_STAKE();
        }

        return
            (block.timestamp - s.stakes[msg.sender].timeStaked) *
            s.rewardRate *
            _callerStake;
    }
}