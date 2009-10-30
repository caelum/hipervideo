# This is a simple script that compiles the plugin using MXMLC (free & cross-platform).
# To use, make sure you have downloaded and installed the Flex SDK in the following directory:
FLEXPATH=/home/pmatiello/Desktop/flex-builder/sdks/3.0.0/


echo "Compiling with MXMLC..."
mkdir -p ../bin-debug/plugins/hipervideo/
$FLEXPATH/bin/mxmlc ./com/jeroenwijering/plugins/Hipervideo.as -sp ./ -o ../bin-debug/plugins/hipervideo/hipervideo.swf -use-network=false