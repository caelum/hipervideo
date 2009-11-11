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
			for each (var element:XML in xml.element) {
				linkArray.push(
					new Element(element.textContent, element.imageContent,
							new Link(
								element.link.tooltip, 
								element.link.thumbnail, 
								element.link.url, 
								Strings.seconds(element.link.time)),
							element.textContent.@color, element.textContent.@backgroundColor,
							Strings.seconds(element.time.@start), Strings.seconds(element.time.@duration),
							element.position.@x, element.position.@y,
							element.position.@width, element.position.@height)
				);
			}
			return linkArray;
		}

	}
}