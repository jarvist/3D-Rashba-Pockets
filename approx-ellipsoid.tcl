proc approx_ellipsoid {mol level {radius {1.0 1.0 1.0}} {center {0.0 0.0 0.0}} {orient {1.0 0.0 0.0 0.0}}} {
    set gid {}

    # vertices of an octahedron inscribed
    # in a sphere with radius 1.0.
    set vec1 {-1.0  0.0  0.0}
    set vec2 { 1.0  0.0  0.0}
    set vec3 { 0.0 -1.0  0.0}
    set vec4 { 0.0  1.0  0.0}
    set vec5 { 0.0  0.0 -1.0}
    set vec6 { 0.0  0.0  1.0}

    # build list of triangles representing
    # the octahedron. the points of the 
    # triangles have to be given clockwise from
    # looking at the surface from the outside.
    set trilist [list \
                 [list $vec1 $vec4 $vec5] \
                 [list $vec5 $vec4 $vec2] \
                 [list $vec2 $vec4 $vec6] \
                 [list $vec6 $vec4 $vec1] \
                 [list $vec5 $vec3 $vec1] \
                 [list $vec2 $vec3 $vec5] \
                 [list $vec6 $vec3 $vec2] \
                 [list $vec1 $vec3 $vec6] ]

    # refinement iterations to approximate a sphere:
    # each triangle is split into 4 subtriangles
    #        p2
    #        /\
    #       /  \
    #    pb/____\pc
    #     /\    /\
    #    /  \  /  \
    #   /____\/____\
    # p1     pa    p3
    #
    # we construct vectors to the three midpoints and rescale
    # them to unit length. then build new triangles enumerating
    # the points in clockwise order again.
    for {set i 0} {$i < $level} {incr i} {
        set newlist {}
        foreach tri $trilist {
            foreach {p1 p2 p3} $tri {}
            set pa [vecnorm [vecadd $p1 $p3]]
            set pb [vecnorm [vecadd $p1 $p2]]
            set pc [vecnorm [vecadd $p2 $p3]]
            lappend newlist [list $p1 $pb $pa]
            lappend newlist [list $pb $p2 $pc]
            lappend newlist [list $pa $pb $pc]
            lappend newlist [list $pa $pc $p3]
        }
        set trilist $newlist
    }
    
    # compute vertex scaling factor to deform a sphere to an ellipsoid
    proc radscale {radius vector} {
        foreach {a b c} $radius {}
        foreach {x y z} $vector {}
        return [expr {sqrt(1.0/($x/$a*$x/$a+$y/$b*$y/$b+$z/$c*$z/$c))}]
	}

    # convert quaternion to rotation matrix
    proc quattorot {quat} {
        foreach {w x y z} $quat {}
        set norm [expr {$w*$w + $x*$x + $y*$y +$z*$z}]
        set sc 0.0
        if {$norm > 0.0} { set s [expr {2.0/$norm}] }
        set X [expr {$x*$s}]
        set Y [expr {$y*$s}]
        set Z [expr {$z*$s}]
        return [list \
            [list [expr {1.0-($y*$y*$s + $z*$z*$s)}] \
                  [expr {$x*$y*$s - $w*$z*$s}] \
                  [expr {$x*$z*$s + $w*$y*$s}] ] \
            [list [expr {$x*$y*$s + $w*$z*$s}] \
                  [expr {1.0-($x*$x*$s + $z*$z*$s)}] \
                  [expr {$y*$z*$s - $w*$x*$s}] ] \
            [list [expr {$x*$z*$s - $w*$y*$s}] \
                  [expr {$y*$z*$s + $w*$x*$s}] \
                  [expr {1.0-($x*$x*$s + $y*$y*$s)}] ] ]
    }

    # apply rotation matrix to vector
    proc rotvec {mat vec} {
        set new {}
        foreach c $mat {
            lappend new [vecdot $c $vec]
        }
        return $new
    }

    foreach tri $trilist {
        foreach {vec1 vec2 vec3} $tri {}
        # rescale to desired radius
        set rad1 [radscale $radius $vec1]
        set rad2 [radscale $radius $vec2]
        set rad3 [radscale $radius $vec3]
        # get and apply rotation matrix
        set mat [quattorot $orient]
        set vec1 [rotvec $mat $vec1]
        set vec2 [rotvec $mat $vec2]
        set vec3 [rotvec $mat $vec3]
        # deform sphereoid and translate
        set pos1 [vecadd [vecscale $rad1 $vec1] $center]
        set pos2 [vecadd [vecscale $rad2 $vec2] $center]
        set pos3 [vecadd [vecscale $rad3 $vec3] $center]
        # since the original vectors to the vertices are those of
        # a unit sphere, we can use them directly as surface normals.
        lappend gid [graphics $mol trinorm $pos1 $pos2 $pos3 $vec1 $vec2 $vec3]
    }
    return $gid
}

proc draw_octahedron {mol {center {0.0 0.0 0.0}}} {
    set gid {}

    set vec1 {-1.0  0.0  0.0}
    set vec2 { 1.0  0.0  0.0}
    set vec3 { 0.0 -1.0  0.0}
    set vec4 { 0.0  1.0  0.0}
    set vec5 { 0.0  0.0 -1.0}
    set vec6 { 0.0  0.0  1.0}

    set pos1 [vecadd {-1.0  0.0  0.0} $center]
    set pos2 [vecadd { 1.0  0.0  0.0} $center]
    set pos3 [vecadd { 0.0 -1.0  0.0} $center]
    set pos4 [vecadd { 0.0  1.0  0.0} $center]
    set pos5 [vecadd { 0.0  0.0 -1.0} $center]
    set pos6 [vecadd { 0.0  0.0  1.0} $center]

    lappend gid [graphics $mol triangle $pos1 $pos4 $pos5]
    lappend gid [graphics $mol triangle $pos5 $pos4 $pos2]
    lappend gid [graphics $mol triangle $pos2 $pos4 $pos6]
    lappend gid [graphics $mol triangle $pos6 $pos4 $pos1]

    lappend gid [graphics $mol triangle $pos5 $pos3 $pos1]
    lappend gid [graphics $mol triangle $pos2 $pos3 $pos5]
    lappend gid [graphics $mol triangle $pos6 $pos3 $pos2]
    lappend gid [graphics $mol triangle $pos1 $pos3 $pos6]
    return $gid
}

if {[molinfo num] < 1} {
    set mol [mol new]
}

graphics $mol delete all
graphics $mol material AOChalky 
graphics $mol color red

#draw_octahedron $mol {-1.0 0.0 0.0}
#graphics $mol color yellow
#approx_ellipsoid $mol 0 {1.0 1.0 1.0} {1.0 0.0 0.0}
#graphics $mol color green
#approx_ellipsoid $mol 1 {0.75 1.00 0.75} {0.0 1.0 0.0}
#graphics $mol color blue
#approx_ellipsoid $mol 2 {-0.75 -0.50 -0.50} {0.0 -1.0 0.0} {0.5 0.5 0.5 0.1}
