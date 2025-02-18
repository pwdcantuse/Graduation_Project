#Read All Files
read_verilog SHA1.v
current_design SHA1
link

#Setting Clock Constraints
source -echo -verbose SHA1.sdc

#Synthesis all design
compile -map_effort high -area_effort high
compile -map_effort high -area_effort high -inc

write -format ddc     -hierarchy -output "SHA1_syn.ddc"
write_sdf SHA1_syn.sdf
write_file -format verilog -hierarchy -output SHA1_syn.v
report_area > area.log
report_timing > timing.log
report_power > power.log
report_qor   >  SHA1_syn.qor

