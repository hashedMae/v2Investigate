// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import "../src/constants.sol";

contract V1State is Test {
    
    BondingV2 reBondV2;
    BondingShareV2 reShareV2;

    ///user address => bond id => lpBalance in bond
    mapping(address => mapping(uint256 => uint256)) lpBalancesV1;
    mapping(address => mapping(uint256 => uint256)) lpBalancesV2;
    mapping(address => mapping(uint256 => uint256)) lpBalancesVR;
    ///user addres => bond id
    mapping(address => uint256[]) v1IDs;
    mapping(address => uint256[]) v2IDs;
    mapping(address => uint256[]) vrIDs;
    ///bond id => weeks locked
    mapping(uint256 => uint256) weeksLockup;
    ///bond id => shares ammount
    mapping(uint256 => uint256) sharesByIDV1;
    mapping(uint256 => uint256) sharesByIDV2;
    mapping(uint256 => uint256) sharesByIDVR;

    function setUp() public {
        vm.warp(blockSnapshot);
        for(uint256 i; i < users.length; ++i) {
            address user = users[i];
            v1IDs[user] = bShareV1.holderTokens(user);
            for(uint256 j; j < v1IDS[user].length; ++j){
                uint256 id = v1IDs[user][j];
                sharesByIDV1[id] = bShareV1.balanceOf(user, id);
                uint256 shareValue = bondV1.currentShareValue();
                lpBalancesV1[user][id] = uFormulas.redeemBonds(sharesByIDV1[id], shareValue, 1e18);
            }
        }

        deal(manager.stableSwapMetaPoolAddress(), firstAccount,10000e18);
    }

    function testWithdrawAmount(uint256 deposit){
        deposit = bound(deposit, 1e18, 10000e18);

        uint256 preBalance = metapool.balanceOf(firstAccount);

        vm.startPrank(firstAccount);
        metapool.approve(address(bondingV1), deposit);
        uint256 id = bondingV1.deposit(deposit, 1);
        vm.warp(block.number + 8 days);
        uint256 shares = bondingV1.balanceOf(firstAccount, id);
        bondingV1.withdraw(shares, id);
        uint256 postBalance = metapool.balanceOf(firstAccount);
        assertGe(postBalance, preBalance);
    }
}
