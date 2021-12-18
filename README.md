#### DCPP (Decentralized Confidential Payment Protocol) is a confidential payment solution that integrates hardware and software to achieve better efficiency and security. The software component is based on the smart contract named ZSC that is deployed at HPB blockchain. 

#### The hardware component is combined with the unique BOE acceleration chip of HPB, allowing the fast execution of zero-knowledge proof algorithms. DCPP provides confidential tokens with the ElGamal public key as an account, which serves as the carrier for HPB confidential transactions. DCPP-hardware is the partial implementation of BOE, which realizes the acceleration of on-chain verification of zero-knowledge proof protocols.

#### The code structure is as follows:


#### --boe_top                           
#### &emsp; | &emsp; --eth  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;            ethernet packet 
#### &emsp; | &emsp; --fap  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;            function accelerate processer
#### &emsp;&emsp;&emsp;&emsp;| &emsp; --proof &emsp;&emsp;&emsp;  proof module
#### &emsp; | &emsp; --prbs  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; hardware prbs
#### &emsp; | &emsp; --  top   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; top and global design

#### For more information, please visit https://dcpp.io
