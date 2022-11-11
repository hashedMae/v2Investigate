// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "ubiquity-dollar/BondingV2.sol";
import "ubiquity-dollar/Bonding.sol";
import "ubiquity-dollar/BondingShare.sol";
import "ubiquity-dollar/BondingFormulas.sol";
import "ubiquity-dollar/BondingShareV2.sol";
import "ubiquity-dollar/interfaces/IMetaPool.sol";
import "ubiquity-dollar/UbiquityGovernance.sol";
import "ubiquity-dollar/UbiquityAlgorithmicDollarManager.sol";
import "ubiquity-dollar/mocks/MockuADToken.sol";
import "ubiquity-dollar/UbiquityFormulas.sol";
import "ubiquity-dollar/TWAPOracle.sol";
import "ubiquity-dollar/MasterChefV2.sol";
import "ubiquity-dollar/UARForDollarsCalculator.sol";
import "ubiquity-dollar/interfaces/ICurveFactory.sol";
import "ubiquity-dollar/MasterChef.sol";
import "ubiquity-dollar/CouponsForDollarsCalculator.sol";
import "ubiquity-dollar/DollarMintingCalculator.sol";
import "ubiquity-dollar/UbiquityAutoRedeem.sol";
import "ubiquity-dollar/ExcessDollarsDistributor.sol";
import "ubiquity-dollar/SushiSwapPool.sol";
import "ubiquity-dollar/interfaces/IERC1155Ubiquity.sol";

import "../src/constants.sol";

import "v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "forge-std/Test.sol";

