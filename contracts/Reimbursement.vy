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

event TeacherAdded:
    teacher: address
    label: String[10]

event Payment:
    sender: indexed(address)
    amount: uint256
    bal: uint256

# interface with ERC20 Wolvercoin
interface Wolvercoin:
    def mint(_to:address , _value: uint256): nonpayable
    def test1(): nonpayable

@external
def __init__(firstTeacher: address):
    self.disabled = False
    self.admin = msg.sender
    self.studentIncomeAllowance = 10

    self.teachers[msg.sender] = True
    log TeacherAdded(msg.sender, "contruct")

    self.teachers[firstTeacher] = True
    log TeacherAdded(firstTeacher, "contruct2")


# @note Default function is executed on a call to the contract if a non-existing function is called
# or if none is supplied at all, such as when someone sends it Eth directly
# @note Payable functions can receive Ether and read from and write to the contract state
@external
@payable
def __default__():
    log Payment(msg.sender, msg.value, self.balance)

@external
def addTeacher(teacherToAdd: address) -> (bool):
    assert not self.disabled
    # only allow teachers to add another user
    assert self.teachers[msg.sender] == True

    # add the teacher
    self.teachers[teacherToAdd] = True

    log TeacherAdded(teacherToAdd, "addTeachFn")
    return True

@external
def addUserByGraduationDate(studentToAdd: address, graduationYear: uint256) -> (bool):
    assert not self.disabled
    # only allow teachers to add another user
    assert self.teachers[msg.sender] == True
    self.studentGraduationYear[studentToAdd] = self.currentGradYear
    return True


@external
def bulkMintToken(wolvercoin: Wolvercoin, users: address[5]):
    assert not self.disabled
    for i in range(5):
        if users[i] != empty(address):
            wolvercoin.mint(users[i], self.studentIncomeAllowance)

@external
@payable
def refund(recipient: address):
    # .
    # . assert Recipient is a current student
    # . assert this contract has enough money to reimburse the student
    # 
    assert self.studentGraduationYear[recipient] == self.currentGradYear

    if self.balance >= msg.gas:

        send(msg.sender, tx.gasprice)
        log GasReimburse(recipient, tx.gasprice)
        return

 #   function sendValue(address payable recipient, uint256 amount) internal {
 #       require(address(this).balance >= amount, "Address: insufficient balance");

 #       (bool success, ) = recipient.call{value: amount}("");
 #       require(success, "Address: unable to send value, recipient may have reverted");
 #   }

@external
@view
def getTeachers(teacherAddress: address) -> bool:
    assert not self.disabled
    assert self.teachers[msg.sender] == True
    return self.teachers[teacherAddress]

@external
def setContractState(_disabled: bool):
    assert self.admin == msg.sender
    self.disabled = _disabled

@external
@view
def getTeacher(_teacher: address) -> bool:
    return self.teachers[_teacher]
