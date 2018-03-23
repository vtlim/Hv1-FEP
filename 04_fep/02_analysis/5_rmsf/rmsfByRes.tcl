
# Purpose: measure RMSF by residue for Hv1. vmd cannot measure RMSF for group
#   of atoms, so each residue uses dummy atom that is the center of mass
#   of the amino acid (with backbone, no hydrogens).

# Usage: vmd -dispdev none -e file.tcl -args inpsf inpdb indcd [indcd2 indcd3 ...]
#  - inpsf TODO
#  - inpdb
#  - indcd
#
# References:
#  - rmsf uses average position of frames as reference, https://tinyurl.com/yawa8xjo
#  - use of dummy atom, https://tinyurl.com/y9l2wkvk

# ========================== Variables ========================= #

set inpsf [lindex $argv 0]
set inpdb [lindex $argv 1]

# why do i have to subtract one? it worked before without it fine..
#for {set i 2} {$i < [expr $argc -1]} {incr i}
for {set i 2} {$i < $argc} {incr i} {
    lappend dcdlist [lindex $argv $i]
}

set dumid 58230 ; # borrow some lone ion to use as dummy atom


# =============================================================== #


# read in data
mol new $inpsf
mol addfile $inpdb
foreach dcd $dcdlist {
    mol addfile $dcd waitfor all
}

# open file for writing output
set outDataFile [open rmsf_hv1.dat w]
puts $outDataFile "# Data from files:\n#  $inpsf\n#  $dcdlist\n"
puts $outDataFile "# Res | RMSF (Angstroms)"

# rmsf calculation
for {set resid 88} {$resid < 231} {incr resid} {
    set whole [atomselect top "protein and resid $resid"]
    set group [atomselect top "protein and resid $resid and noh"]
    set dummy [atomselect top "index $dumid"]
    set refprot [atomselect 0 "protein and backbone and {{resid 100 to 125} or {resid 134 to 160} or {resid 168 to 191} or {resid 198 to 220}}" frame 0]
    set compprot [atomselect 0 "protein and backbone and {{resid 100 to 125} or {resid 134 to 160} or {resid 168 to 191} or {resid 198 to 220}}"]

    
    set num_steps [molinfo top get numframes]
    for {set frame 0} {$frame < $num_steps} {incr frame} {

        # update selections to this frame
        $whole frame $frame
        $group frame $frame
        $dummy frame $frame
        $refprot frame $frame
        $compprot frame $frame

        # align protein by (1) transmembrane regions, (2) backbone
        $compprot move [measure fit $compprot $refprot]

        # measure crds of center of this noh-residue and set crds on dummy atom
        set xyz [measure center $group]
        $dummy set x [lindex $xyz 0]
        $dummy set y [lindex $xyz 1]
        $dummy set z [lindex $xyz 2]
    }

    # rmsf calculation over all frames
    set rmsf [measure rmsf $dummy] 
    $whole set occupancy $rmsf
    puts $outDataFile "$resid\t$rmsf"
    
}

# write out rmsf info in occupancy column of a PDB file
animate write pdb rmsf_hv1.pdb beg 0 end 0 sel [atomselect top protein]
animate write psf rmsf_hv1.psf beg 0 end 0 sel [atomselect top protein]
close $outDataFile
exit
 

# ===== if you want to write out rmsf by frame =====
# this would go in for loop of frames
#set outfile [open "rmsfCA.txt" w] 
#foreach x $rmsf { 
#  puts $outfile $x 
#} 
