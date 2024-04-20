pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract StakingContract {
    address public admin;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public lastStakeTime;
    uint256 public constant MIN_LOCKUP_PERIOD = 30 days; // Minimum lock-up period in seconds

    // Token addresses
    address public stETHAddress;
    address public cbETHAddress;
    address public bethAddress;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _admin, address _stETHAddress, address _cbETHAddress, address _bethAddress) {
        admin = _admin;
        stETHAddress = _stETHAddress;
        cbETHAddress = _cbETHAddress;
        bethAddress = _bethAddress;
    }

    function stake(uint256 amount, address tokenAddress) external {
        require(tokenAddress == stETHAddress || tokenAddress == cbETHAddress || tokenAddress == bethAddress, "Invalid token address");

        // Transfer tokens from user to contract
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Update staked amount and last stake time
        stakedAmounts[msg.sender] += amount;
        lastStakeTime[msg.sender] = block.timestamp;
    }

    function withdraw() external {
        require(stakedAmounts[msg.sender] > 0, "No staked amount");
        require(block.timestamp >= lastStakeTime[msg.sender] + MIN_LOCKUP_PERIOD, "Minimum lock-up period not reached");

        // Transfer staked tokens back to user
        uint256 amount = stakedAmounts[msg.sender];
        stakedAmounts[msg.sender] = 0;
        require(IERC20(stETHAddress).transfer(msg.sender, amount), "Transfer failed");

        // Reset rewards
        rewards[msg.sender] = 0;
    }

    function claimReward() external {
        uint256 timeStaked = block.timestamp - lastStakeTime[msg.sender];
        uint256 reward = timeStaked * 1; // Reward rate, adjust as needed
        rewards[msg.sender] += reward;
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function setTokenAddresses(address _stETHAddress, address _cbETHAddress, address _bethAddress) external onlyAdmin {
        stETHAddress = _stETHAddress;
        cbETHAddress = _cbETHAddress;
        bethAddress = _bethAddress;
    }
}
