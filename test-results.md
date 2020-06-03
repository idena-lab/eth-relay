# Test Results

## pairing

> multiplication
✓ should scalarMult G1 point (1) (67ms)
✓ should scalarMult G1 point (2) (46ms)
✓ should scalarMult G1 point (3) (78ms)
✓ should scalarMult G1 point (4) (61ms)
✓ should scalarMult G1 point (5) (52ms)
✓ should scalarMult G1 point (6) (42ms)
✓ should scalarMult G1 point (7)
✓ should scalarMult G1 point (8)
✓ should scalarMult G1 point (9) (68ms)
✓ should scalarMult G1 point (10) (56ms)
✓ should scalarMult G1 point (11) (42ms)
✓ should scalarMult G1 point (12)
✓ should scalarMult G1 point (13)
✓ should scalarMult G1 point (14) (69ms)
✓ should scalarMult G1 point (15) (52ms)
✓ should scalarMult G1 point (16) (42ms)
✓ should scalarMult G1 point (17)
✓ should scalarMult G1 point (18)
> hashToG1
✓ check hash (1) (44ms)
✓ check hash (2) (44ms)
✓ check hash (3) (55ms)
✓ check hash (4) (46ms)
✓ check hash (5)
✓ check hash (6) (45ms)
✓ check hash (7) (40ms)
✓ check hash (8) (40ms)
✓ check hash (9) (46ms)
✓ check hash (10)
> pairing
✓ check pairing (1) (785ms)
✓ check pairing (2) (714ms)
✓ check pairing (3) (739ms)
✓ check pairing (4) (767ms)
✓ check pairing (5) (761ms)
✓ check pairing (6) (737ms)
✓ check pairing (7) (691ms)
✓ check pairing (8) (661ms)
✓ check pairing (9) (662ms)
✓ check pairing (10) (669ms)
✓ check pairing (11) (666ms)
✓ check pairing (12) (679ms)
✓ check pairing (13) (41ms)

## verify

Contract: IdenaWorldState
✓ owner should be deployer
> verify
Gas cost: 603631
    ✓ check verify (1): keys=1, message= (4013ms)
Gas cost: 619894
    ✓ check verify (2): keys=1, message=idena go (3631ms)
Gas cost: 626396
    ✓ check verify (3): keys=1, message=long message: 9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999 (3607ms)
Gas cost: 604411
    ✓ check verify (4): keys=2, message=2 keys 1 (3565ms)
Gas cost: 604479
    ✓ check verify (5): keys=2, message=2 keys 2 (3623ms)
Gas cost: 604283
    ✓ check verify (6): keys=3, message=3 keys (3663ms)
Gas cost: 635499
    ✓ check verify (7): keys=4, message=4 keys (3673ms)
Gas cost: 604283
    ✓ check verify (8): keys=10, message=10 keys (3644ms)
Gas cost: 635631
    ✓ check verify (9): keys=100, message=100 keys (3570ms)
Gas cost: 635695
    ✓ check verify (10): keys=356, message=356 keys (3576ms)
Gas cost: 604347
    ✓ check verify (11): keys=800, message=800 keys (3519ms)
Gas cost: 651306
    ✓ check verify (12): keys=1024, message=1024 keys (3666ms)
Gas cost: 620150
    ✓ check verify (13): keys=2048, message=2048 keys (3837ms)
Gas cost: 620150
    ✓ check verify (14): keys=4000, message=4000 keys (3808ms)
Gas cost: 620086
    ✓ check verify (15): keys=6000, message=4000 keys (3832ms)
Gas cost: 604479
    ✓ check verify (16): keys=9000, message=9000 keys (3830ms)
Gas cost: 604607
    ✓ check verify (17): keys=10000, message=10000 keys (3808ms)

## state

### case1

Contract: IdenaWorldState
    > initialize
      ✓ init should failed by non-owner (742ms)
Gas cost: 7433545, tx: 0x113960a9df9d3ed0c758d6770a1d2b35fe33a36bc9c3751d913658679d732fdb
      ✓ init with 100 identities (1839ms)
    > update
