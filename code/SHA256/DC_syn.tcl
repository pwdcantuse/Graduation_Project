#Read All Files
read_verilog SHA2.v
current_design SHA2
link

#Setting Clock Constraints
source -echo -verbose SHA2.sdc

#Synthesis all design
compile -map_effort high -area_effort high
compile -map_effort high -area_effort high -inc

write -format ddc     -hierarchy -output "SHA2_syn.ddc"
write_sdf SHA2_syn.sdf
write_file -format verilog -hierarchy -output SHA2_syn.v
report_area > area.log
report_timing > timing.log
report_qor   >  SHA2_syn.qor

