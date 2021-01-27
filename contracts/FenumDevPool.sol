// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
}

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IFenumVesting {
  function drawDown() external returns (bool);
}


contract FenumDevPool {
  using SafeMath for uint256;
  address[] private _approvers;
  uint256 private _threshold;
  address private _vesting;

  struct Transfer {
    uint256 id;
    uint256 approvals;
    bool sent;
    address token;
    uint256 amount;
    address payable to;
  }

  Transfer[] private _transfers;
  mapping(address => mapping(uint256 => bool)) private _approvals;

  event TransferCreated(uint256 indexed id, uint256 approvals, bool sent, address indexed token, uint256 amount, address indexed to);
  event TransferExecuted(uint256 indexed id, uint256 approvals, bool sent, address indexed token, uint256 amount, address indexed to);
  event ApprovershipTransferred(address indexed previousApprover, address indexed newApprover);

  constructor(address[] memory approvers_, uint threshold_, address vesting_) public {
    _approvers = approvers_;
    _threshold = threshold_;
    _vesting = vesting_;     // VESTING_ADDRESS
  }

  function balance(address token) public view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  function vesting() public view returns (address) {
    return _vesting;
  }

  function vestingDrawDown() public {
    IFenumVesting(_vesting).drawDown();
  }

  function threshold() public view returns(uint256) {
    return _threshold;
  }

  function approver(uint256 id) public view returns(address) {
    return _approvers[id];
  }

  function approvers() public view returns(address[] memory) {
    return _approvers;
  }

  function approversLength() public view returns (uint256) {
    return _approvers.length;
  }

  function transfer(uint256 id) public view returns(Transfer memory) {
    return _transfers[id];
  }

  function transfers() public view returns(Transfer[] memory) {
    return _transfers;
  }

  function transfersLength() public view returns (uint256) {
    return _transfers.length;
  }

  function createTransferETH(uint256 amount, address payable to) external onlyApprover returns (uint256) {
    return _createTransfer(address(0), amount, to);
  }

  function createTransferERC20(address token, uint256 amount, address payable to) external onlyApprover returns (uint256) {
    return _createTransfer(token, amount, to);
  }

  function approveTransfer(uint256 id) public onlyApprover returns (bool) {
    address msgSender = _msgSender();
    require(_transfers[id].sent == false, "FenumDevPool: Transfer has already sent");
    require(_approvals[msgSender][id] == false, "FenumDevPool: Cannot approve transfer twice");
    _approvals[msgSender][id] = true;
    _transfers[id].approvals = _transfers[id].approvals.add(1);
    return true;
  }

  function executeTransfer(uint256 id) public onlyApprover returns (bool) {
    if (_transfers[id].approvals >= _threshold) {
      if (_transfers[id].token == address(0)) {
        require(_executeTransferETH(id), "FenumDevPool: Failed to transfer Ethers");
      } else {
        require(_executeTransferERC20(id), "FenumDevPool: Failed to transfer ERC20 tokens");
      }
      _transfers[id].sent = true;
      emit TransferExecuted(_transfers[id].id, _transfers[id].approvals, _transfers[id].sent, _transfers[id].token, _transfers[id].amount, _transfers[id].to);
      return true;
    }
    return false;
  }

  function transferApprovership(address newApprover) public virtual {
    require(newApprover != address(0), "FenumDevPool: New approver is the zero address");
    (bool allowed, uint256 index) = _approverIndex(_msgSender());
    require(allowed == true, "FenumDevPool: Only approver allowed");
    _approvers[index] = newApprover;
    emit ApprovershipTransferred(_approvers[index], newApprover);
  }

  function _createTransfer(address token, uint256 amount, address payable to) internal returns (uint256) {
    require(to != address(0), "FenumDevPool: to is the zero address");
    require(amount > 0, "FenumDevPool: amount must be greater than 0");
    uint256 id = _transfers.length;
    _transfers.push(Transfer(id, 0, false, token, amount, to));
    emit TransferCreated(id, 0, false, token, amount, to);
    return id;
  }

  function _executeTransferETH(uint256 id) internal returns (bool) {
    return _transfers[id].to.send(_transfers[id].amount);
  }

  function _executeTransferERC20(uint256 id) internal returns (bool) {
    return IERC20(_transfers[id].token).transfer(_transfers[id].to, _transfers[id].amount);
  }

  function _approverIndex(address approver) internal view returns (bool, uint256) {
    bool found = false;
    uint256 index = 0;
    for (uint256 i = 0; i < _approvers.length; i = i.add(1)) {
      if (_approvers[i] == approver) {
        found = true;
        index = i;
        break;
      }
    }
    return (found, index);
  }

  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  modifier onlyApprover() {
    (bool allowed, ) = _approverIndex(_msgSender());
    require(allowed == true, "FenumDevPool: Only approver allowed");
    _;
  }

  receive() external payable { }

  fallback() external {
    revert("FenumDevPool: contract action not found");
  }
}
