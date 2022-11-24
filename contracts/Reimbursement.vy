# @version ^0.3.7
currentGradYear: public(uint256)
userGraduationYear: HashMap[address, uint256]

userCoinAllowance: public(uint256)
userCoinAllowanceToPayout: public(HashMap[address, uint256])

userIndividualGweiReimbursementCap: public(uint256)
userGweiReimbursed: HashMap[address, uint256]

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
    amount: uint256

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

# interface with ERC20 Wolvercoin
interface Wolvercoin:
    def mint(_to:address , _value: uint256): nonpayable
    def test1(): nonpayable


@external
def __init__(initialAdmin: address):
    """
        @notice Sets the reimburesement and refund contract
        @param initialAdmin is a mandatory admin address
    """
    assert initialAdmin != empty(address)
    self.disabled = False
    self.owner = msg.sender
    self.userCoinAllowance = 10
    self.userIndividualGweiReimbursementCap = 210000

    self.admins[msg.sender] = True
    self.admins[initialAdmin] = True

    log AdminAdded(msg.sender, "init owner")
    log AdminAdded(initialAdmin, "init admin")


@external
@payable
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
    assert adminToAdd != empty(address), "Cannot add the 0 address as admin"
    assert not self.disabled, "This contract is no longer active"
    assert self.admins[msg.sender] == True, "You need to be a teacher to add a teacher."
    self.admins[adminToAdd] = True
    log AdminAdded(adminToAdd, "add admin")


@external
def addUser(userToAdd: address):
    assert not self.disabled, "This contract and its features are disabled"
    assert userToAdd != empty(address), "Cannot add the 0 address as a user"
    assert self.admins[msg.sender] == True, "Only admins can add active users"
    self.userGraduationYear[userToAdd] = self.currentGradYear


@external
def bulkMintToken(wolvercoin: Wolvercoin, users: address[5]):
    assert not self.disabled
    for i in range(5):
        if users[i] != empty(address):
            wolvercoin.mint(users[i], self.userCoinAllowance)


# TODO: make internal..
@external
def refund(recipient: address):
    """
        @notice refund the user gwei
        @param  recipient address to refund
          Verifies they are a current user, will fail WHOLE TXN if they aren't
          Checks contract has enough Wei to reimburse
          Records total per-user reimbursement amount
    """
    assert self.userGraduationYear[recipient] == self.currentGradYear
    
    if self.balance <= tx.gasprice:
        log ContractOutOfGas(recipient, tx.gasprice)
        return

    if self.userIndividualGweiReimbursementCap > (self.userGweiReimbursed[recipient] + tx.gasprice):
        self.userGweiReimbursed[recipient] += tx.gasprice
        send(recipient, tx.gasprice)
    
    log GasReimburse(
        recipient, 
        tx.gasprice,
        self.userIndividualGweiReimbursementCap, 
        self.userGweiReimbursed[recipient]
    )



@external
def setContractState(disabled: bool):
    assert self.owner == msg.sender
    self.disabled = disabled

@external
@view
def getAdmin(userToCheck: address) -> bool:
    return self.admins[userToCheck]

@external
def setCurrentGradYear(year: uint256):
    assert self.admins[msg.sender] == True, "Only admins can add active students"
    self.currentGradYear = year
    log SetGradYear(msg.sender, year) 

@external
@view
def getUserGradYear(student: address) -> uint256:
    return self.userGraduationYear[student]
