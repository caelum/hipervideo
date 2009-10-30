/**
* Parse a TimedText XML and return an array of captions.
**/
package com.jeroenwijering.parsers {


import com.jeroenwijering.utils.Strings;


public class TTParser {


	/** 
	* Parse the captions XML.
	*
	* @param dat	The loaded XML, which must be in W3C TimedText format.
	* @return		An array with captions. 
	* 				Each caption is an object with 'begin' and 'text' parameters.
	**/
	public static function parseCaptions(dat:XML):Array {
		var arr:Array = new Array({begin:0,text:''});
		for each (var i:XML in dat.children()) {
			if(i.localName() == "body") {
				for each (var j:XML in i.children()) {
					for each (var k:XML in j.children()) {
						if(k.localName() == 'p') {
							var obj:Object = TTParser.parseCaption(k);
							arr.push(obj);
							if(obj['end']) {
								arr.push({begin:obj['end'],text:''});
								delete obj['end'];
							} else if (obj['dur']) {
								arr.push({begin:obj['begin']+obj['dur'],text:''});
								delete obj['dur'];
							}
						}
					}
				}
			}
		}
		return arr;
	};


	/** Parse a single captions entry. **/
	private static function parseCaption(dat:XML):Object {
		var ptn:RegExp = /(\n<br.*>\n)+/;
		var obj:Object = {
			begin:Strings.seconds(dat.@begin),
			dur:Strings.seconds(dat.@dur),
			end:Strings.seconds(dat.@end),
			text:dat.children().toString().replace(ptn,'\n').replace(ptn,'\n')
		};
		return obj;
	};


}


}