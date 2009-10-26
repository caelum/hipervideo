# This is a simple script that compiles the plugin using the free Flex SDK on Linux/Mac.
# Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

FLEXPATH=/Developer/SDKs/flex_sdk_3


echo "Compiling docking plugin..."
$FLEXPATH/bin/mxmlc ./Docking.as -sp ./ -o ./docking.swf -use-network=false