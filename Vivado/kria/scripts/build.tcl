# ------------------------------------------------------------
# build.tcl - Recreate kria-accelerator Vivado project
# ------------------------------------------------------------

# Figure out where this script lives
set script_dir [file normalize [file dirname [info script]]]
set proj_src_root [file normalize [file join $script_dir ".."]]
set build_dir [file normalize [file join $proj_src_root "build"]]
puts "script_dir: '$script_dir'"

proc build_project {{run_impl 0}} {

    # Usage:
    # build_project 0   # just (re)create project, no runs
    # build_project 1   # create project + run synth+impl

    global proj_src_root build_dir

    # Project name and part
    set proj_name "kria-accelerator"
    set part_name "xck26-sfvc784-2LV-c"
    set board_part "xilinx.com:kv260_som:part0:1.4"

    puts ">>> build_project: run_impl = $run_impl"

    # ------------------------------------------------------------
    # Create project
    # ------------------------------------------------------------
    file mkdir $build_dir
    create_project $proj_name $build_dir -part $part_name -force
    set_property BOARD_PART $board_part [current_project]

    # Use external sources (don't copy into project)
    set_property source_mgmt_mode All [current_project]

    # Set implementation strategy
    set_property strategy "Performance_ExploreWithRemap" [get_runs impl_1]

    # ------------------------------------------------------------
    # Add design sources from hdl/
    # ------------------------------------------------------------
    set hdl_dir [file join $proj_src_root "hdl"]

    set design_files [list]
    foreach ext {v sv vh vhd vhdl} {
        eval lappend design_files [glob -nocomplain \
            [file join $hdl_dir *.$ext] \
            [file join $hdl_dir * *.$ext] \
            [file join $hdl_dir * * *.$ext]]
    }

    if {[llength $design_files]} {
        add_files -fileset sources_1 -norecurse $design_files
    }

    # ------------------------------------------------------------
    # Add IP from ip/
    # ------------------------------------------------------------
    set ip_dir [file join $proj_src_root "ip"]

    set ip_files [glob -nocomplain \
        [file join $ip_dir *.xci] \
        [file join $ip_dir * *.xci] \
        [file join $ip_dir * * *.xci]]

    if {[llength $ip_files]} {
        add_files -fileset sources_1 -norecurse $ip_files
    }

    # Upgrade and generate
    set ips [get_ips]
    if {[llength $ips]} {
        upgrade_ip [get_ips]
        generate_target all [get_ips]
    }

    # ------------------------------------------------------------
    # Add simulation-only sources from sim/ into sim_1
    # ------------------------------------------------------------
    set sim_dir [file join $proj_src_root "sim"]

    set sim_files [list]
    foreach ext {v sv vh vhd vhdl} {
        eval lappend sim_files [glob -nocomplain \
            [file join $sim_dir *.$ext] \
            [file join $sim_dir * *.$ext] \
            [file join $sim_dir * * *.$ext]]
    }

    if {[llength $sim_files]} {
        add_files -fileset sim_1 -norecurse $sim_files
        set_property used_in_synthesis false      [get_files $sim_files]
        set_property used_in_implementation false [get_files $sim_files]
        set_property used_in_simulation true      [get_files $sim_files]
    }

    # Set tb as top for sim_1 fileset
    set_property top tb_mvm_accelerator [get_filesets sim_1]

    # ------------------------------------------------------------
    # Recreate block design from bd/design_1.tcl
    # ------------------------------------------------------------
    set bd_dir [file join $proj_src_root "bd"]
    set bd_tcl [file join $bd_dir "design_1.tcl"]

    if {![file exists $bd_tcl]} {
        error "BD Tcl file not found: $bd_tcl"
    }
    update_compile_order -fileset sources_1

    # Generate BD
    source $bd_tcl

    # Open the BD and generate a wrapper
    open_bd_design [get_files design_1.bd]
    set bd_file      [get_files -norecurse design_1.bd]
    set wrapper_path [make_wrapper -fileset sources_1 -files $bd_file -top]
    add_files -fileset sources_1 -norecurse $wrapper_path

    # Set BD wrapper as top module for sources_1 fileset
    set_property top design_1_wrapper        [get_filesets sources_1]

    # Don't use wrapper in simulation
    set wrapper_file                         [get_files $wrapper_path]
    set_property used_in_simulation false    [get_files $wrapper_file]
    set_property used_in_synthesis  true     [get_files $wrapper_file]
    set_property used_in_implementation true [get_files $wrapper_file]

    # Update compile order
    update_compile_order -fileset sources_1

    # --------------------------------------
    # Run: synth + impl + bitstream
    # --------------------------------------
    if { $run_impl } {
        puts ">>> Running synthesis..."
        launch_runs synth_1 -jobs 5
        wait_on_run synth_1
    
        puts ">>> Running implementation..."
        launch_runs impl_1 -to_step write_bitstream -jobs 5
        wait_on_run impl_1
    
        puts ">>> Writing bitstream..."
        write_bitstream -force ../build/kria-accelerator.runs/impl_1/design_1_wrapper.bit
    
        puts ">>> Done. Bitstream located at:"
        puts "    [get_property OUTPUT_DIR [get_runs impl_1]]"
    }

        # ------------------------------------------------------------
        # Done
        # ------------------------------------------------------------
        puts "Project '$proj_name' created in: $build_dir"

    }

# ------------------------------------------------------------
# Auto-run when called in batch with -tclargs
# ------------------------------------------------------------
if {[info exists ::argv] && [llength $::argv] > 0} {
    # Expect: vivado -mode batch -source build.tcl -tclargs impl|noimpl|0|1
    set arg [lindex $::argv 0]
    switch -- $arg {
        "impl"   { set run_impl 1 }
        "noimpl" { set run_impl 0 }
        default  { set run_impl $arg }
    }
    build_project $run_impl
}
