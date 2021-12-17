#dcpp-hardware 是dcpp的硬件加速平台，在fpga上实现dcpp计算的加速。
#总体设计目录结构如下：
#--boe_top                           
#    |       --eth                   ethernet packet 
#    |       --fap                   function accelerate processer
#                |       --proof     proof module
#                |       --prbs      hardware prbs
#    |       --top                   top and global design
