:: This is a simple script that compiles the plugin using the free Flex SDK on Windows.
:: Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

SET FLEXPATH="\Program Files\flex_sdk_3"

echo "Compiling positioning plugin..."

%FLEXPATH%\bin\mxmlc .\Positioning.as -sp .\ -o .\positioning.swf -use-network=false