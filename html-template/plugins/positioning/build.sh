# This is a simple script that compiles the plugin using the free Flex SDK on Linux/Mac.
# Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

FLEXPATH=/Developer/SDKs/flex_sdk_3


echo "Compiling positioning plugin..."
$FLEXPATH/bin/mxmlc ./Positioning.as -sp ./ -o ./positioning.swf -use-network=false