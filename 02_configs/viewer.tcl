
# ============================================================================
# After loading psf and dcd, use this script for various visualizations of Hv1.
#
# Steps:
#   1. "source file.tcl"
#   2. "view_clear"
#   3. "view_[four/protein]"
# By: Victoria Lim
#
# Notes:
#   * Only modifies visualization on TOP molecule. If you want to change the visualization
#     system, use command "reset_top [index_of_new_top]".
#   * The reset_top proc assumes that the top molecule already has one representation, but
#     if this is NOT true, use command "set ::repcount [how_many_already_exist]".
# Source:
#   * Greenplanet: /beegfs/DATA/mobley/limvt/hv1/github/02_configs/viewer.tcl
#   * Cassandra:   /home/limvt/connect/greenplanet/goto-beegfs/hv1/github/02_configs/viewer.tcl
# ============================================================================

#set psf [glob *psf]
#mol new $psf type {psf} first 0 last -1 step 1 waitfor all
#mol addfile npt_eq01.dcd type {dcd} first 0 last -1 step 1 waitfor -1 $moltop


# VMD display settings
color Display Background white
display backgroundgradient off
display projection Orthographic
display depthcue off
axes location LowerLeft
set repcount 1

proc view_clear {} {
    foreach moltop [molinfo list] {
        # assumes no more than 20 representations drawn
        for {set i 0} {$i < 20} {incr i} {
            mol delrep 0 $moltop
        }
    }
    set ::repcount 0
}

proc smooth_rep { {moltop 0} {smoothsize 5} } {
    global repcount
    # doesn't work if some mol has NO representations
    for {set i 0} {$i < $repcount} {incr i} {
        mol smoothrep $moltop $i $smoothsize
    }
}

proc reset_top { newtop } {
    mol top $newtop
    set ::repcount 1
}


proc view_protein {} {
    global repcount
    set moltop [molinfo top]

    # add representation for file with GBI only
    mol addrep $moltop
    mol modselect $repcount $moltop resname GBI1
    mol modstyle $repcount $moltop Licorice
    mol modcolor $repcount $moltop ColorID 4
    incr ::repcount

    # add representation for protein
    mol addrep $moltop
    mol modselect $repcount $moltop protein
    mol modstyle $repcount $moltop NewCartoon
    mol modcolor $repcount $moltop ColorID 6
    #mol modmaterial 1 $moltop Transparent
    incr ::repcount

    # add representation for S1
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 99 to 125
    mol modstyle $repcount $moltop NewCartoon
    mol modcolor $repcount $moltop ColorID 10
    incr ::repcount

    # add representation for S2
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 134 to 160
    mol modstyle $repcount $moltop NewCartoon
    mol modcolor $repcount $moltop ColorID 3
    incr ::repcount

    # add representation for S3
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 168 to 191
    mol modstyle $repcount $moltop NewCartoon
    mol modcolor $repcount $moltop ColorID 7
    incr ::repcount

    # add representation for S4
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 198 to 222
    mol modstyle $repcount $moltop NewCartoon
    mol modcolor $repcount $moltop ColorID 11
    incr ::repcount

}


proc view_network { {lig "resname GBI1"} } {
    global repcount
    set moltop [molinfo top]

    # the ligand
    mol color Name
    mol representation Licorice 0.200000 10.000000 10.000000
    mol selection "$lig"
    mol material Opaque
    mol addrep $moltop
    mol selupdate $repcount $moltop 1 ;# traj update not applied if repcount gets reset
    incr ::repcount

    # the neighbors
    mol color ResType
    mol representation Licorice 0.100000 10.000000 10.000000
    mol selection "(protein or water) and same residue as noh and within 5 of $lig"
    mol material Opaque
    mol addrep $moltop
    mol selupdate $repcount $moltop 1
    incr ::repcount

    # the hbond network
    mol color Name
    mol representation HBonds 3.500000 40.000000 6.000000
    mol selection "(nitrogen or oxygen) and ($lig or (protein or water) and same residue as noh and within 5 of $lig)"
    mol material Opaque
    mol addrep $moltop
    mol selupdate $repcount $moltop 1
    incr ::repcount

}


proc view_four {} {
    global repcount
    set moltop [molinfo top]

    # add representation for file with GBI only
    mol addrep $moltop
    mol modselect $repcount $moltop resname GBI1
    mol modstyle $repcount $moltop Licorice
    mol modcolor $repcount $moltop ColorID 4
    incr ::repcount

    # add representation for protein
    mol addrep $moltop
    mol modselect $repcount $moltop protein
    mol modstyle $repcount $moltop NewCartoon
    mol modcolor $repcount $moltop ColorID 0
    mol modmaterial $repcount $moltop Transparent
    incr ::repcount

    # add representation for residues
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 112
    mol modstyle $repcount $moltop Licorice 0.300000 12.000000 12.000000
    mol modcolor $repcount $moltop ColorID 10
    incr ::repcount

    # add representation for residues
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 150
    mol modstyle $repcount $moltop Licorice 0.300000 12.000000 12.000000
    mol modcolor $repcount $moltop ColorID 3
    incr ::repcount

    # add representation for residues
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 181
    mol modstyle $repcount $moltop Licorice 0.300000 12.000000 12.000000
    mol modcolor $repcount $moltop ColorID 7
    incr ::repcount

    # add representation for residues
    mol addrep $moltop
    mol modselect $repcount $moltop protein and resid 211
    mol modstyle $repcount $moltop Licorice 0.300000 12.000000 12.000000
    mol modcolor $repcount $moltop ColorID 11
    incr ::repcount

    # hide displays for ease of viewing
    #mol off $moltop           ;# don't display anything to start
    #mol showrep $moltop 1 0   ;# don't show protein
}

proc view_dens_wat { {infile "watdens.dx"} } {
    # ============================================================
    # View volumetric density of water in given DX file.
    # You will LIKELY have to adjust [Draw style > Isovalue] and [Trajectory > color scale].
    #
    # Arguments
    #  - infile : string
    #      Name of the output file. Default is "watdens.dx".
    # Returns
    #  - (nothing)
    # Example usage
    #  - calc_dens_wat watdens.dx
    #  - calc_dens_wat
    # Notes
    #  - If you want to use this function, the original call to analyzeDCD should not be vmdt.
    # ============================================================
    mol new $infile type {dx} first 0 last -1 step 1 waitfor 1 volsets {0 }
    set moltop [molinfo top]

    mol addrep $moltop
    mol modstyle 0 $moltop Isosurface
    mol modcolor 0 $moltop Volume 0
    mol modstyle 0 $moltop Isosurface 0.032205 0 2 1 1 1
    mol modstyle 0 $moltop Isosurface 0.032205 0 0 1 1 1
    mol scaleminmax $moltop 0 -0.150000 0.050000 ;# note that moltop and repnum are switched

    puts "\nDensity loaded. Probably need to adjust \[Draw style > Isovalue\] and \[Trajectory > color scale\]\n"

} ;# end of view_dens_wat
