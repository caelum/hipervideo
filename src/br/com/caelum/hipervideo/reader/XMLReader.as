package br.com.caelum.hipervideo.reader
{
	import br.com.caelum.hipervideo.model.Action;
	import br.com.caelum.hipervideo.model.ActionType;
	import br.com.caelum.hipervideo.model.Element;
	import br.com.caelum.hipervideo.model.ElementType;
	import br.com.caelum.hipervideo.model.Hipervideo;
	import br.com.caelum.hipervideo.model.Link;
	
	import com.jeroenwijering.utils.Strings;
	
	public class XMLReader
	{
		private var xml:XML;
		
		public function XMLReader(xml:XML)
		{
			this.xml = xml;
		}
		
		public function extract():Hipervideo {
			var elements:Array = new Array();
			var actions:Array = new Array();
			var playlist:Array = new Array();
			for each (var element:XML in xml.elements.element) {
				
				var content:String;
				var type:String;
				trace("> "+ element.textContent.toString());
				if (element.textContent.toString().length != 0) {
					content = element.textContent;
					type = ElementType.TEXT;
				} else if (element.imageContent.toString().length != 0) {
					content = element.imageContent;
					type = ElementType.IMAGE;
				} else {
					content = "";
					type = ElementType.UNDERLINE;
				}
				
				elements.push(
					new Element(type, content,
							new Link(
								element.link.@activity_id,
								element.link.tooltip, 
								element.link.thumbnail, 
								element.link.url, 
								Strings.seconds(element.link.time), 
								ActionType.fromValue(element.link.@action)),
							element.textContent.@color, element.textContent.@backgroundColor,
							Strings.seconds(element.time.@start), Strings.seconds(element.time.@duration),
							element.geometry.@x, element.geometry.@y,
							element.geometry.@width, element.geometry.@height)
				);
			}
			
			for each (var link:XML in xml.playlist.link) {
				playlist.push(
					new Link("", link.tooltip, link.thumbnail, link.url, link.time, ActionType.NOTHING));
			}
			
			for each (var action:XML in xml.actions.pause) {
				actions.push(
					new Action(ActionType.PAUSE, Strings.seconds(action.@at)));
			}

			return new Hipervideo(xml.video.@file, xml.next.@file, elements, actions, playlist);
		}

	}
}