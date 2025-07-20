# Create project
create_project accelerator ../build -part xc7z020clg400-1
set_property BOARD_PART tul.com.tw:pynq-z2:part0:1.0 [current_project]

# --- Add HDL sources ---
set src_files [glob -nocomplain ../src/*.{v,sv,vh}]
add_files -fileset sources_1 $src_files

# --- Add simulation sources ---
set sim_files [glob -nocomplain ../sim/*.{v,sv,vh}]
add_files -fileset sim_1 $sim_files

# --- Create IPs ---
source ./create_ips.tcl
generate_target all [get_ips]

# --- Source block design ---
source ../bd/accelerator_bd.tcl
#source ../bd/parameterized_accelerator_bd.tcl