Gas cost: 8195408, tx: 0xa32fe6b7e8297c356d919cc840b505a7f4de11c412b189c4a840d49ff1ad2f6c
      ✓ epoch(45): 100 identities -0 +100 by 88 signers(88.00%) (3775ms)
Gas cost: 8483252, tx: 0x398b7a0a4c6266d2fa5d9c95f2604d896348331eb257853d6bad87739e9bf66c
      ✓ epoch(46): 200 identities -0 +100 by 180 signers(90.00%) (4510ms)
Gas cost: 8654672, tx: 0x36d6c2f9f73f712f5841bdced3651b895b1fe7624adfa6db0096d4e7ff68d8d0
      ✓ epoch(47): 300 identities -0 +100 by 248 signers(82.67%) (5006ms)
Gas cost: 9009132, tx: 0xff3ef86fb7dcaf2808788a7467c1d138c21b0d8048a5de6a6b924fcf305c15ad
      ✓ epoch(48): 400 identities -0 +100 by 388 signers(97.00%) (5662ms)
Gas cost: 9084445, tx: 0x0e2966c1eba1f6140fb36de68453c9cebfa526b5ad37f6c1498a74b933a38daf
      ✓ epoch(49): 500 identities -0 +100 by 415 signers(83.00%) (5639ms)
Gas cost: 9481708, tx: 0x9e8dc3d409713ff6a6ddd3978a90edd5762bfedb4ed2a1aeb499034a907d9a98
      ✓ epoch(50): 600 identities -0 +100 by 580 signers(96.67%) (6385ms)
Gas cost: 9506156, tx: 0xd845c50acf9697e14890e5e9d962231a0d16bc7e2d230c2c9918ea47220638a9
      ✓ epoch(51): 700 identities -0 +100 by 572 signers(81.71%) (6371ms)
Gas cost: 9638630, tx: 0xfb0980c243b4215eb6d74bf1931eaaef34bf00af5372ef665bc563d19d5ddcde
      ✓ epoch(52): 800 identities -0 +100 by 624 signers(78.00%) (6637ms)
Gas cost: 9873856, tx: 0xbf46db5b73caa3afd8c6b7e726e277f7c1c4eae12be0eac854c44c5f37f289f5
      ✓ epoch(53): 900 identities -0 +100 by 706 signers(78.44%) (7016ms)
Gas cost: 10088285, tx: 0xbd658e4df261c76b08c121e4b1ab035337a363ff8118e3124737e93e248b1a95
      ✓ epoch(54): 1000 identities -0 +100 by 793 signers(79.30%) (7419ms)
Gas cost: 2805853, tx: 0x836b0eb397b0d509c80c75d00c03c3e40bb10be5ea3e7a7cfc7fc4ea572857b6
      ✓ epoch(54): 1100 identities -0 +0 by 809 signers(73.55%) (5853ms)
Gas cost: 2289288, tx: 0xe6d892fed1c369573da11e86bdc2f59a9555695fe2f5ea1ae7e92cb1f76ced45
      ✓ epoch(55): 1100 identities -100 +0 by 854 signers(77.64%) (7338ms)
Gas cost: 8535106, tx: 0x9d21d171e91f4a34bbcbbec14b1b60ed0457ac7294f7ee8c3203a49a5ff1b08f
      ✓ epoch(56): 1000 identities -0 +100 by 965 signers(96.50%) (7958ms)
Gas cost: 10827821, tx: 0x9958573143db11e82a00616dc4e54c8b57232fc5dd64edb70735cbc0c4a80b70
      ✓ epoch(56): 1100 identities -125 +173 by 903 signers(82.09%) (9921ms)
Gas cost: 7888755, tx: 0x435b8bbd9817e2d5cf6666af6790f5bea3c4dfd904784482020c738f511cbccb
      ✓ epoch(58): 1148 identities -186 +145 by 1101 signers(95.91%) (10575ms)
Gas cost: 9119412, tx: 0x52fb4be3c53cdebc6be22f02be9ba60b416f12033b590ebcbd8b63a4cd948ba6
      ✓ epoch(62): 1107 identities -210 +180 by 1057 signers(95.48%) (11805ms)
Gas cost: 9818132, tx: 0xf3de12283a1dc5d92bbf81d00f50b249b29c9c93f61b8169ae537790596c0172
      ✓ epoch(63): 1077 identities -180 +200 by 727 signers(67.50%) (10152ms)
