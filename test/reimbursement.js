const Reimbursement = artifacts.require("Reimbursement");

contract("Reimbursement", (accounts) => {
  it("...should make the deployer a teacher who can add other teachers (and not others).", async () => {

    // Create the contract as accounts[0]
    // Add accounts[1]
    const reimbursement = await Reimbursement.deployed();
    await reimbursement.addTeacher(accounts[1]);

    // Check that account 0,1 are teachers and that 2 is not
    const validTeacher1 = await reimbursement.getIsTeacher(accounts[0]);
    const validTeacher2 = await reimbursement.getIsTeacher(accounts[1]);
    const invalidTeacher1 = await reimbursement.getIsTeacher(accounts[2]);
    
    assert.equal(validTeacher1, true, "The contract deployer is a teacher... ");
    assert.equal(validTeacher2, true, "The added teacher was added correctly... ");
    assert.equal(invalidTeacher1, false, "Someone not added is not a teacher... ");
  });

  it("...should be payable and can receive money", async () => {
    const depositAmount = "10";
    const reimbursement = await Reimbursement.deployed();

    const currentBalance = await web3.eth.getBalance(reimbursement.address);
    assert.equal(0, currentBalance, "contract wei balance should be empty at inception");

    const currentAccount = accounts[0];
    assert.equal(currentAccount, "0x5C60bC4E3a17f15BB65189484FFde011931E21fe", "incorrect deafult account");

    // Test account balance pre-test
    web3.eth.defaultAccount = accounts[0];
    const contractBalanceOfAccount = await web3.eth.getBalance(accounts[0]);
    try {
    console.log(await reimbursement.deposit().send({from: currentAccount,
      value: "10"})); 
    } catch (e) {
        console.log(e);
    }
    /*.sendTransaction({
      from: currentAccount,
      value: "10"
    }));
    */
/*
    contract.methods.somFunc().send({from: ....})
.on('receipt', function(){
    ...
});*/
/*
    // using the promise
    await web3.eth.sendTransaction({
      from: "0x5C60bC4E3a17f15BB65189484FFde011931E21fe",
      to: reimbursement.address,
      value: depositAmount
    });
*/
  //  const contractBalanceOfAccountAfterTransfer = await web3.eth.getBalance(reimbursement.address);
  //  assert.equal(contractBalanceOfAccountAfterTransfer, depositAmount, "contract should have a balance");


    /*
    send transaction
    instance.sendTransaction({...}).then(function(result) {
  // Same transaction result object as above.
});
*/
});

/*
it("...should reimburse a user for most of the gas tx cost", async () => {

    const reimbursement = await Reimbursement.deployed();

    // Pay the contract so it has some $$$
});
*/

// it("...should create a placeholder for other tests. LOL.", async () => {});

});