contract LiveTestHelper is Test, Constants {
    using stdStorage for StdStorage;

    
    Bonding bondingV1;
    BondingV2 bondingV2;
    BondingFormulas bFormulas;
    BondingShareV2 bondingShareV2;

    UbiquityAlgorithmicDollarManager manager;

    UbiquityFormulas uFormulas;
    TWAPOracle twapOracle;
    MasterChefV2 chefV2;
    UARForDollarsCalculator uarCalc;
    CouponsForDollarsCalculator couponCalc;
    DollarMintingCalculator dollarMintCalc;
    UbiquityAutoRedeem uAR;
    ExcessDollarsDistributor excessDollarsDistributor;
    SushiSwapPool sushiUGOVPool;
    IMetaPool metapool;
    
    MockuADToken uAD;
    MockuADToken uAD2;
    UbiquityGovernance uGov;
    UbiquityGovernance uGov2;

    BondingShare bondingShareV1;

    IUniswapV2Factory factory =
        IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    IUniswapV2Router02 router =
        IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 crvToken = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    IERC20 WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    ICurveFactory curvePoolFactory =
        ICurveFactory(0x0959158b6040D32d04c301A72CBFD6b39E21c9AE);

    MasterChef chefV1;

    address admin = address(0x1);
    address treasury = address(0x3);
    address firstAccount = address(0x99);
    address secondAccount = address(0x4);
    address thirdAccount = address(0x5);
    address fourthAccount = address(0x6);
    address fifthAccount = address(0x7);
    address bondingZeroAccount = address(0x8);
    address bondingMinAccount = address(0x9);
    address bondingMaxAccount = address(0x10);

    address sablier = 0xA4fc358455Febe425536fd1878bE67FfDBDEC59a;
    address curve3CrvBasePool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
    address curveWhaleAddress = 0x4486083589A063ddEF47EE2E4467B5236C508fDe;
    address daiWhaleAddress = 0x16463c0fdB6BA9618909F5b120ea1581618C1b9E;
    address usdcWhaleAddress = 0x72A53cDBBcc1b9efa39c834A540550e23463AAcB;
    address curve3CrvToken = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;

    string uri =
        "https://bafybeifibz4fhk4yag5reupmgh5cdbm2oladke4zfd7ldyw7avgipocpmy.ipfs.infura-ipfs.io/";
    uint256 couponLengthBlocks = 100;

    address[] migrating;
    uint256[] migrateLP;
    uint256[] locked;

    function setUp() public virtual {
        
        for(uint256 i; i< users_.length; ++i){
        users.push(users_[i]);
        lpAmounts.push(lpAmounts_[i]);
        lockups.push(lockups_[i]);
        }

        
        vm.startPrank(admin);

        manager = new UbiquityAlgorithmicDollarManager(admin);
        address managerAddress = address(manager);
        

        bondingV1 = new Bonding(address(manager), sablier);
        bondingShareV1 = new BondingShare(address(manager));
        manager.setBondingShareAddress(address(bondingShareV1));
        manager.setBondingContractAddress(address(bondingV1));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(bondingV1));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(bondingShareV1));

        uAD = new MockuADToken(10000);
        manager.setDollarTokenAddress(address(uAD));
        
        uFormulas = new UbiquityFormulas();
        manager.setFormulasAddress(address(uFormulas));
        

        uGov = new UbiquityGovernance(address(manager));
        
        manager.setGovernanceTokenAddress(address(uGov));
        
        //manager.grantRole(manager.BONDING_MANAGER_ROLE(), admin);

        bondingV1.setBlockCountInAWeek(420);
        manager.setBondingContractAddress(address(bondingV1));

        bondingShareV1.setApprovalForAll(address(bondingV1), true);

        manager.setTreasuryAddress(treasury);

        deal(address(uGov), thirdAccount, 100000e18);
        deal(address(uAD), thirdAccount, 1000000e18);

        sushiUGOVPool = new SushiSwapPool(address(manager));
        manager.setSushiSwapPoolAddress(address(sushiUGOVPool));
        manager.setSushiSwapPoolAddress(address(sushiUGOVPool));

        vm.stopPrank();

        vm.startPrank(thirdAccount);
        uAD.approve(address(router), 1000000e18);
        uGov.approve(address(router), 100000e18);
        router.addLiquidity(
            address(uAD),
            address(uGov),
            1000000e18,
            100000e18,
            990000e18,
            99000e18,
            thirdAccount,
            block.timestamp + 100
        );
        vm.stopPrank();

        vm.startPrank(admin);

        address[6] memory mintings = [
            admin,
            address(manager),
            fourthAccount,
            bondingZeroAccount,
            bondingMinAccount,
            bondingMaxAccount
        ];

        for (uint256 i = 0; i < mintings.length; ++i) {
            deal(address(uAD), mintings[i], 10000e18);
        }

        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(bondingV1));
        manager.grantRole(manager.UBQ_BURNER_ROLE(), address(bondingV1));

        deal(address(uAD), curveWhaleAddress, 10e18);

        vm.stopPrank();

        address[4] memory crvDeal = [
            address(manager),
            bondingMaxAccount,
            bondingMinAccount,
            fourthAccount
        ];

        for (uint256 i; i < crvDeal.length; ++i) {
            vm.prank(curveWhaleAddress);
            crvToken.transfer(crvDeal[i], 10000e18);
        }

        vm.startPrank(admin);
        manager.deployStableSwapPool(
            address(curvePoolFactory),
            curve3CrvBasePool,
            curve3CrvToken,
            10,
            50000000
        );
        
        metapool = IMetaPool(manager.stableSwapMetaPoolAddress());
        /*metapool.transfer(address(bondingV2), 100e18);
        metapool.transfer(secondAccount, 1000e18);*/

        twapOracle =
        new TWAPOracle(address(metapool), address(uAD), address(curve3CrvToken));
        manager.setTwapOracleAddress(address(twapOracle));
        uarCalc = new UARForDollarsCalculator(address(manager));
        manager.setUARCalculatorAddress(address(uarCalc));

        couponCalc = new CouponsForDollarsCalculator(address(manager));
        manager.setCouponCalculatorAddress(address(couponCalc));

        dollarMintCalc = new DollarMintingCalculator(address(manager));
        manager.setDollarMintingCalculatorAddress(address(dollarMintCalc));


        /*manager.grantRole(manager.COUPON_MANAGER_ROLE(), address(debtCouponMgr));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(debtCouponMgr));
        manager.grantRole(manager.UBQ_BURNER_ROLE(), address(debtCouponMgr));*/

        uAR = new UbiquityAutoRedeem(address(manager));
        manager.setuARTokenAddress(address(uAR));

        excessDollarsDistributor =
            new ExcessDollarsDistributor(address(manager));
        /*manager.setExcessDollarsDistributor(
            address(debtCouponMgr), address(excessDollarsDistributor)
        );*/

        address[] memory tos;
        uint256[] memory amounts;
        uint256[] memory ids;

        chefV1 = new MasterChef(address(manager));
        manager.setMasterChefAddress(address(chefV1));
        manager.grantRole(manager.UBQ_TOKEN_MANAGER_ROLE(), admin);
        chefV1.setUGOVPerBlock(10e18);

        chefV2 = new MasterChefV2(managerAddress, tos, amounts, ids);

        /*manager.setMasterChefAddress(address(chefV2));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(chefV2));
        manager.grantRole(manager.UBQ_TOKEN_MANAGER_ROLE(), admin);
        manager.grantRole(manager.UBQ_TOKEN_MANAGER_ROLE(), managerAddress);*/

        

        vm.stopPrank();

        vm.startPrank(bondingMinAccount);
        uAD.approve(address(metapool), 10000e18);
        crvToken.approve(address(metapool), 10000e18);
        vm.stopPrank();

        vm.startPrank(bondingMaxAccount);
        uAD.approve(address(metapool), 10000e18);
        crvToken.approve(address(metapool), 10000e18);
        vm.stopPrank();

        vm.startPrank(fourthAccount);
        uAD.approve(address(metapool), 10000e18);
        crvToken.approve(address(metapool), 10000e18);
        vm.stopPrank();

        uint256[2] memory amounts_ = [uint256(100e18), uint256(100e18)];

        uint256 dyuAD2LP = metapool.calc_token_amount(amounts_, true);

        vm.prank(bondingMinAccount);
        metapool.add_liquidity(amounts_, dyuAD2LP * 99 / 100, bondingMinAccount);

        vm.prank(bondingMaxAccount);
        metapool.add_liquidity(amounts_, dyuAD2LP * 99 / 100, bondingMaxAccount);

        vm.prank(fourthAccount);
        metapool.add_liquidity(amounts_, dyuAD2LP * 99 / 100, fourthAccount);

        ///uint256 bondingMinBal = metapool.balanceOf(bondingMinAccount);
        ///uint256 bondingMaxBal = metapool.balanceOf(bondingMaxAccount);

        vm.startPrank(admin);
        bondingShareV2 = new BondingShareV2(address(manager), uri);
        //manager.setBondingShareAddress(address(bondingShareV2));

        bFormulas = new BondingFormulas();

        migrating = [bondingZeroAccount, bondingMinAccount, bondingMaxAccount];
        migrateLP = [0, 0, 0];
        locked = [uint256(1), uint256(1), uint256(208)];

        bondingV2 =
        new BondingV2(address(manager), address(uFormulas), users, lpAmounts, lockups);

        //bondingV1.sendDust(address(bondingV2), address(metapool), bondingMinBal + bondingMaxBal);

        bondingV2.setMigrating(true);

        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(bondingV2));
        bondingV2.setBlockCountInAWeek(420);

        ///manager.setBondingContractAddress(address(bondingV2));

        vm.stopPrank();

        vm.prank(secondAccount);
        bondingShareV1.setApprovalForAll(address(bondingV1), true);

        vm.prank(thirdAccount);
        bondingShareV1.setApprovalForAll(address(bondingV1), true);

        deal(address(metapool), firstAccount, 10000e18);
        deal(address(metapool), secondAccount, 10000e18);
    }

    function switchV2() public {
        vm.startPrank(admin);
        manager.setMasterChefAddress(address(chefV2));
        manager.grantRole(manager.UBQ_MINTER_ROLE(), address(chefV2));
        manager.grantRole(manager.UBQ_TOKEN_MANAGER_ROLE(), admin);
        manager.grantRole(manager.UBQ_TOKEN_MANAGER_ROLE(), address(manager));
        manager.grantRole(manager.BONDING_MANAGER_ROLE(), admin);
        manager.setBondingContractAddress(address(bondingV2));
        manager.setBondingShareAddress(address(bondingShareV2));
        chefV2.setUGOVPerBlock(10e18);
        vm.stopPrank();
    }
}

