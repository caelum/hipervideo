package br.com.caelum.hipervideo.plugin {


import br.com.caelum.hipervideo.model.Element;
import br.com.caelum.hipervideo.model.Video;
import br.com.caelum.hipervideo.reader.XMLReader;

import com.jeroenwijering.events.*;
import com.jeroenwijering.parsers.*;
import com.jeroenwijering.utils.Logger;

import flash.display.*;
import flash.events.*;
import flash.external.ExternalInterface;
import flash.filters.DropShadowFilter;
import flash.net.*;
import flash.text.*;

public class Hipervideo extends MovieClip implements PluginInterface {

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
	/** Reference to the textfield. **/
	public var field:TextField;
	/** Reference to the background graphic. **/
	private var back:MovieClip;
	/** The array the captions are loaded into. **/
	private var captions:Array;
	/** Textformat entry for the captions. **/
	private var format:TextFormat;
	/** Currently active caption. **/
	private var current:Number;
	/** Reference to the dock button. **/
	private var button:MovieClip;

	private var img:Loader;
	private var child:DisplayObject;
	
	private var forceReload:Boolean = false;

	private function drawClip():void {
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE,loaderHandler);
		
		back = new MovieClip();
		back.graphics.beginFill(0x000000,0.75);
		back.graphics.drawRect(0,0,400,0);
		addChild(back);
		
		format = new TextFormat();
		format.color = 0xFFFFFF;
		format.size = config['fontsize'];
		format.align = "center";
		format.font = "_sans";
		format.leading = 4;
		
		field = new TextField();
		field.border = true;
		field.borderColor = 0xAAAAAA;
		field.x = Infinity;
		field.selectable = false;
		field.multiline = true;
		field.wordWrap = true;
		field.defaultTextFormat = format;
		field.mouseEnabled = true;
		
		field.addEventListener(MouseEvent.CLICK, clickHandler);
		
		img = new Loader();
		img.addEventListener(MouseEvent.CLICK, clickHandler);
		
		if (config['back'] == false) {
			back.alpha = 0;
			field.filters = new Array(new DropShadowFilter(0,45,0,1,2,2,10,3));
		}
	};

	/** Show/hide the captions **/
	public function hide(stt:Boolean):void {
		config['state'] = stt;
		visible = config['state'];
		if (config['state']) {
			if(button) { 
				button.field.text = 'is on'; 
			}
		} else { 
			if(button) { 
				button.field.text = 'is off'; 
			}
		}
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
		
		if (view.config['dock']) {
			button = view.getPlugin('dock').addButton(new DockIcon(),'is on', clickHandler);
		}
		hide(config['state']);
	};

	/** Check for captions with a new item. **/
	private function itemHandler(evt:ControllerEvent=null):void {
		current = 0;
		captions = new Array();
		config['file'] = undefined;
		field.htmlText = '';
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
		var video:Video = new XMLReader(new XML(evt.target.data)).extract();
		var elementArray:Array = video.elements; 
		
		for each (var element:Element in elementArray) {
			captions.push({begin:element.start, content:element.content, isText: element.isText,
							textColor: element.color, backgroundColor: element.backgroundColor,
							hasBackgroundColor: element.hasBackgroundColor, url: element.link.url,
							time: element.link.time, activityId: element.link.activityId,
							topLeft_x:element.x, topLeft_y:element.y,
							width:element.width, height:element.height});
			captions.push({begin:(element.start + element.duration), content:null, isText: element.isText,
							textColor: null, backgroundColor: null, url: element.link.url,
							time: element.link.time, activityId: element.link.activityId,
							hasBackgroundColor: element.hasBackgroundColor,
							topLeft_x:Infinity, topLeft_y:element.y,
							width:element.width, height:element.height});
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
			field.htmlText = txt+' ';
			resizeHandler();
			Logger.log(txt,'hipervideo');
		}
	};

	private var xmlLoaded:Boolean;

	/** Resize the captions if the display changes. **/
	private function resizeHandler(evt:ControllerEvent=undefined):void {
		back.height = field.height + 10;
		width = view.config['width'];
		scaleY = scaleX;
		y = view.config['height']-height;
		
		if (!xmlLoaded) {
			itemHandler(evt);
			xmlLoaded = true;
		}
	};

	/** Set a caption on screen. **/
	private function setCaption(pos:Number):void {
		for (var i:Number=0; i<captions.length; i++) {
			if (captions[i]['begin'] < pos && (i == captions.length - 1 || captions[i+1]['begin'] > pos)) {
				current = i;
				drawElement(i);
				Logger.log(captions[i]['content'],'hipervideo');
				return;
			}
		}
	};
	
	private function drawElement(i:Number):void {
		if (captions[i]['content'] != null) {
			if (captions[i]['isText']) {
				child = addChild(field);
				field.htmlText = captions[i]['content'];
				field.width = captions[i]['width'];
				field.height = captions[i]['height'];
				field.x = captions[i]['topLeft_x'];
				field.y = - captions[i]['topLeft_y'];
				field.textColor = captions[i]['textColor'];
				field.background = captions[i]['hasBackgroundColor'];
				field.backgroundColor = captions[i]['backgroundColor'];
				resizeHandler();
			} else {
				child = addChild(img);
				img.load(new URLRequest(captions[i]['content']));
				img.x = captions[i]['topLeft_x'];
				img.y = - captions[i]['topLeft_y'];
			}
		} else if (child != null) {
			removeChild(child);
			child = null;
		}
	}

	private function clickHandler(event:MouseEvent):void {
		if (captions[current]['activityId'] != "") {
			ExternalInterface.call('logActivity', captions[current]['activityId']);
		}
		
		if (captions[current]['url'] == "") {
			if (child != null) {
				removeChild(child);
				child = null;
			}
			view.sendEvent("SEEK", captions[current]['time']);
		} else {
			if (view.config['hipervideo.target'] != undefined){
				try {
				  navigateToURL(new URLRequest(captions[current]['url']), view.config['hipervideo.target']); 
				} catch (e:Error) {
				  trace("Error occurred!");
				}
			} else {
				try {
				  navigateToURL(new URLRequest(captions[current]['url'])); 
				} catch (e:Error) {
				  trace("Error occurred!");
				}
			}
		}
	}
	
	/** Check timing of the player to sync captions. **/
	private function stateHandler(evt:ModelEvent):void {
		visible = 
			(view.config['state'] == ModelStates.PLAYING || view.config['state'] == ModelStates.PAUSED) 
				&& config['state'];
		 	
		if (view.config['state'] == ModelStates.PAUSED) {
			field.x = Infinity;
			img.x = Infinity;
			if (child != null) {
				removeChild(child);
				child = null;
			}
		} else if (view.config['state'] == ModelStates.PLAYING) {
			forceReload = true;
		}
	};

	/** Check timing of the player to sync captions. **/
	private function timeHandler(evt:ModelEvent):void {
		var pos:Number = evt.data.position;
		if (captions && captions.length > 0 && (
			captions[current]['begin'] >= pos || (captions[current+1] && captions[current+1]['begin'] < pos))) {
			setCaption(pos);
		} else if (forceReload) {
			forceReload = false;
			setCaption(pos);
		}
	};

};

}