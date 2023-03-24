ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}') && echo "IP: $ip"
xhost + ${ip}
massifdir=$(pwd)

docker run -d -ti --rm -e DISPLAY=${ip}:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v ${massifdir}:/home/massif/test aeppert/massif-visualizer
