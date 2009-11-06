
package com.neoarchaic.ui
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.filters.DropShadowFilter;
	
	/**
	 * <p>A Customizable static Singleton Class for generating and displaying Tooltips from anywhere in your code. 
	 * There are no assests for the library, since the tooltip is created and drawn dynamically.</p>
	 * 
	 * <p>The tooltip is created by invoking the static Tooltip class methods: Tooltip.show() and Tooltip.hide() 
	 * DisplayObject instances can also subscribe and unsubscribe themselves from the tooltip for automatic handling.
	 * See method documentation for each method.</p>
	 * 
	 * <p>The text is rendered using html and styled with CSS. The body text is wrapped with <tooltip></tooltip> tags 
	 * and the main stylesheet uses the "tooltip" xml selector to format the text, 
	 * but additional selectors can be used to format various html entities</p>
	 * 
	 * <p>All the Tooltip's options can be customise both globally and locally.<br/>
	 * For global customisation, use the static get/set options method to pass an object containing one or more options,
	 * or set them one at a time using the static setOption () method. <br/>
	 * For local customisation of individual tooltips, pass an options object to the static Tooltip.show () method, or register the options with the subscribe(method).</p> 
	 * 
	 * <p>The Tooltip uses a fadeIn/fadeOut animation by default, so fonts are also embedded by default - but only if the font corresponding to the fontFamily option is embedded in the Flash file. When a comma separated list of fonts is used for fontFamily, the code uses the first located font and ingores all others.<br/> However, overriding or additional fonts in the styleSheet option are not checked, so you need to make sure that all those fonts are embedded or turn off the automatic embedding using the embedFonts option.</p>
	 * 
	 * <p>By default, the Tooltip's background is a rounded rectangle, with customisable corner rounding. The backgroundColor, lineColor, alpha transparacy, and dropShadow are all customisable using the options. <br/>
	 * To use a different background, for example a Symbol in the library, you can pass a customBackground option. 
	 * This attaches a MovieClip or other DisplayObject as the tooltip's background property. <br/>
	 * The custom background is then streched to the default dimensions (text width and height plus margins), but for extra control you can also access the Tooltip's instance properties from within the background instance using parent.getDimensions() / parent.getLocalOptions() (or the equivalent Tooltip.getInstance().getDimensions()). </p>
	 * 
	 * <p>To set all the margins at once, use the margin property. To override specific margins, use marginLeft, marginRight, marginTop, or marginBottom. Can be helpful for adjusting the text with non-rectangular custom backgrounds. </p>
	 * 
	 * <p>For non standard implementations, if you want the tooltip displayed in a fixed spot on the stage (eg, for a status bar or speech bubble), you can use offsetX and offsetY together with fixedPosition - the offset will be relative to the stage instead of the mouse. You can also use fixedWidth to prevent the tooltip from shrinking to fit a single line, and boundingRect to constrain it to an area other than the stage.</p>
	 * 
	 * <p>To register the tooltip with the Stage, you need to pass the Tooltip a target DisplayObject that is registered with the stage, at least once in the programme's lifetime. You can chose one of several ways to do so:
	 * Subscribe a target DisplayObject to the tooltip - this will automatically attach the tooltip to the Stage the moment the target becomes a child of the Stage.<br/>
	 * or - Call Tooltip.getInstance(target) once before using the Tooltip.<br/>
	 * or - Pass an optional "target" parameter to the Tooltip.show() method<br/>
	 * For example: Tooltip.show("Tooltip Text", null, target)</p>
	 * 
	 * <p>To make it easier to extend, the code for displaying the tooltip is broken-up into protected methods.</p>
	 * 
	 * <p>TOOLTIP OPTIONS:
	 * <listing>
	 * delay:Number (default: 0.5 seconds) delay in seconds 
	 * width:Number (defalut: 200) maximum width of the tooltip rectangle (default: 200px)
	 * alpha:Number (default: 0.8) Alpha transparency of the tooltip's background
	 * corner:Number (default: 10) The diameter for the rounded corner. For sharp corners pass 0)
	 * margin:Number (default: 4) Overall margin
	 * marginLeft:Number (default: Tooltip.MARGIN) Left margin. Defaults to the overall margin value
	 * marginRight:Number (default: Tooltip.MARGIN) Left margin. Defaults to the overall margin value
	 * marginTop:Number (default: Tooltip.MARGIN) Left margin. Defaults to the overall margin value
	 * marginBottom:Number (default: Tooltip.MARGIN) Left margin. Defaults to the overall margin value
	 * color:Color Text and line color, can also accept a string hex value (default 0x000000)		
	 * backgroundColor:int Background color of the tooltip (default: 0xFFFFDD - light yellow)
	 * shadowColor:int (default: Tooltip.COLOR_TEXT) Drop shadow colour. By default duplicates the color property.
	 * shadowType:int (default: Tooltip.SHADOW_HOLLOW), ) 
	 * lineColor:Color (default: Tooltip.COLOR_TEXT) COLOR_TEXT uses same colour as the options.color. For no line use COLOR_NONE.
	 * customBackground:DisplayObject (defult:null) If true overrides background and line colour settings and inserts a custom class as background. The mc is automatically stretched to fit the dimensions, but can use getDimensions() and getLocalOptions() methods of the Tooltip instance to adjust itself.
	 * styleSheet:TextField.StyleSheet (default: null) Use to extend the default stylesheet. 
	 * fontFamily:String (default: "Verdana,Helvetica,_sans") Can be a single font or a comma separated list of fonts (no spaces between commas allowed). 
	 * fontSize:Number Font size (default: 11)
	 * fontWeight:String (default: "normal")
	 * leading:Number line spacing (default: 2)
	 * textAlign:String (default: TextFormatAlign.LEFT)
	 * embedFonts:Boolean (default: true) If true, will first check if the embedded font passed in the fontFamily option is available (if it's a list of fonts, it will use the first available font in the list). If set to false, it will not embed the fonts regardles of availability.
	 * followMouse:Boolean (default: true) If true the tooltip will follow mouse
	 * duration:Number or Boolean (default:1) The duration of the fadeIn/fadeOut animation.	
	 * offsetX:Number (default 20) Horizontal distance from mouse. 
	 * offsetY:Number (default 25) Vertical distance from mouse. 
	 * fixedPosition:Boolean (default: false) - If true, the tooltip will appear in a fixed position on the stage, instead of at the mouse position. A fixed tooltip will not adjust to Stage dimensions or follow the mouse. 
	 * fixedWidth:Boolean (default: false) don't adjust the width of a single line tooltip.
	 * boundingRect:Object (default: Tooltip.STAGE_RECT) set the constraining bounds to other than the stage (x, y, width, height); 
	 * </listing>
	 * 
	 * @example
	 * <listing> 
	 * import com.neoarchaic.ui.Tooltip;
	 * Tooltip.options = {width: 500, margin:10}
	 * Toolip.subscribe(this, "I'm a subscribed tooltip", {backgroundColor:0x000000, color:"#FFFFFF});
	 * Tooltip.show("I'm a tooltip. &lt;br/&gt;I'm 500 pixels wide and have a 10 pixel margin");
	 * Tooltip.show("I'm a delayed tooltip.", {delay: 2});
	 * Tooltip.hide();	 
	 * Tooltip.unsubscribe(this);
	 * </listing>
	 * 
	 * <p>AUTHOR:<br/>
	 * Karina Steffens <br/>
	 * Neo-Archaic <br/>
	 * <a href = "http://www.neo-archaic.net"> www.neo-archaic.net </a></p>
	 * 
	 * <p>HISTORY:<br/>
	 * Created:  December 2008<br/>
	 * NOTE: This is a complete rewrite of the old AS2 com.neoarchaic.ui.Tooltip class, with different option names and defaults </p>
	 * 
	 */
	public class  Tooltip extends Sprite {

		//CONSTANTS		
		/**No Drop shadow*/
		public static const SHADOW_NONE:int = 0;
		/**The default hollow drop shadow (doesn't display behind the tooltip)*/
		public static const SHADOW_HOLLOW:int = 1;
		/**Full drop shadow*/
		public static const SHADOW_FULL:int = 2;
		/**Use the same colour as the text (options.color)*/
		public static const COLOR_TEXT:int = -1;
		/**No Colour*/
		public static const COLOR_NONE:int = -2;
		/**Use the value set in options.margin (for marginLeft, marginRight etc.)*/
		public static const MARGIN:String = "margin";
		/**Use the stage as the constraining rectangle*/
		public static const STAGE_RECT:Object = { };
		
		//PRIVATE PROPERTIES
		private static var instance:Tooltip;
		private static var allowInstantiation:Boolean = false;
		private static var delayTimer:Timer;
		private var options:Object;
		private var defOptions:Object;
		private var globalOptions:Object;		
		private var keys:Dictionary;
		private var currentProps:Object;
		private var background:Sprite;
		private var tipText:TextField;		
		private var tipWidth:Number;
		private var tipHeight:Number;
		private var chunk:Number;
		
		/**
		 * Constructor - Only to be used via the "getInstance" option.
		 */
		public function Tooltip() {	
			if (!allowInstantiation) {
				throw(new Error("Tooltip: Singleton Class - use Tooltip.show() or Tooltip.subscribe()"));
				return;
			}
			keys = new Dictionary(true);
			//Default options
			defOptions = { 
				delay:0.5,
				width:200,
				alpha:.8,
				corner:10,
				margin:4,
				marginLeft:Tooltip.MARGIN,
				marginRight:Tooltip.MARGIN,
				marginTop:Tooltip.MARGIN,
				marginBottom:Tooltip.MARGIN,
				color:"#000000",
				backgroundColor:0xFFFFDD,
				shadowColor:Tooltip.COLOR_TEXT,				
				shadowType: Tooltip.SHADOW_HOLLOW,				
				lineColor:Tooltip.COLOR_TEXT,
				customBackground:null,
				styleSheet:null,
				fontFamily:"Verdana,Helvetica,_sans",				
				fontSize:11,
				fontWeight:"normal",
				leading:2,
				textAlign:TextFormatAlign.LEFT,
				embedFonts:true,
				followMouse:true,
				duration:1,
				offsetX:20,
				offsetY:25,
				fixedPosition:false,
				fixedWidth:false,
				boundingRect:Tooltip.STAGE_RECT
			};
			//Set global options to defaults
			resetDefaultOptions();
			//Disable mouse events on the tooltip
			mouseEnabled = false;
			mouseChildren = false;			
		}
		
		//PUBLIC STATIC METHODS
		
		/**
		 * Initiate the Tooltip: 
		 * Create/Return a singleton instace
		 * Register with the stage by passing a stage-enabled DisplayObject
		 * Invoked automatically by subscribing a DisplayObject or passing a target to Tooltip.show()
		 * @param	target Optional
		 * @return Tooltip Instance
		 */
		public static function getInstance(target:DisplayObject  = null):Tooltip {
			if (Tooltip.instance == null) {
				allowInstantiation = true;
				Tooltip.instance = new Tooltip();
				allowInstantiation = false;
				delayTimer = new Timer(options.delay, 1);
				delayTimer.addEventListener(TimerEvent.TIMER, instance.doShow);
			}
			if (target != null){
				if (Tooltip.instance.stage == null) {
					if (target.stage != null) {
						target.stage.addChild(Tooltip.instance);
						target.stage.addEventListener(Event.MOUSE_LEAVE, Tooltip.instance.hideListener);
						Tooltip.instance.removeStageEvent();	
					}else {
						target.addEventListener(Event.ADDED_TO_STAGE, instance.stageListener);
					}
				}
			}
			return Tooltip.instance;
		}
		
		/**
		 * Show the tooltip
		 * @param	tooltip The tooltip text to show
		 * @param	options Local (overriding) options 
		 * @param	target - optional target for registering with the stage
		 */
		
		public static function show(tooltip:String = "", localOptions:Object = null, target:DisplayObject = null):void {
			//trace (Tooltip.className, "show", arguments);
			var instance:Tooltip = Tooltip.getInstance(target);
			if (instance.stage != null && tooltip != "" && tooltip != null) {
				Tooltip.hide();
				instance.currentProps = { tooltip:tooltip, options:localOptions, target:target};
				var delay:Number = localOptions != null && localOptions.delay != undefined ? localOptions.delay  : options.delay;
				delayTimer.delay = delay * 1000;
				delayTimer.start();
			}
		}	
				
		/**
		 * Hide the tooltip
		 */
		public static function hide():void{
			delayTimer.stop();
			instance.doHide();
		}
		
		
		/**
		 * Get/Set multiple multiple <a href="#tooltipOptions">global options</a> 
		 */
		public static function get options ():Object {
			return instance.globalOptions;
		}
		
		/** 
		 * Get/Set multiple multiple global options
		 * @param options:Object Defines the display properties of the tooltip
		 */
		public static function set options(newOptions:Object):void {
			for (var i:String in newOptions) {
				var optionValue:* = newOptions[i];
				if( optionValue !== undefined){
					instance.globalOptions[i] = optionValue;
				}
			}
		}
				
		/** Change a single <a href="#tooltipOptions">global option</a>
		* @param optionName The property name of the option.
		* @param optionValue The new value for the option.
		*/
		public static function setOption(optionName:String, optionValue:*):void {
			instance.globalOptions[optionName] = optionValue;
		}
		
		/** Get the value of a single global option
		* @param optionName The property name of the option.
		*/
		public static function getOption(optionName:String):* {
			return instance.globalOptions[optionName];
		}
		
		/** Get the value of a single default option
		* @param optionName The property name of the option.
		*/
		public static function getDefaultOption(optionName:String):* {
			return instance.defOptions[optionName];
		}		
		
		/**
		 * Reset global options to defaults
		 */
		public static function resetDefaults():void {
			instance.resetDefaultOptions();
		}
				
		/**
		 * Subscribe the Tooltip - register MouseEvent 
		 * @param	target
		 * @param	tipText
		 * @param	options 
		 */
		public static function subscribe(target:DisplayObject, tooltip:String = "", options:Object = null):void {
			if (target == null) {
				return;
			}
			var instance:Tooltip = getInstance(target);
			if (instance.stage == null){
				target.addEventListener(Event.ADDED_TO_STAGE, instance.stageListener, false, 0, true);				
			}
			instance.addTargetProps(target, tooltip, options);	
			target.addEventListener(MouseEvent.ROLL_OVER, instance.showListener, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OUT, instance.hideListener, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_DOWN, instance.hideListener, false, 0, true);					
			target.addEventListener(MouseEvent.CLICK, instance.hideListener, false, 0, true);	
		}
				
		
		/**
		 * Unsubscribe the Tooltip
		 * @param	target
		 */
		public static function unsubscribe(target:DisplayObject):void {
			if (target == null) {
				return;
			}
			var instance:Tooltip = getInstance(target);
			if (instance.getProps(target) == null) {
				return;
			}
			target.removeEventListener(MouseEvent.ROLL_OVER, instance.showListener);
			target.removeEventListener(MouseEvent.ROLL_OUT, instance.hideListener);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, instance.hideListener);			
			target.removeEventListener(MouseEvent.CLICK, instance.hideListener);
			target.removeEventListener(Event.ADDED_TO_STAGE, instance.stageListener);
			target.removeEventListener(Event.MOUSE_LEAVE, instance.hideListener);	
			if (instance.getProps(target) == instance.currentProps) {
				Tooltip.hide();
			}
			instance.removeTargetProps(target);
		}
		
		//PUBLIC METHODS
			
		/**
		 * Retrieve the current local options object
		 * Could be used from the customBackground clip to get the options of a currently displayed Tooltip instance.
		 */
		public function getLocalOptions():Object{
			return instance.options;
		}
		
		/**
		 * Retrieve the current local options object
		 * Could be used from the customBackground clip to get the options of a currently displayed Tooltip instance.
		 */
		public function getDimensions():Object{
			return {width:tipWidth, height:tipHeight};
		}
				
		//EVENT LISTENERS		
		
		/**
		 * Listener for showing the tooltip. 
		 * @param	e
		 */
		private function showListener(e:MouseEvent):void {
			//trace ("showListener", e.toString());
			if (e.buttonDown) {
				return;
			}			
			var target:DisplayObject = e.target as DisplayObject;		
			var props:Object = Tooltip.instance.getProps(target);
			if (props != null) {
				if (props.tootlip != "") {
					Tooltip.show(props.tooltip, props.options, target);
				}
			}
		}
		
		/**
		 * Listener for hiding the tooltip
		 * @param	e
		 */
		private function hideListener(e:Event):void {
			//trace ("hideListener", e.toString());
			Tooltip.hide();
		}
		
		/**
		 * Listener for hiding the tooltip
		 * @param	e
		 */
		private function stageListener(e:Event):void {
			//trace ("stageListener");
			Tooltip.getInstance(e.target as DisplayObject);
			removeStageEvent();
		}
		
		//PROTECTED METHODS
		
		/**
		 * Create tooltip elements and place as the top child of the stage.
		 * Broken up into multiple protected functions for easier inheritance.
		 * @param	e
		 */
		protected function doShow(e:TimerEvent):void {
			if (stage == null) {
				return;
			}
			var localOptions:Object = currentProps.options;
			
			//Merge the locally passed overriding options with the global options in a new object.
			options = new Object();
			for (var i:String in globalOptions) {
				options[i] = localOptions == null || localOptions[i] === undefined ? globalOptions[i] : localOptions[i];
			}
			
			createText();
			placeTip()	
			
			//Call a method to draw a new background
			if (background != null && contains(background)) {
				removeChild(background);
			}
			if (options.customBackground == null){
				drawBackground();
			}else {
				attachBackground();
			}
			addChild(background);
			addChild(tipText);
			
			//Move on top of the other children on the stage
			stage.setChildIndex(this, stage.numChildren - 1);
			visible = true;
		
			//Make the tooltip follow the mouse
			if (options.followMouse && !options.fixedPosition) {
				addEventListener(Event.ENTER_FRAME, placeTip);
			}			
			animate();			
		}		
		
		/**
		 * Hide the tooltip - if animated, initiate the fadeout.
		*/
		protected function doHide():void {			
			removeEventListener(Event.ENTER_FRAME, placeTip);	
			removeEventListener(Event.ENTER_FRAME, fadeIn);				
			if (options && options.duration) {	
				addEventListener(Event.ENTER_FRAME, fadeOut);
			}else{
				visible = false;
			}
		}
		
		/**
		 * Create, position, and style a new TextField for the tooltip
		 */
		protected function createText():void {
			if (currentProps != null){
				var tooltip:String = currentProps.tooltip;
				if (tooltip == null) {
					return;
				}
			}
			
			if (tipText != null) {
				removeChild(tipText);
			}

			tipText = new TextField();
			autoEmbed();
			

						
			//Wrap the text for the main stylesheet
			if (tooltip.indexOf("<tooltip") == -1){
				tooltip = "<tooltip>" + tooltip + "</tooltip>";
			}
			setStyles();
			tipText.htmlText = tooltip;	
			
			//Set dimensions and position
			tipText.autoSize = "left";
			tipWidth = tipText.width+1;
			tipText.wordWrap = true;
			//var margins:Number = options.margin * 2;
			var ar:Array = ["marginRight", "marginLeft", "marginTop", "marginBottom"];
			for each (var m:String in ar) {
				if (options[m] == Tooltip.MARGIN) {
					options[m] = options.margin;
				}
			}
			var margins:Number = options.marginLeft + options.marginRight;
			var marginsV:Number = options.marginTop + options.marginBottom;
			tipText.width = options.width - margins;
			if (!options.fixedWidth) {
				tipWidth = Math.min(tipWidth, tipText.width);
				tipText.width = tipWidth;				
			}	
			tipWidth += margins;
			tipHeight =  tipText.height + marginsV;	
			tipText.x = options.marginLeft;
			tipText.y = options.marginTop;
		}
		
		/**
		 * Embed the fonts if options.embedFonts is true and the embedded fontFamily is present.
		 * If a list of fonts is passed for options.fontFamily, the first embedded font that is found replaces the entire list.
		 */
		protected function autoEmbed():void {
			if (options.embedFonts) {
				var fonts:Array = Font.enumerateFonts();
				//Cylce through the fonts in options.fontFamily
				var families:Array = options.fontFamily.split(",");
				for (var i:int = 0; i < families.length; i++){
					var family:String = families[i];
					//Cylce through embedded fonts
					for each (var font:Font in fonts) {
							if (font.fontName == family) {
								//Embed the font if found
								tipText.embedFonts = true;
								//Make sure there's only one fontFamily, or the embedding will fail
								options.fontFamily = family;							
								return;
							}
					}					
				}
				tipText.embedFonts = false;
			}
			tipText.embedFonts = false;
		}
		/**
		 * Set the stylesheet for the textFiled
		 */
		protected function setStyles():void{			
			var style:StyleSheet;
			if (options.styleSheet is StyleSheet){
				style = options.styleSheet;
			}else{
				style = new StyleSheet ();
			}		
			var styleObj:Object = style.getStyle("tooltip");
			if (styleObj == null) {
				styleObj = new Object();
			}
			if (styleObj.color == null){
				if (options.color is String){
					styleObj.color = options.color;
				}else{
					//Convert a color object to a hex string
					var clr:String = options.color.toString(16);
					while (clr.length < 6){
						clr = "0" + clr;
					}
					clr = "#" + clr;
					styleObj.color = clr;
				}
			}
			if (styleObj.fontFamily == null || tipText.embedFonts){
				styleObj.fontFamily = options.fontFamily;
			}
			if (styleObj.fontSize == null){
				styleObj.fontSize = options.fontSize.toString ();
			}
			if (styleObj.textAlign == null){
				styleObj.textAlign = options.textAlign;
			}
			if (styleObj.fontWeight == null) {
				styleObj.fontWeight = options.fontWeight;
			}
			if (styleObj.leading == null) {
				styleObj.leading = options.leading;
			}			
			style.setStyle ("tooltip", styleObj);	
			tipText.styleSheet = style;
		}
		
		/**
		 * Draw a rounded rectangle background with drop shadow
		 */
		protected function drawBackground():void {
			//Make the line colour the same as the font colour
			if (options.lineColor == Tooltip.COLOR_TEXT) {
				options.lineColor = options.color;
			}
			
			//Make the shadow colour the same as the font colour
			if (options.shadowColor == Tooltip.COLOR_TEXT) {
				options.shadowColor = options.color;
			}
			
			if (options.alpha){
				background = new Sprite();
				var rect:Shape = new Shape();
				rect.graphics.beginFill(options.backgroundColor, options.alpha);
				if (options.lineColor != Tooltip.COLOR_NONE){
					rect.graphics.lineStyle(1, options.lineColor, options.alpha, true  );
				}
				rect.graphics.drawRoundRect(0, 0, tipWidth, tipHeight, options.corner, options.corner);
				//Create a drop shadow filter
				if (options.shadowType != Tooltip.SHADOW_NONE && options.shadowColor != Tooltip.COLOR_NONE){
					var myFilter:DropShadowFilter = new DropShadowFilter ();
					myFilter.quality = 2;
					myFilter.alpha = options.alpha ;
					myFilter.distance = 2;
					myFilter.knockout = true;
					myFilter.color = options.shadowColor;
					if (options.shadowType == Tooltip.SHADOW_HOLLOW){		
						//Draw a clip for the knockout drop shadow
						var shadow:Sprite = new Sprite();	
						shadow.graphics.beginFill(0x000000);
						shadow.graphics.drawRoundRect(0, 0, tipWidth, tipHeight, options.corner, options.corner);
						myFilter.knockout = true;
						shadow.filters = [myFilter];
						background.addChild(shadow);			
					}else if (options.shadowType == Tooltip.SHADOW_FULL) {
						//Apply the drop shadow directly to the rect
						rect.filters = [myFilter];
					}
				}
				background.addChild(rect);

			}			
		}
		
		/**
		 * Attach a custom background
		 */
		protected function attachBackground():void {
			background = new options.customBackground();
			background.width = tipWidth;
			background.height = tipHeight;
		}
		
		/**
		 * Place the tip at the cursor's position or static location and constrain to stage
		 */
		protected function placeTip(e:Event = null):void {
			var wmin:Number;
			var wmax:Number;
			var hmin:Number;
			var hmax:Number;
			
			if (options.boundingRect == Tooltip.STAGE_RECT) {
				wmin = 0
				wmax = stage.stageWidth;
				hmin = 0
				hmax = stage.stageHeight;
			}else{
				wmin = options.boundingRect.x;
				wmax = options.boundingRect.x + options.boundingRect.width;
				hmin = options.boundingRect.y;
				hmax = options.boundingRect.y + options.boundingRect.height;
			}

			if (options.fixedPosition){
				x = options.offsetX;
				y = options.offsetY;
			} else {
				x = stage.mouseX + options.offsetX;
				y = stage.mouseY + options.offsetY;
				
				//Constrain to the boundries of the stage
				var r:Number = width + x;
				var l:Number = height + y;
				if (wmax < r) {
					//Move the Tooltip to the left
					x -= r - wmax;
					//Constrain to stage left
					x = Math.max(wmin, x);
				}
				if (hmax < l) {
					//Move the Tooltip above the cursor
					y -= (height + options.offsetY);
					//Constrain to stage top
					y = Math.max(hmin, y);
				}	
			}
		}
		
		/**
		 * Start the fadeIn animation, based on frameRate and duration
		 */
		protected function animate():void {
			removeEventListener(Event.ENTER_FRAME, fadeOut);
			if (options.duration){
				alpha = 0;					
				chunk = (1/stage.frameRate) / options.duration
				addEventListener(Event.ENTER_FRAME, fadeIn);
			}else{
				alpha = 1;
			}
		}
		
		
		//PRIVATE METHODS		
		
		//Add the passed arguments to the keys Dictionary.
		private function addTargetProps(target:DisplayObject, tooltip:String = "", options:Object = null):void {			
			var props:Object = { target:target, tooltip:tooltip, options:options };
			keys[target] = props;
		}
		
		//Add the target the keys Dictionary.
		private function removeTargetProps(target:DisplayObject):void {
			delete keys[target];
		}		
		
		//Retrieve the object that contians the target
		private function getProps(target:DisplayObject):Object {
			return keys[target];
		}
		
		//Save the tooltip, options, and current target in an object
		private function setCurrentProps (tooltip:String = "", options:Object = null, target:DisplayObject = null):void {
				currentProps = { tooltip:tooltip, options:options, target:target};
		}
		
		//Set all global options to defaults
		private function resetDefaultOptions():void {
			globalOptions = new Object();
			for (var i:String in defOptions) {
				globalOptions[i] = defOptions[i];
			}	
		}
		
		//Remove the Added to Stage Event
		private function removeStageEvent():void {
			for each (var props:Object in keys) {
				props.target.removeEventListener(Event.ADDED_TO_STAGE, stageListener);
			}
		}
		
		//FadeIn animation
		private function fadeIn(e:Event):void {			
			alpha += chunk;	
			if (alpha >= 1) {
				alpha = 1;
				removeEventListener(Event.ENTER_FRAME, fadeIn);
			}
		}
		
		//FadeOut animation
		private function fadeOut(e:Event):void {
			alpha -= chunk;
			if (alpha <= 0) {
				alpha = 0;
				visible = false;
				removeEventListener(Event.ENTER_FRAME, fadeOut);
			}
		}
	}
	
	
	
}