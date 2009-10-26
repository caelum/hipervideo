:: This is a simple script that compiles the plugin using the free Flex SDK on Windows.
:: Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

SET FLEXPATH="\Program Files\flex_sdk_3"

echo "Compiling controlling plugin..."

%FLEXPATH%\bin\mxmlc .\Controlling.as -sp .\ -o .\controlling.swf -use-network=false