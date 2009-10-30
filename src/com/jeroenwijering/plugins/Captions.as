/**
* Plugin for playing closed captions and a closed audiodescription with a video.
**/
package com.jeroenwijering.plugins {


import com.jeroenwijering.events.*;
import com.jeroenwijering.parsers.*;
import com.jeroenwijering.utils.Logger;

import flash.display.*;
import flash.events.*;
import flash.filters.DropShadowFilter;
import flash.net.*;
import flash.text.*;


public class Captions extends MovieClip implements PluginInterface {


	[Embed(source="../../../controlbar.png")]
	private const ControlbarIcon:Class;
	[Embed(source="../../../dock.png")]
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
	/** Icon for the controlbar. **/
	private var icon:Bitmap;
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


	public function Captions() {
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE,loaderHandler);
	};


	/** Clicking the  hide button. **/
	private function clickHandler(evt:MouseEvent):void {
		hide(!config['state']);
	};


	private function drawClip():void {
		back = new MovieClip();
		back.graphics.beginFill(0x000000,0.75);
		back.graphics.drawRect(0,0,400,20);
		addChild(back);
		format = new TextFormat();
		format.color = 0xFFFFFF;
		format.size = config['fontsize'];
		format.align = "center";
		format.font = "_sans";
		format.leading = 4;
		field = new TextField();
		field.width = 400;
		field.height = 10;
		field.y = 5;
		field.autoSize = "center";
		field.selectable = false;
		field.multiline = true;
		field.wordWrap = true;
		field.defaultTextFormat = format;
		addChild(field);
		if(config['back'] == false) {
			back.alpha = 0;
			field.filters = new Array(new DropShadowFilter(0,45,0,1,2,2,10,3));
		}
	};


	/** Show/hide the captions **/
	public function hide(stt:Boolean):void {
		config['state'] = stt;
		visible = config['state'];
		if(config['state']) {
			if(button) { 
				button.field.text = 'is on'; 
			} else { 
				icon.alpha = 1;
			}
		} else { 
			if(button) { 
				button.field.text = 'is off'; 
			} else {
				icon.alpha = 0.3;
			}
		}
		var cke:SharedObject = SharedObject.getLocal('com.jeroenwijering','/');
		cke.data['captions.state'] = stt;
		cke.flush();
	};


	/** Initing the plugin. **/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		view.addControllerListener(ControllerEvent.ITEM,itemHandler);
		view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
		view.addModelListener(ModelEvent.TIME,timeHandler);
		view.addModelListener(ModelEvent.STATE,stateHandler);
		view.addModelListener(ModelEvent.META,metaHandler);
		drawClip();
		mouseEnabled = false;
		mouseChildren = false;
		if(view.config['dock']) {
			button = view.getPlugin('dock').addButton(new DockIcon(),'is on',clickHandler);
		} else if (view.getPlugin('controlbar')) {
			icon = new ControlbarIcon();
			view.getPlugin('controlbar').addButton(icon,'captions',clickHandler);
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
		if (view.playlist[view.config['item']]['captions.file']){
			file = view.playlist[view.config['item']]['captions.file'];
		} else if (view.playlist[view.config['item']]['captions']){
			file = view.playlist[view.config['item']]['captions']; 
		} else if(view.config['captions.file']) {
			file = view.config['captions.file'];
		} else if(view.config['captions']) {
			file = view.config['captions'];
		}
		if(file) {
			config['file'] = file;
			try {
				loader.load(new URLRequest(config['file']));
			} catch (err:Error) {
				Logger.log(err.message,'captions');
			}
		}
	};


	/** Captions are loaded; now display them. **/
	private function loaderHandler(evt:Event):void {
		var ext:String = config['file'].substr(-3);
		if(ext == 'srt' || ext == 'txt') {
			captions = SRTParser.parseCaptions(String(evt.target.data));
		} else { 
			captions = TTParser.parseCaptions(XML(evt.target.data));
		}
		if(captions.length == 0) {
			Logger.log('Not a valid TimedText or SRT file.','captions');
		}
	};


	/** Check for captions in metadata. **/
	private function metaHandler(evt:ModelEvent):void {
		var txt:String;
		var fnd:Boolean;
		if(evt.data.type == 'caption') {
			txt = evt.data.captions;
			fnd = true;
		} else if (evt.data.type == 'textdata') {
			txt = evt.data.text;
			fnd = true;
		}
		if(fnd == true) {
			field.htmlText = txt+' ';
			resizeHandler();
			Logger.log(txt,'caption');
		}
	};


	/** Resize the captions if the display changes. **/
	private function resizeHandler(evt:ControllerEvent=undefined):void {
		back.height = field.height + 10;
		width = view.config['width'];
		scaleY = scaleX;
		y = view.config['height']-height;
	};


	/** Set a caption on screen. **/
	private function setCaption(pos:Number):void {
		for(var i:Number=0; i<captions.length; i++) {
			if(captions[i]['begin'] < pos && (i == captions.length - 1 || captions[i+1]['begin'] > pos)) {
				current = i;
				field.htmlText = captions[i]['text'];
				resizeHandler();
				Logger.log(captions[i]['text'],'caption');
				return;
			}
		}
	};


	/** Check timing of the player to sync captions. **/
	private function stateHandler(evt:ModelEvent):void {
		if((view.config['state'] == ModelStates.PLAYING ||
		 	view.config['state'] == ModelStates.PAUSED) && config['state']) {
			visible = true;
		} else {
			visible = false;
		}
	};


	/** Check timing of the player to sync captions. **/
	private function timeHandler(evt:ModelEvent):void {
		var pos:Number = evt.data.position;
		if(captions && captions.length > 0 && (
			captions[current]['begin'] > pos || 
			(captions[current+1] && captions[current+1]['begin'] < pos))) {
			setCaption(pos);
		}
	};


};


}