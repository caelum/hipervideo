package br.com.caelum.hipervideo.reader
{
	import br.com.caelum.hipervideo.model.Action;
	import br.com.caelum.hipervideo.model.ActionType;
	import br.com.caelum.hipervideo.model.Element;
	import br.com.caelum.hipervideo.model.ElementType;
	import br.com.caelum.hipervideo.model.Hipervideo;
	import br.com.caelum.hipervideo.model.Link;
	
	import com.jeroenwijering.utils.Strings;
	
	public class XMLReader {
		
		private var xml:XML;
		
		public function XMLReader(xml:XML) {
			this.xml = xml;
		}
		
		public function extract():Hipervideo {
			var elements:Array = new Array();
			var actions:Array = new Array();
			var playlist:Array = new Array();
			
			for each (var element:XML in xml.elements.element) {
				var content:String;
				var type:String;
				var color:uint;
				var thickness:Number = 1;
				var alpha:Number = 1;
				
				if ("textContent" in element) {
					content = element.textContent;
					type = ElementType.TEXT;
					color = element.textContent.@color.toString().length == 0 ? 0xFFFFFF : uint(element.textContent.@color);
					alpha = element.textContent.@alpha.toString().length == 0 ? 1 : Number(element.textContent.@alpha);
				} else if ("imageContent" in element) {
					content = element.imageContent;
					type = ElementType.IMAGE;
					color = 0xFFFFFF;
					alpha = element.imageContent.@alpha.toString().length == 0 ? 1 : Number(element.imageContent.@alpha);
				} else if ("frame" in element) {
					content = element.frame;
					type = ElementType.FRAME;
					color = element.frame.@color.toString().length == 0 ? 0x0000FF : uint(element.frame.@color);
					thickness = element.frame.@thickness.toString().length == 0 ? 1 : element.frame.@thickness;
				} else if ("underline" in element) {
					content = "";
					type = ElementType.UNDERLINE;
					color = element.underline.@color.toString().length == 0 ? 0x0000FF : uint(element.underline.@color);
					alpha = element.underline.@alpha.toString().length == 0 ? 1 : Number(element.underline.@alpha);
				}
				
				elements.push(
					new Element(type, content,
							new Link(
								element.link.@activity_id,
								element.link.tooltip, 
								element.link.thumbnail, 
								element.link.url, 
								element.link.url.@target,
								Strings.seconds(element.link.time), 
								element.link.video,
								ActionType.fromValue(element.link.@action)),
							color, element.textContent.@backgroundColor, alpha,
							Strings.seconds(element.time.@start), Strings.seconds(element.time.@duration),
							element.geometry.@x, element.geometry.@y,
							element.geometry.@width, element.geometry.@height, thickness)
				);
			}
			
			for each (var link:XML in xml.playlist.link) {
				playlist.push(
					new Link("", link.tooltip, link.thumbnail, link.url, link.url.@target, link.time, link.video, ActionType.NOTHING));
			}
			
			for each (var action:XML in xml.actions.pause) {
				actions.push(
					new Action(ActionType.PAUSE, Strings.seconds(action.@at)));
			}
			
			for each (var activity:XML in xml.actions.activity) {
				actions.push(
					new Action(ActionType.ACTIVITY, Strings.seconds(activity.@at), activity.@id));
			}
			
			for each (var controlbarAct:XML in xml.actions.controlbar) {
				actions.push(
					new Action(ActionType.CONTROLBAR, Strings.seconds(controlbarAct.@at), controlbarAct.@enabled));
			}

			return new Hipervideo(xml.video.@file, xml.next.@file, elements, actions, playlist);
		}

	}
}