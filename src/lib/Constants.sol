pragma solidity ^0.8.17;

library Constants { 
    uint256 public constant NO_BOOST = 10 ** 18;
    uint256 public constant BOOST_UP = 2 * 10 ** 18;
    uint256 public constant BOOST_DOWN = 5 * 10 ** 17;

    uint256 public constant UNIT = 10 ** 18;

    uint256 public constant THRESHOLD_UP = 70;
    uint256 public constant THRESHOLD_DOWN = 30;
}
