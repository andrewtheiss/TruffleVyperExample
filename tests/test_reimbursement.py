#version ^0.3.8
import pytest
import brownie
import web3
from web3 import Web3, EthereumTesterProvider

# . This runs before ALL tests
@pytest.fixture
def reimbursementContract(Reimbursement, accounts):
    return Reimbursement.deploy(accounts[1], {'from': accounts[0]})

def test_contractDeployment(reimbursementContract, accounts):
    assert reimbursementContract.getTeacher(accounts[0]) == True, "Contract creator should be a teacher"
    assert reimbursementContract.getTeacher(accounts[1]) == True, "Contract constructor should enter a single teacher"
    assert reimbursementContract.getTeacher(accounts[2]) == False, "Random accounts should not be teachers"

def test_canAddTeacher(reimbursementContract, accounts):

    return

def test_canSetGradYear(reimbursementContract, accounts):
    txn1 = reimbursementContract.setCurrentGradYear(2023)
    assert len(txn1.events) == 1
    assert reimbursementContract.currentGradYear() == 2023

def test_canAddStudent(reimbursementContract, accounts):
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addStudent(accounts[4],  {'from': accounts[1]})
    assert reimbursementContract.getStudentGradYear(accounts[4]) == 2023

def test_canReceiveMoney(reimbursementContract, accounts):
    depositAmount = 1
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    accounts[2].transfer(reimbursementContract, depositAmount, gas_price=0)
    assert reimbursementContract.balance() == (depositAmount * 2), "Contract should be able to receive money"

def test_canReimburseMoney(reimbursementContract, accounts):
    # Add money, set grad year, and an active student
    depositAmount = 1
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addStudent(accounts[4],  {'from': accounts[1]})

    assert reimbursementContract.getStudentGradYear(accounts[4]) == 2023
    assert reimbursementContract.balance() == depositAmount, "Contract should be able to receive money"
    
    reimbursementContract.refund(accounts[4], {'from': accounts[4]})
    # TODO - Fix this test
    #assert reimbursementContract.balance() < depositAmount, "Contract should be able to receive money"

# Test for the following
"""
Refund people money
Add other teachers
Disable or enable the contract
Get Teachers
"""