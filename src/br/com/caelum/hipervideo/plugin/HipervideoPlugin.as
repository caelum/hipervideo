package br.com.caelum.hipervideo.plugin {


import br.com.caelum.hipervideo.model.Action;
import br.com.caelum.hipervideo.model.ActionType;
import br.com.caelum.hipervideo.model.Element;
import br.com.caelum.hipervideo.model.ElementType;
import br.com.caelum.hipervideo.model.Hipervideo;
import br.com.caelum.hipervideo.model.Link;
import br.com.caelum.hipervideo.reader.XMLReader;

import com.jeroenwijering.events.*;
import com.jeroenwijering.parsers.*;
import com.jeroenwijering.utils.Logger;
import com.jeroenwijering.utils.Strings;

import flash.display.*;
import flash.events.*;
import flash.external.ExternalInterface;
import flash.net.*;
import flash.text.*;

public class HipervideoPlugin extends MovieClip implements PluginInterface {

	[Embed(source="../../../../../dock.png")]
	private const DockIcon:Class;

	private var playfile:String;
	private var loader:URLLoader;
	private var view:AbstractView;
	private var back:MovieClip;
	private var captions:Array;
	private var actions:Array;
	private var lastPos:Number = Infinity;
	private var currentTime:Number;
	private var xmlLoaded:Boolean;
	
	/** Inicializa o plugin. **/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		view.addControllerListener(ControllerEvent.RESIZE,resizeHandler);
		view.addModelListener(ModelEvent.TIME,timeHandler);
		view.addModelListener(ModelEvent.STATE,stateHandler);
		view.addModelListener(ModelEvent.META,metaHandler);
		view.addControllerListener(ControllerEvent.SEEK, seekHandler);
		
		view.config['HipervideoPlugin'] = this;
		
		drawClip();
		disablePauseClick();
	};
	
	private function drawClip():void {
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE,loaderHandler);
		
		back = new MovieClip();
		back.graphics.beginFill(0x000000,0.75);
		back.graphics.drawRect(0,0,400,260);
		back.graphics.endFill();
		addChild(back);
		back.alpha = 0;
	};

	/** Desabilita play/pause com cliques sobre o vídeo */
	private function disablePauseClick():void {
		new TextElement(
			new Element(ElementType.TEXT, "",
				new Link(null, null, null, null, null, 0, null, null),
				0, "", 1, -Infinity, Infinity, 0, 0, view.config['width'], view.config['height'],0),
			this, view);
	}

	/** Carrega arquivo. **/
	private function loadFile(evt:ControllerEvent=null):void {
		playfile = undefined;
		var file:String;
		
		file = view.config['hipervideo.file'];
		trace("lendo arquivo " + file);

		if (file) {
			playfile = file;
			try {
				loader.load(new URLRequest(playfile));
			} catch (err:Error) {
				Logger.log(err.message,'hipervideo');
			}
		}
	};
		
	private function loadNextVideo():void {
		notifyNextVideo();
		view.config['StateManager'].notifyNextVideo();
	}
	
	public function notifyNextVideo():void {
		if (view.config['next'] != null && view.config['next'] != "") {
			view.config['hipervideo.file'] = view.config['next'];
			drawClip();
			xmlLoaded = false;
			resizeHandler();
		}
	}


	/** Captions are loaded; now display them. **/
	private function loaderHandler(evt:Event):void { 
		var hipervideo:Hipervideo = new XMLReader(new XML(evt.target.data)).extract();
		captions = hipervideo.elements;
		actions = hipervideo.actions; 
		
		view.sendEvent(ViewEvent.LOAD, hipervideo.video);
		
		if (captions.length == 0) {
			Logger.log('Not a valid file.','hipervideo');
		}
		
		if (view.config['next'] != null && view.config['next'] != "") {
			view.sendEvent(ViewEvent.NEXT);
		}
		
		view.config['next'] = hipervideo.next;
	};
	
	/** Quando a posicao do vídeo for alterada pela barra de busca,
	 * não executar nenhum javascript indesejado */
	private function seekHandler(evt:ControllerEvent):void {
		lastPos = Infinity;
	}

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

	/** Lida com mudanças de tamanho. **/
	private function resizeHandler(evt:ControllerEvent=undefined):void {
		width = view.config['width'];
		height = view.config['height'];
		
		if (!xmlLoaded) {
			loadFile(evt);
			xmlLoaded = true;
		}
	};

	/** Detecta fim da reproducao vídeo e prepara carregamento do seguinte **/
	private function stateHandler(evt:ModelEvent):void {
		visible = ( view.config['state'] == ModelStates.PLAYING ||
					view.config['state'] == ModelStates.PAUSED );
		switch (evt.data.newstate) {
			case ModelStates.COMPLETED:
				loadNextVideo();
				break;
		}
	};

	/** Exibe baloes e executa funcoes JS nos momentos determinados. **/
	private function timeHandler(evt:ModelEvent):void {
		var pos:Number = evt.data.position;
		currentTime = pos;
		
		for (var i:Number = 0; i < captions.length; i++) {
			if (captions[i].start < pos && captions[i].end > pos && !captions[i].active) {
				drawElement(captions[i]);
			}
		} 
		for (var next:Number = 0; next < actions.length; next++) {
			if (actions[next].time < pos && actions[next].time >= lastPos) {
				performAction(actions[next]);
			}
		}
		
		lastPos = pos;
	};
		
	/** Logica para lidar com cliques em baloes */
	public function clickHandler(element:Element, clip:MovieClip):void {
		if (element.link.activityId != "" && element.link.activityId != null) {
			receive_notification_from_activity_log(ExternalInterface.call('logActivity', element.link.activityId, currentTime));
		}
		
		if (element.link.action == ActionType.PLAY || element.link.action == ActionType.PAUSE) {
			if (element.link.action == ActionType.PLAY) {
				clip.shouldRemove = true;
			}
			view.config['autoPaused'] = true;
			view.sendEvent(ControllerEvent.PLAY, element.link.action == ActionType.PLAY);
		}

		if (element.link.url != null && element.link.url != "") {
			try {
			  navigateToURL(new URLRequest(element.link.url), element.link.target); 
			} catch (e:Error) {
			  trace("Error occurred!");
			}
		} else if (element.link.time != 0){
			view.sendEvent("SEEK", element.link.time);
		} else if (element.link.video != "") {
			view.config['next'] = element.link.video;
			loadNextVideo();
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
	

	private function drawElement(caption:Object):void {
		caption.build(this, view);
		resizeHandler();
	}
	
	/** Usado para executar uma acao JS disparada por tempo */
	private function performAction(action:Action):void {
		if (action.type == ActionType.ACTIVITY) {
			receive_notification_from_activity_log(ExternalInterface.call('logActivity', action.data.toString(), currentTime));
		}
	}
	
	/** Pega a resposta de uma chamada JS e coloca na tela os baloes presentes na resposta */
	public function receive_notification_from_activity_log(response:Object):void {
		if (response != null) {
			for each (var elem:Object in response) {
				if (elem['id'] == "Element") { 
					var data:Object = elem['value'];
					var newElement:Element = new Element(
						data['type'], 
						data['content'],
						new Link(
							data['link']['activityId'], 
							data['link']['tooltip'], 
							data['link']['thumbnail'], 
							data['link']['url'], 
							data['link']['target'], 
							data['link']['time'], 
							data['link']['video'], 
							data['link']['action']),
						uint(data['color']), 
						data['backgroundColor'],
						data['alpha'] == undefined ? 1 : data['alpha'], 
						Strings.seconds(data['begin']),
						Strings.seconds(data['duration']),
						data['x'], data['y'], data['width'], data['height'], 1);
					newElement.active = data['active'];
					
					drawElement(newElement);
				}
			}
		}
	}
};

}