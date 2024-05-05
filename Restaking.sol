pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract StakingContract {
    address public admin;

    struct TokenData {
        uint256 stakedAmount;
        uint256 lastStakeTime;
        uint256 rewardPoints;
    }

    mapping(address => TokenData) public stEthData;
    mapping(address => TokenData) public cbEthData;
    mapping(address => TokenData) public bEthData;
    
    uint256 public constant MIN_LOCKUP_PERIOD = 30 days; // Minimum lock-up period in seconds

    // Token addresses
    address public stEthAddress;
    address public cbEthAddress;
    address public bEthAddress;
    uint256 public rewardRate;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _admin, address _stEthAddress, address _cbEthAddress, address _bEthAddress, uint256 _rewardRate) {
        admin = _admin;
        stEthAddress = _stEthAddress;
        cbEthAddress = _cbEthAddress;
        bEthAddress = _bEthAddress;
        rewardRate = _rewardRate;
    }

    function updateRewardPoints(address _user) public {
        TokenData storage DataStEth = stEthData[_user];
        TokenData storage DataCbEth = cbEthData[_user];
        TokenData storage DataBEth = bEthData[_user];
        if(DataStEth.stakedAmount != 0){
            uint256 timeStaked = block.timestamp - DataStEth.lastStakeTime;
             DataStEth.rewardPoints = (timeStaked * DataStEth.stakedAmount * rewardRate) / 1e18;
        }
        if(DataCbEth.stakedAmount != 0){
            uint256 timeStaked = block.timestamp - DataCbEth.lastStakeTime;
            DataCbEth.rewardPoints = (timeStaked * DataCbEth.stakedAmount * rewardRate) / 1e18;
        }
        if(DataBEth.stakedAmount != 0){
            uint256 timeStaked = block.timestamp - DataBEth.lastStakeTime;
            DataBEth.rewardPoints = (timeStaked * DataBEth.stakedAmount * rewardRate) / 1e18;
        }    
    } 

    function stakeStEth(uint256 amount) external {
        // Transfer stETH tokens from user to contract
        require(IERC20(stEthAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Update staked amount and last stake time
        stEthData[msg.sender].stakedAmount += amount;
        stEthData[msg.sender].lastStakeTime = block.timestamp;
        updateRewardPoints(msg.sender);
    }

    function stakeCbEth(uint256 amount) external {
        // Transfer cbETH tokens from user to contract
        require(IERC20(cbEthAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Update staked amount and last stake time
        cbEthData[msg.sender].stakedAmount += amount;
        cbEthData[msg.sender].lastStakeTime = block.timestamp;
        updateRewardPoints(msg.sender);
    }

    function stakeBEth(uint256 amount) external {
        // Transfer bETH tokens from user to contract
        require(IERC20(bEthAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Update staked amount and last stake time
        bEthData[msg.sender].stakedAmount += amount;
        bEthData[msg.sender].lastStakeTime = block.timestamp;
        updateRewardPoints(msg.sender);
    }

    function withdrawStEth(uint256 amount) external {
        TokenData storage data = stEthData[msg.sender];
        require(data.stakedAmount >= amount, "Insufficient staked amount");
        require(block.timestamp >= data.lastStakeTime + MIN_LOCKUP_PERIOD, "Minimum lock-up period not reached");

        // Transfer staked tokens back to user
        data.stakedAmount -= amount;
        updateRewardPoints(msg.sender);
        require(IERC20(stEthAddress).transfer(msg.sender, amount), "Transfer failed");
    }

    function withdrawCbEth(uint256 amount) external {

        TokenData storage data = cbEthData[msg.sender];
        require(data.stakedAmount >= amount, "Insufficient staked amount");
        require(block.timestamp >= data.lastStakeTime + MIN_LOCKUP_PERIOD, "Minimum lock-up period not reached");

        // Transfer staked tokens back to user
        data.stakedAmount -= amount;
        updateRewardPoints(msg.sender);
        require(IERC20(cbEthAddress).transfer(msg.sender, amount), "Transfer failed");
    }

    function withdrawBEth(uint256 amount) external {
        TokenData storage data = bEthData[msg.sender];
        require(data.stakedAmount >= amount, "Insufficient staked amount");
        require(block.timestamp >= data.lastStakeTime + MIN_LOCKUP_PERIOD, "Minimum lock-up period not reached");

        // Transfer staked tokens back to user
        data.stakedAmount -= amount;
        updateRewardPoints(msg.sender);
        require(IERC20(bEthAddress).transfer(msg.sender, amount), "Transfer failed");
    }

    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function setStEthAddress(address _stEthAddress) external onlyAdmin {
        stEthAddress = _stEthAddress;
    }

    function setCbEthAddress(address _cbEthAddress) external onlyAdmin {
        cbEthAddress = _cbEthAddress;
    }

    function setBEthAddress(address _bEthAddress) external onlyAdmin {
        bEthAddress = _bEthAddress;
    }

    
    function setRewardRate(uint256 _rewardRate) external onlyAdmin {
        rewardRate = _rewardRate;
    }
}
