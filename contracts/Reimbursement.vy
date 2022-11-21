# look into interface import https://vyper.readthedocs.io/en/stable/interfaces.html

# TODO - Grab the following from other contracts via an interface
studentGraduationYear: HashMap[address, uint256]
currentGradYear: public(uint256)
users: public(HashMap[address, uint256])
teachers: HashMap[address, bool]
allowance: uint256
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

event GasReimburse:
    recipient: address
    amount: uint256

# interface with ERC20 Wolvercoin
interface Wolvercoin:
    def mint(_to:address , _value: uint256): nonpayable
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
    # .
    # . assert Recipient is a current student
    # . assert this contract has enough money to reimburse the student
    # 
    assert self.studentGraduationYear[recipient] == self.currentGradYear

    if self.balance >= msg.gas:

        send(msg.sender, tx.gasprice)
        log GasReimburse(recipient, tx.gasprice)
        return
    
@external
@payable
def depositMoneyToContract() -> bool:
    return True


 #   function sendValue(address payable recipient, uint256 amount) internal {
 #       require(address(this).balance >= amount, "Address: insufficient balance");

 #       (bool success, ) = recipient.call{value: amount}("");
 #       require(success, "Address: unable to send value, recipient may have reverted");
 #   }

