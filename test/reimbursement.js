const Reimbursement = artifacts.require("Reimbursement");

contract("Reimbursement", (accounts) => {
  it("...should make the deployer a teacher.", async () => {

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
});
