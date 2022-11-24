# @version ^0.3.7

# look into interface import https://vyper.readthedocs.io/en/stable/interfaces.html

# TODO - Grab the following from other contracts via an interface
studentGraduationYear: HashMap[address, uint256]
currentGradYear: public(uint256)
users: public(HashMap[address, uint256])
teachers: public(HashMap[address, bool])
studentIncomeAllowance: uint256
admin: address
disabled: bool
# Payable from solidity
 #   address payable public seller;

#    constructor() {
#        seller = payable(msg.sender);
#    }

 #   // Wins the auction for the specified amount
 #   function win() external payable {
 #       winner = msg.sender;
 #       nft.safeTransferFrom(address(this), msg.sender, nftId);
 #       seller.transfer(msg.value);

 #       emit Win(msg.sender, msg.value);
 #   }

 #  ** Proposal for all sub-contracts to have a disable interface **
 #
 #

event GasReimburse:
    recipient: address
    amount: uint256

event OutOfGas:
    recipient: address
    amount: uint256


event TeacherAdded:
    teacher: address
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
def __init__(firstTeacher: address):
    """
        @notice Sets the reimburesement and refund contract
        @param firstTeacher is a mandatory teacher address
    """
    assert firstTeacher != ZERO_ADDRESS
    self.disabled = False
    self.admin = msg.sender
    self.studentIncomeAllowance = 10

    self.teachers[msg.sender] = True
    log TeacherAdded(msg.sender, "contruct")

    self.teachers[firstTeacher] = True
    log TeacherAdded(firstTeacher, "contruct2")


@external
@payable
def __default__():
    """
        @notice Default function is executed on a call to the contract if a non-existing function is called
        or if none is supplied at all, such as when someone sends it Eth directly
        Payable functions can receive Ether and read from and write to the contract state
    """
    log Payment(msg.sender, msg.value, self.balance)


#   @note AddTeacher function adds a new teacher and can only be called by active teachers
@external
def addTeacher(teacherToAdd: address):
    assert not self.disabled, "This contract is no longer active"
    assert self.teachers[msg.sender] == True, "You need to be a teacher to add a teacher."
    self.teachers[teacherToAdd] = True
    log TeacherAdded(teacherToAdd, "addTeachFn")


@external
def addStudent(studentToAdd: address):
    assert not self.disabled, "This contract and its features are disabled"
    # only allow teachers to add another user
    assert self.teachers[msg.sender] == True, "Only teachers can add active students"
    self.studentGraduationYear[studentToAdd] = self.currentGradYear

@external
def bulkMintToken(wolvercoin: Wolvercoin, users: address[5]):
    assert not self.disabled
    for i in range(5):
        if users[i] != empty(address):
            wolvercoin.mint(users[i], self.studentIncomeAllowance)

@external
def refund(recipient: address):
    """
        @notice refund refunds the user gas
        @param  recipient address to refund
        Verify they are:
            - A current student
            - TODO: Have fewer than REIMBURSEMENT_COUNT reimbursements
            - Contract has enough Wei to reimburse
            - ** TODO: Record total reimbursement amount
    """
    assert self.studentGraduationYear[recipient] == self.currentGradYear

    if self.balance >= (tx.gasprice):
        send(recipient, tx.gasprice)
        log GasReimburse(recipient, tx.gasprice)
        return

    log OutOfGas(recipient, tx.gasprice)


@external
def setContractState(disabled: bool):
    assert self.admin == msg.sender
    self.disabled = disabled

@external
@view
def getTeacher(teacher: address) -> bool:
    return self.teachers[teacher]

@external
@view
def getStudentGradYear(student: address) -> uint256:

    return self.studentGraduationYear[student]

@external
def setCurrentGradYear(year: uint256):
    assert self.teachers[msg.sender] == True, "Only teachers can add active students"
    self.currentGradYear = year
    log SetGradYear(msg.sender, year)