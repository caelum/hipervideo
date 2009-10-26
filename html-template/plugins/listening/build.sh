# This is a simple script that compiles the plugin using the free Flex SDK on Linux/Mac.
# Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

FLEXPATH=/Developer/SDKs/flex_sdk_3


echo "Compiling listening plugin..."
$FLEXPATH/bin/mxmlc ./Listening.as -sp ./ -o ./listening.swf -use-network=false