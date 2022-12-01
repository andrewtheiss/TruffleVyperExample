# Prerequisites
> Prerequisites:
> You need two commands to use this:  vyper, python3.6+, brwonie and ganache
> 
> **Brownie Installation:**
>   This depends on which version of python you have installed. Full instructions can be found: https://eth-brownie.readthedocs.io/en/stable/install.html
>
> **Ganache Installation:**
> https://github.com/trufflesuite/ganache has a README with a full description of how install

# Installation
> **To install:**
>   To start you need to clone the repository, this can be done through any Git application (like GitKraken) or via the terminal command:
> > git clone https://github.com/andrewtheiss/VyperExample
>
> Once cloned (downloaded) you need to 'Change Directory' of your terminal to the VyperExample folder (using the 'cd' command): https://www.ibm.com/docs/en/aix/7.1?topic=directories-changing-another-directory-cd-command
>
> Supplemental installation instructions: https://www.youtube.com/watch?v=oo6YRNf3eZM 
>
> # Once in the VyperExample, we can run all the code by typing:
> **brownie test**




>  ##**Compiling Commands**
> > ** To compile Code**
> > brownie compile

# Testings Installation Instructions
> ** Python testing will show warnings by default**
> > To turn them off, modify the pytest.ini file as mentioned here: 
> https://docs.pytest.org/en/stable/how-to/capture-warnings.html

> TODO: install dependency
> > https://pypi.python.org/pypi/pytest_dependency 
> > @pytest.mark.dependency(depends=["test_canSetGradYear, test_canReceiveMoney"])


# Compile and generate ABI for deployment or UI testing 
>> vyper -f abi,bytecode,bytecode_runtime,ir,asm,source_map,method_identifiers ./contracts/Reimbursement.vy
