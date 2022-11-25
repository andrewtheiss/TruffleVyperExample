# @version ^0.3.7
currentGradYear: public(uint256)
userGraduationYear: HashMap[address, uint256]

userIndividualWeiReimbursementCap: public(uint256)
userWeiReimbursed: HashMap[address, uint256]
WEI_REIMBURSEMENT_BUFFER: constant(uint256) = as_wei_value(0.0005, "ether")

admins: public(HashMap[address, bool])
owner: address
disabled: bool

event GasReimburse:
    recipient: address
    amount: uint256
    maxAllowed: uint256
    totalReimbursed: uint256

event ContractOutOfGas:
    recipient: address
    amountNotReimbursed: uint256

event AdminAdded:
    admin: address
    label: String[10]

event Payment:
    sender: indexed(address)
    amount: uint256
    bal: uint256

event SetGradYear:
    user: address
    year: uint256

@external
def __init__(initialAdmin: address):
    """
        @notice Sets the reimburesement and reimburseGas contract
        @param initialAdmin is a mandatory admin address
    """
    assert initialAdmin != empty(address)
    self.disabled = False
    self.owner = msg.sender
    self.userIndividualWeiReimbursementCap = as_wei_value(0.01, "ether")

    self.admins[msg.sender] = True
    self.admins[initialAdmin] = True

    log AdminAdded(msg.sender, "init owner")
    log AdminAdded(initialAdmin, "init admin")


@payable
@external
def __default__():
    """
        @notice Default function is executed on a call to the contract if a non-existing function is called
        or if none is supplied at all, such as when someone sends it Eth directly
        Payable functions can receive Ether and read from and write to the contract state
    """
    log Payment(msg.sender, msg.value, self.balance)


@external
def addAdmin(adminToAdd: address):
    """
        @notice addAdmin function adds a new admin
        @param  adminToAdd is the admin to input
        can only be called by existing admin / owner
    """
    assert not self.disabled, "This contract is no longer active"
    assert adminToAdd != empty(address), "Cannot add the 0 address as admin"
    assert self.admins[msg.sender] == True, "You need to be a teacher to add a teacher."
    self.admins[adminToAdd] = True
    log AdminAdded(adminToAdd, "add admin")


@external
def addUser(userToAdd: address):
    assert not self.disabled, "This contract and its features are disabled"
    assert userToAdd != empty(address), "Cannot add the 0 address as a user"
    assert self.admins[msg.sender] == True, "Only admins can add active users"
    self.userGraduationYear[userToAdd] = self.currentGradYear

@internal
def _reimburseGas(recipient: address, amount: uint256):
    """
        @notice reimburse the user wei
        @param  recipient address to reimburse
          Verifies they are a current user
          Checks contract has enough Wei to reimburse
          Records total per-user reimbursement amount
          Need to grab msg.gas before and msg.gas after to find amount
    """
    assert not self.disabled, "This contract and its features are disabled"

    # Will not reimburse graduates...
    if self.userGraduationYear[recipient] != self.currentGradYear:
        return
    
    if self.balance < (WEI_REIMBURSEMENT_BUFFER + amount):
        log ContractOutOfGas(recipient, amount)
        return

    if self.userIndividualWeiReimbursementCap >= (self.userWeiReimbursed[recipient] + amount):
        self.userWeiReimbursed[recipient] += amount
        send(recipient, amount)
    
    log GasReimburse(
        recipient, 
        amount,
        self.userIndividualWeiReimbursementCap, 
        self.userWeiReimbursed[recipient]
    )


@external
def reimburseGas(recipient: address):
    self._reimburseGas(recipient, tx.gasprice)


@external
def setDisableContract(disabled: bool):
    assert self.owner == msg.sender
    self.disabled = disabled


@view
@external
def getAdmin(userToCheck: address) -> bool:
    return self.admins[userToCheck]


@external
def setCurrentGradYear(year: uint256):
    assert not self.disabled, "This contract and its features are disabled"
    assert self.admins[msg.sender] == True, "Only admins can add active students"
    self.currentGradYear = year
    log SetGradYear(msg.sender, year) 


@view
@external
def getUserGradYear(student: address) -> uint256:
    return self.userGraduationYear[student]


@external
def setUserIndividualWeiReimbursementCap(cap: uint256):
    assert not self.disabled, "This contract and its features are disabled"
    assert self.admins[msg.sender] == True, "Only admins can add active students"
    self.userIndividualWeiReimbursementCap = cap


@view
@external
def getWeiReimbursed(dummy: bool) -> uint256:
    return self.userWeiReimbursed[msg.sender]


@view
@external
def getUserInidividualWeiReimbursementCap() -> uint256:
    return self.userIndividualWeiReimbursementCap
