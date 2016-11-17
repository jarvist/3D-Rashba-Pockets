for d in 1 2 4 8 16
do
 echo "draw_ellipsoid ${d} ${d} ${d} 90 90 90 1 1 1 white"
 echo "draw_ellipsoid ${d} ${d} ${d} 0 0 0 1 1 1 white"
# echo "draw_ellipsoid 10 10 10 90 90 90 1 1 1 white"
# echo "draw_ellipsoid 10 10 10 90 90 90 1 1 1 white"

done

s=1.0 #sun diam
echo "draw_ellipsoid ${s} ${s} ${s} 90 90 90 1 1 1 yellow"
echo "draw_ellipsoid ${s} ${s} ${s} 0 0 0 1 1 1 yellow"
echo "draw_ellipsoid ${s} ${s} ${s} 30 30 30 1 1 1 yellow"
