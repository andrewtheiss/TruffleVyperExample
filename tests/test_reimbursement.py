#version ^0.3.8
import pytest
import brownie

DEFAULT_GAS = 210000

# . This runs before ALL tests
@pytest.fixture
def reimbursementContract(Reimbursement, accounts):
    return Reimbursement.deploy(accounts[1], {'from': accounts[0]})

def _as_wei_value(base, conversion):
    if conversion == "wei":
        return base
    if conversion == "gwei":
        return base * 10 ** 9
    return base * 10 ** 18

def test_contractDeployment(reimbursementContract, accounts):
    assert reimbursementContract.getAdmin(accounts[0]) == True, "Contract creator should be a admin"
    assert reimbursementContract.getAdmin(accounts[1]) == True, "Contract constructor should enter a single admin"
    assert reimbursementContract.getAdmin(accounts[2]) == False, "Random accounts should not be admins"

def test_canAddAdmin(reimbursementContract, accounts):   
    assert reimbursementContract.getAdmin(accounts[3]) == False, "User should not be admin before test"
    reimbursementContract.addAdmin(accounts[3],  {'from': accounts[0]})
    assert reimbursementContract.getAdmin(accounts[3]) == True, "Contract constructor should add an single admin"

def test_canSetGradYear(reimbursementContract, accounts):
    txn1 = reimbursementContract.setCurrentGradYear(2023)
    assert len(txn1.events) == 1
    assert reimbursementContract.currentGradYear() == 2023

def test_canAddUser(reimbursementContract, accounts):
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addUser(accounts[4],  {'from': accounts[1]})
    assert reimbursementContract.getUserGradYear(accounts[4]) == 2023

def test_canReceiveMoney(reimbursementContract, accounts):
    depositAmount = 1
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    accounts[2].transfer(reimbursementContract, depositAmount, gas_price=0)
    assert reimbursementContract.balance() == (depositAmount * 2), "Contract should be able to receive money"

# @Notice Relies on 'canAddUser'
def test_canReimburseMoney(reimbursementContract, accounts):
    # Add money, set grad year, and an active user
    targetReimbursementAccount = accounts[4]
    # https://vyper.readthedocs.io/en/stable/built-in-functions.html?highlight=send#send
    # send uses wei value to send to the address
    txnGasPriceToRepay = _as_wei_value(800577, "gwei")
    depositAmount = _as_wei_value(0.01, "eth")
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    assert reimbursementContract.balance() == depositAmount, "Contract should have eth"
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addUser(targetReimbursementAccount,  {'from': accounts[1]})
    txn1 = reimbursementContract._reimburseGas(targetReimbursementAccount, {'from': targetReimbursementAccount, 'gas_price' : txnGasPriceToRepay, 'gas' : DEFAULT_GAS})
    assert reimbursementContract.balance() < depositAmount, "Contract should have sent eth"
    
    # Verify log is correct
    assert len(txn1.events) == 1
    assert txn1.events[0]['recipient'] == targetReimbursementAccount
    assert txn1.events[0]['amount'] == txnGasPriceToRepay
    assert reimbursementContract.balance() == (depositAmount - txnGasPriceToRepay)

# TODO- adjust this for 'internal' contract calls
# @Notice Relies on 'canAddUser', and 'canReimburseMoney'
def test_userHitMaxReimbursement(reimbursementContract, accounts):
    adminAccount = accounts[1]
    targetReimbursementAccount = accounts[4]
    depositAmount = _as_wei_value(0.011, "ether")
    totalReimbursementAllowed = _as_wei_value(0.01, "ether")

    # Add money, set grad year, and an active user
    accounts[0].transfer(reimbursementContract, depositAmount, gas_price=0)
    reimbursementContract.setCurrentGradYear(2023)
    reimbursementContract.addUser(targetReimbursementAccount,  {'from': adminAccount})
    txn1 = reimbursementContract.setUserIndividualWeiReimbursementCap(totalReimbursementAllowed, {'from': adminAccount, 'gas_price' : 2100, 'gas' : DEFAULT_GAS})
    txn2 = reimbursementContract._reimburseGas(targetReimbursementAccount, {'from': targetReimbursementAccount, 'gas_price' : 2100, 'gas' : DEFAULT_GAS})
    assert len(txn2.events) == 1
    #assert reimbursementContract.balance() < depositAmount, "Contract should have sent eth"
    #assert reimbursementContract.getGweiReimbursed(True, {'from':targetReimbursementAccount}) < 0
    assert reimbursementContract.balance() < depositAmount, "Contract should have sent eth"
    #assert txn1.events[0]['recipient'] == targetReimbursementAccount

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
Disable or enable the contract
Get Teachers
"""