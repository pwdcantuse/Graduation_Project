#Read All Files
read_verilog MD4.v
current_design MD4
link

#Setting Clock Constraints
source -echo -verbose MD4.sdc

#Synthesis all design
compile -map_effort high -area_effort high
compile -map_effort high -area_effort high -inc

write -format ddc     -hierarchy -output "MD4_syn.ddc"
write_sdf MD4_syn.sdf
write_file -format verilog -hierarchy -output MD4_syn.v
report_area > area.log
report_timing > timing.log
report_qor   >  MD4_syn.qor

