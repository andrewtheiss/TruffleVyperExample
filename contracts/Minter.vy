
# @version ^0.3.7
userCoinAllowance: public(uint256)
userCoinAllowanceToPayout: public(HashMap[address, uint256])

admins: public(HashMap[address, bool])
owner: address
disabled: bool

# interface with ERC20 Wolvercoin
# TODO : import as ERC20
interface Wolvercoin:
    def mint(_to:address , _value: uint256): nonpayable
    def test1(): nonpayable



@external
def __init__(initialAdmin: address):
    """
        @notice Sets the WVC Minter contract
        @param initialAdmin is a mandatory admin address
    """
    assert initialAdmin != empty(address)
    self.disabled = False
    self.owner = msg.sender
    self.userCoinAllowance = 10



@external
def bulkMintToken(wolvercoin: Wolvercoin, users: address[5]):
    assert not self.disabled, "This contract and its features are disabled"
    assert self.admins[msg.sender] == True, "Only admins can add bulk mint coins"
    for i in range(5):
        if users[i] != empty(address):
            wolvercoin.mint(users[i], self.userCoinAllowance)

