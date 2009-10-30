# This is a simple script that compiles the plugin using MXMLC (free & cross-platform).
# To use, make sure you have downloaded and installed the Flex SDK in the following directory:
FLEXPATH=/home/pmatiello/Desktop/flex-builder/sdks/3.0.0/


echo "Compiling with MXMLC..."
mkdir -p ../html-template/plugins/captions/
$FLEXPATH/bin/mxmlc ./com/jeroenwijering/plugins/Captions.as -sp ./ -o ../bin-debug/plugins/captions/captions.swf -use-network=false