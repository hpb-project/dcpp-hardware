#### dcpp-hardware 是dcpp的硬件加速平台，在fpga上实现dcpp计算的加速。

#### 总体设计目录结构如下：

#### --boe_top                           
#### &emsp; | &emsp; --eth  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;            ethernet packet 
#### &emsp; | &emsp; --fap  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;            function accelerate processer
#### &emsp;&emsp;&emsp;&emsp;| &emsp; --proof &emsp;&emsp;&emsp;  proof module
#### &emsp; | &emsp; --prbs  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; hardware prbs
#### &emsp; | &emsp; --top   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;  top and global design
