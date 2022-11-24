#version ^0.3.8
import pytest
import brownie

# . This runs before ALL tests
@pytest.fixture
def reimbursementContract(Reimbursement, accounts):
    return Reimbursement.deploy(accounts[1], {'from': accounts[0]})

def test_contractDeployment(reimbursementContract, accounts):
    assert reimbursementContract.getTeacher(accounts[0]) == True, "Contract creator should be a teacher"
    assert reimbursementContract.getTeacher(accounts[1]) == True, "Contract constructor should enter a single teacher"
    assert reimbursementContract.getTeacher(accounts[2]) == False, "Random accounts should not be teachers"

def test_canReceiveMoney(reimbursementContract, accounts):
    depositAmount = "0.1 ether"
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    assert reimbursementContract.balance() == depositAmount, "Contract should be able to receive money"

def test_canReimburseMoney(reimbursementContract, accounts):
    return