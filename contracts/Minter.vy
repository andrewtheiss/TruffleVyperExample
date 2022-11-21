# look into interface import https://vyper.readthedocs.io/en/stable/interfaces.html

studentGraduationYear: HashMap[address, uint256]
currentGradYear: public(uint256)
users: public(HashMap[address, uint256])
teachers: HashMap[address, bool]
allowance: uint256

# interface with ERC20 Wolvercoin
interface Wolvercoin:
    def  mint(_to:address , _value: uint256): nonpayable
    def test1(): nonpayable

@external
def __init__():
    self.teachers[msg.sender] = True
    self.allowance = 10

@external
def addTeacher(teacherToAdd: address) -> (bool):
    # only allow teachers to add another user
    assert self.teachers[msg.sender] == True

    # add the teacher
    self.teachers[teacherToAdd] = True
    return True

@external
def addUserByGraduationDate(studentToAdd: address, graduationYear: uint256) -> (bool):
    # only allow teachers to add another user
    assert self.teachers[msg.sender] == True
    self.studentGraduationYear[studentToAdd] = self.currentGradYear
    return True


@external
def bulkMintToken(wolvercoin: Wolvercoin, users: address[5]):
    for i in range(5):
        if users[i] != empty(address):
            wolvercoin.mint(users[i], self.allowance)

@external
@payable
def refund(recipient: address):
    recipientToCheck: address = recipient
    assert self.studentGraduationYear[msg.sender] == self.currentGradYear

    # ensure there is enough wei to pay
    assert self.balance >= msg.gas
    
@external
@payable
def depositMoneyToContract() -> bool:
    return True


 #   function sendValue(address payable recipient, uint256 amount) internal {
 #       require(address(this).balance >= amount, "Address: insufficient balance");

 #       (bool success, ) = recipient.call{value: amount}("");
 #       require(success, "Address: unable to send value, recipient may have reverted");
 #   }
