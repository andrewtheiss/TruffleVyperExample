const Reimbursement = artifacts.require("Reimbursement");

contract("Reimbursement", (accounts) => {
  it("...should make the deployer a teacher.", async () => {

    const accountOne = accounts[0];
    const reimbursement = await Reimbursement.deployed();

    reimbursement.addTeacher(accounts[1]);
    // Set value of 89
    //await storage.set(89);

    // Get stored value
   // const isTeacher = await reim;


   //assert.equal(reimbursement.teachers[accountOne], null, "The contract deployer is a teacher.");


    // Get stored value
    const storedData = await reimbursement.getIsTeacher();
    console.log(storedData);
   assert.equal(storedData, true, "The contract deployer is a teacher... ");
  });
});
