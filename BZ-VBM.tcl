source "approx-ellipsoid.tcl"

draw color white
draw text {0.0 0.0 0.0} G
draw text {0.5 0.5 0.5} R
draw text {0.5 0.5 0.0} M 
draw text {0.5 0.0 0.0} X

graphics $mol color red
approx_ellipsoid $mol 2 {0.015000 0.015000 0.015000} {0.500000 0.500000 0.500000} {1.000000 0.000000 0.000000 0.000000}

draw color white
draw cylinder {0.000000 0.000000 0.000000} {0.500000 0.500000 0.500000} radius 0.0025
draw cylinder {0.000000 0.000000 0.000000} {0.500000 0.000000 0.000000} radius 0.0025
draw cylinder {0.000000 0.000000 0.000000} {0.500000 0.500000 0.000000} radius 0.0025
draw cylinder {0.500000 0.500000 0.500000} {0.500000 0.000000 0.000000} radius 0.0025
draw cylinder {0.500000 0.500000 0.500000} {0.500000 0.500000 0.000000} radius 0.0025
draw cylinder {0.500000 0.000000 0.000000} {0.500000 0.500000 0.000000} radius 0.0025


# Do What You Feel Like 