Reverted as expected, reson: not enough signatures
      ✓ epoch(64): 1097 identities -100 +120 by 380 signers(34.64%) (5230ms)
Reverted as expected, reson: epoch can not decrease
      ✓ epoch(62): 1097 identities -100 +120 by 1092 signers(99.54%) (1073ms)
Gas cost: 7263903, tx: 0x94c9ff74b81045dbf96be60ca412887e0f2a868352088fa590f3c5da1569762b
      ✓ epoch(64): 1097 identities -80 +110 by 862 signers(78.58%) (8650ms)


  22 passing (2m)


### case2

Contract: IdenaWorldState
    > initialize
      ✓ init should failed by non-owner (533ms)
Gas cost: 7433545, tx: 0x4508540d4bd442d75243985ea98a0409147ab55bc9bc92f7cf4779705ab474ac
      ✓ init with 100 identities (1669ms)
    > update
Gas cost: 8195408, tx: 0xcc106f482ed1e5175c28f4c3eac17e79fb15b64f305dd6daf956f6bbf7362acd
      ✓ epoch(45): 100 identities -0 +100 by 88 signers(88.00%) (3598ms)
Gas cost: 8483252, tx: 0x392f3f3d826d4df6160be4f83d7ced0b3d72bc9877b7218acece0ff8984e275e
      ✓ epoch(46): 200 identities -0 +100 by 180 signers(90.00%) (4108ms)
Gas cost: 8654672, tx: 0xe73d99302bf5be7ad115a41b5a524d76fceb33e4ab2b6295a31ebdcb68ecd2f6
      ✓ epoch(47): 300 identities -0 +100 by 248 signers(82.67%) (4454ms)
Gas cost: 9009132, tx: 0x31086c9d3f5eef3e138f4105758ce810f62bba2204b0a851fecf28ea0b313698
      ✓ epoch(48): 400 identities -0 +100 by 388 signers(97.00%) (5266ms)
Gas cost: 9084445, tx: 0x5baea21973eb3d38b4cf9e8cd079fed231f05050c3ced8fa53b2121c987ee923
      ✓ epoch(49): 500 identities -0 +100 by 415 signers(83.00%) (5361ms)
Gas cost: 9481708, tx: 0x36c06eb36ac1271510c4540f0bfef2541f93f4fe1a8ebd1cbe7d33e1f545698e
      ✓ epoch(50): 600 identities -0 +100 by 580 signers(96.67%) (6586ms)
Gas cost: 9506156, tx: 0x48874bde6f2f41d8e81eb445a051c4f89f399e5550d5b1489ab05688ab120360
      ✓ epoch(51): 700 identities -0 +100 by 572 signers(81.71%) (6704ms)
Gas cost: 9638630, tx: 0x41e7b78d345dcb4fdae7cc2f0d71154e3578c28d32e7fba2e49dfcc966376c09
      ✓ epoch(52): 800 identities -0 +100 by 624 signers(78.00%) (6401ms)
Gas cost: 9873856, tx: 0x44d8546fa9262319d14a3225cd972f95157ab597322349c42e443ccd44071d66
      ✓ epoch(53): 900 identities -0 +100 by 706 signers(78.44%) (7013ms)
Gas cost: 10088285, tx: 0xb36ba083d70db3c1a0e3884c35760de2d482c2ce83ebbee5d884933b6534e1fb
      ✓ epoch(54): 1000 identities -0 +100 by 793 signers(79.30%) (7173ms)
Gas cost: 10153387, tx: 0x82f9672313db5234fee381acb0b877561e8e0bb672988062a2ee8215ffe471e5
      ✓ epoch(55): 1100 identities -0 +100 by 809 signers(73.55%) (7673ms)
Gas cost: 11018822, tx: 0x792f1b1f4878a417cda79e7cd565f026493a3504a1648d1df32c44598807d035
      ✓ epoch(56): 1200 identities -0 +100 by 1168 signers(97.33%) (8937ms)
Gas cost: 10757511, tx: 0xa4d4afb48322473cc1c2e3131b03cc4c6226639000007dbea0ae7672839719e8
      ✓ epoch(57): 1300 identities -0 +100 by 1044 signers(80.31%) (8698ms)
