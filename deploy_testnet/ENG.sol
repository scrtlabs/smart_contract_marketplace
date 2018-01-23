pragma solidity ^0.4.18;


/**
 * @title Enigma Token
 * @dev ERC20 Enigma Token (ENG)
 *
 * ENG Tokens are divisible by 1e8 (100,000,000) base
 * units referred to as 'Grains'.
 *
 * ENG are displayed using 8 decimal places of precision.
 *
 * 1 ENG is equivalent to:
 *   100000000 == 1 * 10**8 == 1e8 == One Hundred Million Grains
 *
 * 150 million ENG (total supply) is equivalent to:
 *   15000000000000000 == 150000000 * 10**8 == 1e17
 *
 * All initial ENG Grains are assigned to the creator of
 * this contract.
 *
 */
contract ENG{

  string public constant name = 'Enigma';                                      // Set the token name for display
  string public constant symbol = 'ENG';                                       // Set the token symbol for display
  uint8 public constant decimals = 8;                                          // Set the number of decimals for display
  uint256 public constant INITIAL_SUPPLY = 150000000;  // 150 million ENG specified in Grains
   address public test;
   mapping (address => mapping (address => uint256)) internal allowed;
   mapping(address => uint256) balances;
  /**
   * @dev SesnseToken Constructor
   * Runs only on initial contract creation.
   */
  function ENG() {
    totalSupply = INITIAL_SUPPLY;                               // Set the total supply
    balances[msg.sender] = INITIAL_SUPPLY;                      // Creator address is assigned all
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  /* Basic token */

  /* STANDRAD TOKEN */
 function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from]-_value;
    balances[_to] = balances[_to]+_value;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
    function approve(address _spender, uint256 _value) public returns (bool) {
    test1 = msg.sender;
    test2 = _spender;
    test3 = _value;
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
    function allowance(address _owner, address _spender) public constant returns (uint256) {
    return allowed[_owner][_spender];
  }
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  /**
   * @dev Transfer token for a specified address when not paused
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    test= msg.sender;
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender]-_value;
    balances[_to] = balances[_to]+_value;
    Transfer(msg.sender, _to, _value);
    return true;
  }
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
  /**
   * @dev Transfer tokens from one address to another when not paused
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender when not paused.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {
    return super.approve(_spender, _value);
  }
  function allowance(address _owner, address _spender) public constant returns (uint256) {
    return super.allowance(_owner,_spender);
  }


}