# Test Results

## state

![state-tests.jpg](./resources/state-tests.jpg)

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
