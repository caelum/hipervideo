var settings = {
	/** Player versions to embed in the testpage. **/
	players: {
		'4.5':'players/4.5.swf',
		'4.4':'players/4.4.swf',
		'4.3':'players/4.3.swf',
		'4.2':'players/4.2.swf',
		'4.1':'players/4.1.swf'
	},
	/** Available plugins (xml contains all info for flashvars). **/
	plugins: {
		controlling: {
			swf:'plugins/controlling/controlling.swf',
			xml:'plugins/controlling/controlling.xml',
		},
		docking: {
			swf:'plugins/docking/docking.swf',
			xml:'plugins/docking/docking.xml',
		},
		flashvars: {
			swf:'plugins/flashvars/flashvars.swf',
			xml:'plugins/flashvars/flashvars.xml',
		},
		listening: {
			swf:'plugins/listening/listening.swf',
			xml:'plugins/listening/listening.xml',
		},
		positioning: {
			swf:'plugins/positioning/positioning.swf',
			xml:'plugins/positioning/positioning.xml',
		}
	},
	/** Skins to embed in the testpage. **/
	skins: {
		none:'',
		bright:'skins/bright.swf',
		overlay:'skins/overlay.swf',
		simple:'skins/simple.swf',
		stylish:'skins/stylish.swf',
		swift:'skins/swift.swf',
		thin:'skins/thin.swf'
	},
	/** All the setup examples with their flashvars. **/
	examples: {
		'== select an example ==': {},
		'': {},
		'FLV video': {
			file:'../files/bunny.flv',
			image:'files/bunny.jpg',
			height:240,
			width:400
		},
		'MP3 audio': {
			file:'files/bunny.mp3',
			height:20,
			width:400
		},
		'JPG image': {
			file:'files/bunny.jpg',
			height:240,
			width:400
		},
		'RSS playlist': {
			file:'files/bunnies.xml',
			height:240,
			width:800,
			playlist:'right',
			playlistsize:400
		},
		' ': {
		},
		'Controlling plugin template': {
			file:'../files/bunny.flv',
			image:'files/bunny.jpg',
			plugins:'controlling',
			height:240,
			width:400
		},
		'Docking plugin template': {
			file:'../files/bunny.flv',
			image:'files/bunny.jpg',
			plugins:'docking',
			height:240,
			width:400
		},
		'Flashvars plugin template': {
			file:'../files/bunny.flv',
			image:'files/bunny.jpg',
			plugins:'flashvars',
			'flashvars.message':'hello world!',
			height:240,
			width:400
		},
		'Listening plugin template': {
			file:'../files/bunny.flv',
			image:'files/bunny.jpg',
			plugins:'listening',
			height:240,
			width:400
		},
		'Positioning plugin template': {
			file:'../files/bunny.flv',
			image:'files/bunny.jpg',
			plugins:'positioning',
			'positioning.position':'left',
			'positioning.size':200,
			height:240,
			width:600
		}
	}
}