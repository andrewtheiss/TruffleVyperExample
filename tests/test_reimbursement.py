#version ^0.3.8
import pytest
import brownie
import web3

# . This runs before ALL tests
@pytest.fixture
def reimbursementContract(Reimbursement, accounts):
    return Reimbursement.deploy(accounts[1], {'from': accounts[0]})

def test_contractDeployment(reimbursementContract, accounts):
    assert reimbursementContract.getAdmin(accounts[0]) == True, "Contract creator should be a admin"
    assert reimbursementContract.getAdmin(accounts[1]) == True, "Contract constructor should enter a single admin"
    assert reimbursementContract.getAdmin(accounts[2]) == False, "Random accounts should not be admins"

def test_canAddTeacher(reimbursementContract, accounts):

    return

def test_canSetGradYear(reimbursementContract, accounts):
    txn1 = reimbursementContract.setCurrentGradYear(2023)
    assert len(txn1.events) == 1
    assert reimbursementContract.currentGradYear() == 2023

def test_canAddStudent(reimbursementContract, accounts):
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addUser(accounts[4],  {'from': accounts[1]})
    assert reimbursementContract.getUserGradYear(accounts[4]) == 2023

def test_canReceiveMoney(reimbursementContract, accounts):
    depositAmount = 1
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    accounts[2].transfer(reimbursementContract, depositAmount, gas_price=0)
    assert reimbursementContract.balance() == (depositAmount * 2), "Contract should be able to receive money"

def test_canReimburseMoney(reimbursementContract, accounts):
    # Add money, set grad year, and an active student
    targetReimbursementAccount = accounts[4]
    depositAmount = 100000
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addUser(targetReimbursementAccount,  {'from': accounts[1]})
    assert reimbursementContract.getUserGradYear(targetReimbursementAccount) == 2023
    assert reimbursementContract.balance() == depositAmount, "Contract should be able to receive money"
    
    txn1 = reimbursementContract.refund(targetReimbursementAccount, {'from': targetReimbursementAccount, 'gas_price' : 2100, 'gas' : 2100000})
    assert len(txn1.events) == 1
    assert reimbursementContract.balance() < depositAmount, "Contract should have sent eth"
    assert txn1.events[0]['recipient'] == targetReimbursementAccount

# TODO - test Gwei reimbusement cap is Gwei and not eth
# test too many reimbursements
# test too much reimbursed
# test contract out of eth to reimburse

"""
# This test works and fails...
def test_willOnlyReimburseStudents(reimbursementContract, accounts):
    # Add money, set grad year, and an active student
    depositAmount = 100000
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addStudent(accounts[3],  {'from': accounts[1]})

    assert reimbursementContract.getStudentGradYear(accounts[3]) == 2023
    assert reimbursementContract.balance() == depositAmount, "Contract should be able to receive money"
    
    txn1 = reimbursementContract.refund(accounts[0], {'from': accounts[0], 'gasPrice' : 10, 'gas' : 0.001})
    assert txn1.events[0]['success'] == False, "Should only reimburse active students"
"""
    

# Test for the following
"""
Add other teachers
Disable or enable the contract
Get Teachers
"""