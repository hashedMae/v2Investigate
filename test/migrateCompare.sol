// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import "./LiveTestHelper.sol";

contract V1State is LiveTestHelper {
    
    BondingV2 reBondV2;
    BondingShareV2 reShareV2;

    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    //user address => bond id => lpBalance in bond
    mapping(address => mapping(uint256 => uint256)) lpBalancesV1;
    mapping(address => mapping(uint256 => uint256)) lpBalancesV2;
    mapping(address => mapping(uint256 => uint256)) lpBalancesVR;
    //user addres => bond id
    mapping(address => uint256) v1IDs;
    mapping(address => uint256) v2IDs;
    mapping(address => uint256) vrIDs;
    //bond id => weeks locked
    mapping(uint256 => uint256) weeksLockup;
    //bond id => shares ammount
    uint256[] public sharesByIDV1;
    uint256[] public sharesByIDV2;
    uint256[] public sharesByIDVR;
    
    uint256 mainnetFork;


    function setUp() public virtual override {
       super.setUp();
       /* mainnetFork = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/hJjFfMayAD0ty8fkQh3PR33iXG3g8MaK", 12811688);
        vm.selectFork(mainnetFork);
        /*for(uint256 i; i < users.length; ++i) {
            address user = users[i];
            v1IDs[user] = bondingShareV1.holderTokens(user);
            for(uint256 j; j < v1IDs[user].length; ++j){
                uint256 id = v1IDs[user][j];
                sharesByIDV1[id] = bondingShareV1.balanceOf(user, id);
                uint256 shareValue = bondingV1.currentShareValue();
                lpBalancesV1[user][id] = uFormulas.redeemBonds(sharesByIDV1[id], shareValue, 1e18);
            }
        }
        vm.startPrank(deployer);
        manager.setBondingContractAddress(address(bondingV1));
        manager.setBondingShareAddress(address(bondingShareV1));
        manager.setMasterChefAddress(0x8fFCf9899738e4633A721904609ffCa0a2C44f3D);
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(bondingV1));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(bondingShareV1));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), 0x8fFCf9899738e4633A721904609ffCa0a2C44f3D);
        manager.grantRole(manager.UBQ_BURNER_ROLE(), address(bondingShareV1));
        manager.grantRole(manager.UBQ_BURNER_ROLE(), address(bondingV1));
        vm.stopPrank();*/
        
    }

   /* function testWithdrawAmount(uint256 deposit) public {
        deposit = bound(deposit, 1e18, 10000e18);

        //uint256 preBalance = metapool.balanceOf(firstAccount);

        vm.startPrank(firstAccount);
        metapool.approve(address(bondingV1), deposit);
        uint256 id = bondingV1.deposit(deposit, 8);
        vm.roll(12811688 + 43 days);
        uint256 shares = bondingShareV1.balanceOf(firstAccount, id);
        bondingShareV1.setApprovalForAll(address(bondingV1), true);
        bondingV1.withdraw(shares, id);
        //uint256 postBalance = metapool.balanceOf(firstAccount);
        //assertGe(postBalance, preBalance);
    }*/

    function testBondShares(uint256 lpAmount, uint256 lockup) public {
        lpAmount = bound(lpAmount, 1e18, 10000e18);
        lockup = bound(lockup, 1, 208);

        vm.startPrank(firstAccount);
        metapool.approve(address(bondingV1), lpAmount);
        uint256 id1 = bondingV1.deposit(lpAmount, lockup);
        uint256 shares1 = bondingShareV1.balanceOf(firstAccount, id1);
        vm.stopPrank();
        switchV2();
        vm.prank(admin);
        bondingV2.addUserToMigrate(secondAccount, lpAmount, lockup);
        vm.prank(secondAccount);
        bondingV2.migrate();
        vm.stopPrank();
        uint256[2] memory shares2 = chefV2.getBondingShareInfo(1);

        assertEq(shares1, shares2[0]);
    }

    function testMigration() public {
        for(uint256 i; i < users.length; ++i){
            address user = users[i];
            deal(address(metapool), user, 2**128-1);
            vm.startPrank(users[i]);
            metapool.approve(address(bondingV1), 2**256-1);
            uint256 id = bondingV1.deposit(lpAmounts[i], lockups[i]);
            v1IDs[user] = id;
            sharesByIDV1.push(bondingShareV1.balanceOf(users[i], id));
            bondingShareV1.setApprovalForAll(address(bondingV1), true);
            vm.stopPrank();
        }
        switchV2();
        for(uint256 i; i < users.length; ++i){
            address user = users[i];
            vm.prank(user);
            uint256 id = bondingV2.migrate();
            v2IDs[user] = id;
            uint256[2] memory shares = chefV2.getBondingShareInfo(id);
            sharesByIDV2.push(shares[0]);
        }
        log_array(sharesByIDV1);
        log_array(sharesByIDV2);
    }

    function testMigrateVsDeposit() public {
        address migrateUser = users[0];
        uint256 migrateAmount = lpAmounts_[0];
        uint256 lockup = lockups[0];
        address depositUser = address(0x19191919);
        
        
        deal(address(metapool), migrateUser, migrateAmount);
        deal(address(metapool), depositUser, migrateAmount);

        vm.startPrank(migrateUser);
        metapool.approve(address(bondingV1), migrateAmount);
        bondingV1.deposit(migrateAmount, lockup);
        bondingShareV1.setApprovalForAll(address(bondingV1), true);
        vm.stopPrank();

        switchV2();
        uint256 dust = metapool.balanceOf(address(bondingV1));
        vm.prank(admin);
        bondingV1.sendDust(address(bondingV2), address(metapool), dust);

        vm.prank(migrateUser);
        uint256 migrateID = bondingV2.migrate();

        vm.startPrank(depositUser);
        metapool.approve(address(bondingV2), migrateAmount);
        uint256 depositID = bondingV2.deposit(migrateAmount, lockup);
        vm.stopPrank();

        vm.roll(block.number+1000);
        
        vm.prank(migrateUser);
        uint256 migrateRewards = chefV2.getRewards(migrateID);

        vm.prank(depositUser);
        uint256 depositRewards = chefV2.getRewards(depositID);

        emit log_uint(migrateRewards);
        emit log_uint(depositRewards);

        assertEq(migrateRewards, uGov.balanceOf(migrateUser));

        assertEq(depositRewards, uGov.balanceOf(depositUser));
    }
}
