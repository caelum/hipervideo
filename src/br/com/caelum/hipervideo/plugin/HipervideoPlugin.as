package br.com.caelum.hipervideo.plugin {


import br.com.caelum.hipervideo.model.ActionType;
import br.com.caelum.hipervideo.model.Element;
import br.com.caelum.hipervideo.model.Hipervideo;
import br.com.caelum.hipervideo.reader.XMLReader;

import com.jeroenwijering.events.*;
import com.jeroenwijering.parsers.*;
import com.jeroenwijering.utils.Logger;

import flash.display.*;
import flash.events.*;
import flash.external.ExternalInterface;
import flash.net.*;
import flash.text.*;

public class HipervideoPlugin extends MovieClip implements PluginInterface {

	[Embed(source="../../../../../dock.png")]
	private const DockIcon:Class;

	/** List with configuration settings. **/
	public var config:Object = {
		back:false,
		file:undefined,
		fontsize:14,
		state:true
	};
	/** XML connect and parse object. **/
	private var loader:URLLoader;
	/** Reference to the MVC view. **/
	private var view:AbstractView;
	/** Reference to the background graphic. **/
	private var back:MovieClip;
	/** The array the captions are loaded into. **/
	private var captions:Array;

	private var currentTime:Number;

	private function drawClip():void {
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE,loaderHandler);
		
		back = new MovieClip();
		back.graphics.beginFill(0x000000,0.75);
		back.graphics.drawRect(0,0,400,0);
		addChild(back);
		
		
		if (config['back'] == false) {
			back.alpha = 0;
		}
	};

	/** Show/hide the captions **/
	public function hide(stt:Boolean):void {
		config['state'] = stt;
		visible = config['state'];
		var cke:SharedObject = SharedObject.getLocal('com.jeroenwijering','/');
		cke.data['hipervideo.state'] = stt;
		cke.flush();
	};

	/** Initing the plugin. **/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
		view.addModelListener(ModelEvent.TIME,timeHandler);
		view.addModelListener(ModelEvent.STATE,stateHandler);
		view.addModelListener(ModelEvent.META,metaHandler);
		
		drawClip();
		
		hide(config['state']);
	};

	/** Check for captions with a new item. **/
	private function itemHandler(evt:ControllerEvent=null):void {
		captions = new Array();
		config['file'] = undefined;
		var file:String;
		
		file = view.config['hipervideo.file'];

		if (file) {
			config['file'] = file;
			try {
				loader.load(new URLRequest(config['file']));
			} catch (err:Error) {
				Logger.log(err.message,'hipervideo');
			}
		}
	};

	/** Captions are loaded; now display them. **/
	private function loaderHandler(evt:Event):void { 
		var hipervideo:Hipervideo = new XMLReader(new XML(evt.target.data)).extract();
		var elementArray:Array = hipervideo.elements; 
		
		view.sendEvent(ViewEvent.LOAD, hipervideo.video);
		
		for each (var element:Element in elementArray) {
			captions.push({begin:element.start, end:element.start + element.duration, 
							content:element.content, isText: element.isText,
							textColor: element.color, backgroundColor: element.backgroundColor,
							hasBackgroundColor: element.hasBackgroundColor, url: element.link.url,
							time: element.link.time, activityId: element.link.activityId,
							action: element.link.action,
							topLeft_x:element.x, topLeft_y:element.y,
							width:element.width, height:element.height, active:false});
		}
		
		if (captions.length == 0) {
			Logger.log('Not a valid file.','hipervideo');
		}
	};

	/** Check for captions in metadata. **/
	private function metaHandler(evt:ModelEvent):void {
		var txt:String;
		var fnd:Boolean;
		
		if (evt.data.type == 'hipervideo') {
			txt = evt.data.captions;
			fnd = true;
		} else if (evt.data.type == 'textdata') {
			txt = evt.data.text;
			fnd = true;
		}
		
		if (fnd) {
			resizeHandler();
			Logger.log(txt,'hipervideo');
		}
	};

	private var xmlLoaded:Boolean;

	/** Resize the captions if the display changes. **/
	private function resizeHandler(evt:ControllerEvent=undefined):void {
		width = view.config['width'];
		scaleY = scaleX;
		y = view.config['height']-height;
		
		if (!xmlLoaded) {
			itemHandler(evt);
			xmlLoaded = true;
		}
	};
	
	private function drawElement(caption:Object):void {
		if (caption['isText']) {
			new TextElement(caption, this, view);
		} else {
			new ImageElement(caption, this, view);
		}
		resizeHandler();
	}

	/** Check timing of the player to sync captions. **/
	private function stateHandler(evt:ModelEvent):void {
		visible = 
			(view.config['state'] == ModelStates.PLAYING || view.config['state'] == ModelStates.PAUSED) 
				&& config['state'];
	};

	/** Check timing of the player to sync captions. **/
	private function timeHandler(evt:ModelEvent):void {
		var pos:Number = evt.data.position;
		currentTime = pos;
		
		for (var i:Number = 0; i < captions.length; i++) {
			if (captions[i]['begin'] < pos && captions[i]['end'] > pos && captions[i]['active'] == false) {
				drawElement(captions[i]);
			}
		}
	};
	
	public function clickHandler(data:Object, clip:MovieClip):void {
		if (data['activityId'] != "") {
			receive_notification_from_activity_log(ExternalInterface.call('logActivity', data['activityId'], currentTime));
		}
		
		if (data['action'] == ActionType.PLAY) {
			clip.shouldRemove = true;
			view.sendEvent("PLAY");
			return;
		}

		if (data['url'] != "") {
			if (view.config['hipervideo.target'] != undefined){
				try {
				  navigateToURL(new URLRequest(data['url']), view.config['hipervideo.target']); 
				} catch (e:Error) {
				  trace("Error occurred!");
				}
			} else {
				try {
				  navigateToURL(new URLRequest(data['url'])); 
				} catch (e:Error) {
				  trace("Error occurred!");
				}
			}
		} else if (data['time'] != ""){
			view.sendEvent("SEEK", data['time']);
		}
		
	}
	
	public function receive_notification_from_activity_log(response:Object):void {
		trace(response['id'] + " - " + response['value']);
		
		if (response['id'] == "Element") {
			drawElement(response['value']);
		}
	}
	
	public function elementStateHandler(element:Object, item:Object, evt:ModelEvent):void {
		switch (evt.data.newstate) {
			case ModelStates.PLAYING:
				if (element.shouldRemove) 
					item.visible = false;
				else
					item.visible = true;
				break;
			case ModelStates.PAUSED:
				if (!view.config['autoPaused']) {
					item.visible = false;	
				}
				break;
			case ModelStates.COMPLETED:
				item.visible = false;
				break;
		}
	}

};

}