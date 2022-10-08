// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import "ubiquity-dollar/Bonding.sol";
import "ubiquity-dollar/BondingShare.sol";
import "ubiquity-dollar/BondingV2.sol";
import "ubiquity-dollar/BondingShareV2.sol";
import "ubiquity-dollar/BondingFormulas.sol";
import "ubiquity-dollar/UbiquityAlgorithmicDollarManager.sol";
import "ubiquity-dollar/UbiquityFormulas.sol";



contract Constants {

    Bonding bondV1 = Bonding(0x831e3674Abc73d7A3e9d8a9400AF2301c32cEF0C);
    BondingShare bShareV1 = BondingShare(0x0013B6033dd999676Dc547CEeCEA29f781D8Db17);
    BondingV2 bondV2 = BondingV2(0xC251eCD9f1bD5230823F9A0F99a44A87Ddd4CA38);
    BondingShareV2 bShareV2 = bondingShareV2(0x2dA07859613C14F6f05c97eFE37B9B4F212b5eF5);
    UbiquityAlgorithmicDollarManager manager = UbiquityAlgorithmicDollarManager(0x4DA97a8b831C345dBe6d16FF7432DF2b7b776d98);
    UbiquityFormulas uFormulas = UbiquityFormulas(0x54F528979A50FA8Fe99E0118EbbEE5fC8Ea802F7);

    address deployer = address(0xefc0e701a824943b469a694ac564aa1eff7ab7dd);

    uint256 blockSnapshot = 12931300;
    uint256 blockDeploy = 12931495;

    address firstAccount = address(0x1);
    

    address[36] users = [
      "0x89eae71b865a2a39cba62060ab1b40bbffae5b0d",
      "0xefc0e701a824943b469a694ac564aa1eff7ab7dd",
      "0xa53a6fe2d8ad977ad926c485343ba39f32d3a3f6",
      "0x7c76f4db70b7e2177de10de3e2f668dadcd11108",
      "0x4007ce2083c7f3e18097aeb3a39bb8ec149a341d",
      "0xf6501068a54f3eab46c1f145cb9d3fb91658b220",
      "0x10693e86f2e7151b3010469e33b6c1c2da8887d6",
      "0xcefd0e73cc48b0b9d4c8683e52b7d7396600abb2",
      "0xd028babbdc15949aaa35587f95f9e96c7d49417d",
      "0x9968efe1424d802e1f79fd8af8da67b0f08c814d",
      "0xd3bc13258e685df436715104882888d087f87ed8",
      "0x0709b103d46d71458a71e5d81230dd688809a53d",
      "0xe3e39161d35e9a81edec667a5387bfae85752854",
      "0x7c361828849293684ddf7212fd1d2cb5f0aade70",
      "0x9d3f4eeb533b8e3c8f50dbbd2e351d1bf2987908",
      "0x865dc9a621b50534ba3d17e0ea8447c315e31886",
      "0x324e0b53cefa84cf970833939249880f814557c6",
      "0xce156d5d62a8f82326da8d808d0f3f76360036d0",
      "0x26bdde6506bd32bd7b5cc5c73cd252807ff18568",
      "0xd6efc21d8c941aa06f90075de1588ac7e912fec6",
      "0xe0d62cc9233c7e2f1f23fe8c77d6b4d1a265d7cd",
      "0x0b54b916e90b8f28ad21da40638e0724132c9c93",
      "0x629cd43eaf443e66a9a69ed246728e1001289eac",
      "0x0709e442a5469b88bb090dd285b1b3a63fb0c226",
      "0x94a2ffdbdbd84984ac7967878c5c397126e7bbbe",
      "0x51ec66e63199176f59c80268e0be6ffa91fab220",
      "0x0a71e650f70b35fca8b70e71e4441df8d44e01e9",
      "0xc1b6052e707dff9017deab13ae9b89008fc1fc5d",
      "0x9be95ef84676393588e49ad8b99c9d4cdfdaa631",
      "0xfffff6e70842330948ca47254f2be673b1cb0db7",
      "0x0000ce08fa224696a819877070bf378e8b131acf",
      "0xc2cb4b1bcaebaa78c8004e394cf90ba07a61c8f7",
      "0xb2812370f17465ae096ced55679428786734a678",
      "0x3eb851c3959f0d37e15c2d9476c4adb46d5231d1",
      "0xad286cf287b91719ee85d3ba5cf3da483d631dba",
      "0xbd37a957773d883186b989f6b21c209459022252"
    ];


    
}