Gas cost: 11231700, tx: 0xcdec599955418122cc555ae87f8f3495cfb2cece28aa9b8462879806d511e7f2
      ✓ epoch(58): 1400 identities -0 +100 by 1222 signers(87.29%) (9832ms)
Gas cost: 11130654, tx: 0x9606a8643507b2603decb604e6c95742a5a1f8c22b4a8b37c43d490039fd9298
      ✓ epoch(59): 1500 identities -0 +100 by 1174 signers(78.27%) (9547ms)
Gas cost: 11128993, tx: 0x61df4fa7524afb39f2f449cd965cd1f91bed8bd6dcb5f0cd87d42cfcdd2b8c61
      ✓ epoch(60): 1600 identities -0 +100 by 1168 signers(73.00%) (9305ms)
Gas cost: 11394853, tx: 0x1691a984ff9639f0c7314c1b34db3adce5ab237a594be5b06158faafd71a803c
      ✓ epoch(61): 1700 identities -0 +100 by 1263 signers(74.29%) (9749ms)
Gas cost: 11414514, tx: 0xc284cb75761b3e98826dd921f5e5fc516ce4379d3f24befd6ffedae76ec7aa18
      ✓ epoch(62): 1800 identities -0 +100 by 1267 signers(70.39%) (9752ms)
Gas cost: 12057595, tx: 0xe163db6844f48beeb806b262465b9fe93ee5f547fcdb11939d60d721a447de95
      ✓ epoch(63): 1900 identities -0 +100 by 1530 signers(80.53%) (10977ms)
Gas cost: 13121323, tx: 0xdcb99a761ce9bbb8f77c88b0c3b5548586d537cf7b3e613db9c9d898d377d0b8
      ✓ epoch(64): 2000 identities -0 +100 by 1954 signers(97.70%) (12944ms)
Gas cost: 4150029, tx: 0x931e2d2ce549d4ff5fdf875fd22bfab64d218c0621110562db7350f269c5663d
      ✓ epoch(65): 2100 identities -100 +0 by 1829 signers(87.10%) (12147ms)
Gas cost: 8624178, tx: 0x854eaa3cc9d9c7fcd7bb8a1a9d3f278435567f207e36ed9052e842f1dcb52d18
      ✓ epoch(66): 2000 identities -100 +100 by 1733 signers(86.65%) (12404ms)
Gas cost: 13834392, tx: 0x53caaf0e3bcbfe9c1a46954ce93ecd16b06ceddafc124ba335971c46b1ed18ab
      ✓ epoch(67): 2000 identities -100 +200 by 1675 signers(83.75%) (13807ms)
Gas cost: 6701493, tx: 0xd92834cf937be881e905bcc16f794d294bdecd2d57ade2d96ea3b66b86b44128
      ✓ epoch(68): 2100 identities -200 +100 by 1489 signers(70.90%) (13254ms)
Gas cost: 12031366, tx: 0x35d6d71aa2bdb46a77cd8d729de3ae68f37029dc04db12d92843b072557de00f
      ✓ epoch(69): 2000 identities -200 +200 by 1718 signers(85.90%) (14899ms)
Gas cost: 7151739, tx: 0x974ad9f68a4ac4c2403e00e9468338c23a5dc193b71f06fdd18c7fd5f35260f0
      ✓ epoch(70): 2000 identities -300 +100 by 1481 signers(74.05%) (14063ms)
Gas cost: 10447990, tx: 0xe2e7a0c34d6e7adfc4e35d28b02e36ce8ddda1afa5238251733e935005921636
      ✓ epoch(71): 1800 identities -300 +200 by 1636 signers(90.89%) (17135ms)
      1) epoch(72): 1700 identities -300 +250 by 1426 signers(83.88%)
    > No events were emitted


  29 passing (5m)
  1 failing

  1) Contract: IdenaWorldState
       > update
         epoch(72): 1700 identities -300 +250 by 1426 signers(83.88%):
     AssertionError: expected promise to be fulfilled but it was rejected with 'Error: Returned error: VM Exception while processing transaction: out of gas'
