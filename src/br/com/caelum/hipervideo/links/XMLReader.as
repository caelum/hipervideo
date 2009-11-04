package br.com.caelum.hipervideo.links
{
	import com.jeroenwijering.utils.Strings;
	
	public class XMLReader
	{
		
		private var xml:XML;
		
		public function XMLReader(xml:XML)
		{
			this.xml = xml;
		}
		
		public function extract():Array {
			var linkArray:Array = new Array();
			for each (var link:XML in xml.link) {
				linkArray.push(
					new Link(link.content, link.content.@type,
							Strings.seconds(link.startTime), Strings.seconds(link.endTime),
							link.topLeft.x, link.topLeft.y,
							link.bottomRight.x, link.bottomRight.y)
				);
			}
			return linkArray;
		}

	}
}