package test.br.com.caelum.hipervideo.reader
{
	import asunit.framework.TestCase;
	
	import br.com.caelum.hipervideo.model.ActionType;
	import br.com.caelum.hipervideo.model.ElementType;
	import br.com.caelum.hipervideo.model.Hipervideo;
	import br.com.caelum.hipervideo.reader.XMLReader;
		
	public class XMLReaderTest extends TestCase
	{
		private var xmlStr:String = ( <![CDATA[
			<hipervideo>
				<video file="support/bunny.flv"/>
				<next file="support/next.xml"/>
				
				<playlist current="2">
					<link>
						<tooltip>playlist 1</tooltip>
						<url>algum-video.flv</url>
						<thumbnail>thumb1.jpg</thumbnail>
					</link>	
					<link>
						<tooltip>playlist 2</tooltip>
						<url>algum-outro-video.flv</url>
						<thumbnail>thumb2.jpg</thumbnail>
					</link>
				</playlist>
				
				<actions>
					<pause at="00:00:17" />
					<pause at="00:00:21" />
				</actions>
								
				<elements>
					<element>
						<textContent>
							Conteúdo em texto
						</textContent>
						
						<link>
							<tooltip>Tooltip do link 1</tooltip>
							<url>http://algum-link.com</url>
							<thumbnail>Thumbnail do link 1</thumbnail>
						</link>
						
						<time start="00:00:10" duration="00:01:10"/>
						<geometry x="50" y="70" height="60" width="50"/>
					</element>
					
					<element>
						<textContent color="0xFF0000" backgroundColor="0x0000FF">
							Teste de cores
						</textContent>
						
						<link activity_id="act_id1" action="pause">
							<tooltip></tooltip>
							<url target="_blank">http://link-qualquer.com</url>
							<thumbnail>imagem_das_cores.jpg</thumbnail>
						</link>
						
						<time start="00:00:10" duration="00:01:10"/>
						<geometry x="50" y="70" height="60" width="50"/>
					</element>
				
					<element>
						<imageContent>http://link-para-imagem.com</imageContent>
						
						<link activity_id="act_id2" action="play">
							<tooltip>Tooltip 3</tooltip>
							<time>00:02:15</time>
							<thumbnail></thumbnail>
						</link>
						
						<time start="01:00:01" duration="00:10:10.5"/>
						<geometry x="150" y="170" height="960" width="950"/>
					</element>
					
					<element>
						<underline color="0xF0F0F0"/>
						
						<link activity_id="#ActID#">
							<tooltip>Tooltip do underline.</tooltip>
							<video>outro.xml</video>
							<thumbnail>thumbs/video10.jpg</thumbnail>
						</link>
						
						<time start="00:00:01" duration="00:00:08"/>
						<geometry x="30" y="100" height="50" width="200"/>
					</element>
					
					<element>
						<frame color="0xFF0000" backgroundColor="corDeFundo">Conteudo</frame>
						
						<link activity_id="#ActID#">
							<tooltip>Tooltip do underline.</tooltip>
							<video>outro.xml</video>
							<thumbnail>thumbs/video10.jpg</thumbnail>
						</link>
						
						<time start="00:00:01" duration="00:00:08"/>
						<geometry x="30" y="100" height="50" width="200"/>
					</element>
					
				</elements>
			</hipervideo>
		]]> ).toString();

		private var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
		private var hipervideo:Hipervideo = xmlReader.extract()
		private var elementArray:Array = hipervideo.elements;
		private var playlistArray:Array = hipervideo.playlist;
		private var actionArray:Array = hipervideo.actions;
		
		public function testReadNextXmlFile():void {
			assertEquals("support/next.xml", hipervideo.next);
		}
		
		public function testReadVideoFileName():void {
			assertEquals("support/bunny.flv", hipervideo.video);
		}
		
		public function testReadCorrectNumberOfActions():void {
			assertEquals(2, actionArray.length);
		}
		
		public function testReadPauses():void {
			assertEquals(ActionType.PAUSE, actionArray[0].type);
			assertEquals(17, actionArray[0].time);
			assertEquals(ActionType.PAUSE, actionArray[1].type);
			assertEquals(21, actionArray[1].time);
		}

		public function testReadCorrectNumberOfPlaylistItens():void {
			assertEquals(2, playlistArray.length);
		}
		
		public function testReadPlaylistItemTooltip():void {
			assertEquals("playlist 1", playlistArray[0].tooltip);
			assertEquals("playlist 2", playlistArray[1].tooltip);
		}
		
		public function testReadPlaylistItemThumbnail():void {
			assertEquals("thumb1.jpg", playlistArray[0].thumbnail);
			assertEquals("thumb2.jpg", playlistArray[1].thumbnail);
		}
		
		public function testReadPlaylistItemUrl():void {
			assertEquals("algum-video.flv", playlistArray[0].url);
			assertEquals("algum-outro-video.flv", playlistArray[1].url);
		}
					
		public function testReadCorrectNumberOfLinksFromXML():void {
			assertEquals(5, elementArray.length);
		}
		
		public function testReadLinkContents():void {
			assertEquals("Conteúdo em texto", elementArray[0].content);
			assertEquals("Teste de cores", elementArray[1].content);
			assertEquals("http://link-para-imagem.com", elementArray[2].content);
		}
		
		public function testReadLinkTime():void {
			assertEquals(10, elementArray[0].start);
			assertEquals(70, elementArray[0].duration);
			assertEquals(3601, elementArray[2].start);
			assertEquals(610.5, elementArray[2].duration);			
		}
		
		public function testReadLinkGeometry():void {
			assertEquals(50, elementArray[0].x);
			assertEquals(70, elementArray[0].y);
			assertEquals(50, elementArray[0].width);
			assertEquals(60, elementArray[0].height);
			assertEquals(150, elementArray[2].x);
			assertEquals(170, elementArray[2].y);
			assertEquals(950, elementArray[2].width);
			assertEquals(960, elementArray[2].height);
		}
		
		public function testReadTextColor():void {
			assertEquals(0xFFFFFF, elementArray[0].color);
			assertEquals(0, elementArray[0].backgroundColor);
			assertEquals(false, elementArray[0].hasBackgroundColor);
			
			assertEquals(0xFF0000, elementArray[1].color);
			assertEquals(0x0000FF, elementArray[1].backgroundColor);
			assertEquals(true, elementArray[1].hasBackgroundColor);
		}
		
		public function testReadTooltip():void {
			assertEquals("Tooltip do link 1", elementArray[0].link.tooltip);
		}
		
		public function testTooltipIsUrlIfNoTooltipSpecified():void {
			assertEquals("http://link-qualquer.com", elementArray[1].link.tooltip);
		}
		
		public function testReadLinkURL():void {
			assertEquals("http://algum-link.com", elementArray[0].link.url);
			assertEquals("http://link-qualquer.com", elementArray[1].link.url);
			assertEquals("", elementArray[2].link.url);
		}
		
		public function testReadLinkSeekPosition():void {
			assertEquals(0, elementArray[0].link.time);
			assertEquals(0, elementArray[1].link.time);
			assertEquals(135, elementArray[2].link.time);
		}
		
		public function testReadThumbnail():void {
			assertEquals("Thumbnail do link 1", elementArray[0].link.thumbnail);
			assertEquals("imagem_das_cores.jpg", elementArray[1].link.thumbnail);
		}
		
		public function testReadThumbnailDefaultWhenItIsNotInformed():void {
			assertEquals("thumbs/defaultThumb.jpg", elementArray[2].link.thumbnail);
		}
		
		public function testReadLinkActivityId():void {
			assertEquals("", elementArray[0].link.activityId);
			assertEquals("act_id1", elementArray[1].link.activityId);
			assertEquals("act_id2", elementArray[2].link.activityId);
		}
		
		public function testReadLinkAction():void {
			assertEquals(ActionType.NOTHING, elementArray[0].link.action);
			assertEquals(ActionType.PAUSE, elementArray[1].link.action);
			assertEquals(ActionType.PLAY, elementArray[2].link.action);
		}
		
		public function testReadElementType():void {
			assertEquals(ElementType.TEXT, elementArray[0].type);
			assertEquals(ElementType.TEXT, elementArray[1].type);
			assertEquals(ElementType.IMAGE, elementArray[2].type);
			assertEquals(ElementType.UNDERLINE, elementArray[3].type);
			assertEquals(ElementType.FRAME, elementArray[4].type);
		}
		
		public function testReadUnderlineColor():void {
			assertEquals("0xF0F0F0", elementArray[3].color);		
		}
		
		public function testReadVideoLink():void {
			assertEquals("", elementArray[2].link.video);
			assertEquals("outro.xml", elementArray[3].link.video);
		}
		
		public function testReadTargetLink():void {
			assertEquals("_self", elementArray[0].link.target);
			assertEquals("_blank", elementArray[1].link.target);
		}
		
		public function testReadBorderColor():void {
			assertEquals("0xFF0000", elementArray[4].color);
		}

		public function testReadXMLWithNoElements():void {
			var xmlStr:String = ( <![CDATA[
				<video>
					<playlist>
					</playlist>
					<elements>
					</elements>
				</video>
			]]> ).toString();
				
			var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
			var video:Hipervideo = xmlReader.extract();
			var elementArray:Array = video.elements;
			var playlistArray:Array = video.playlist;
			
			assertEquals(0, elementArray.length);
			assertEquals(0, playlistArray.length);
		}
		
		public function testReadEmptyXML():void {
			var xmlStr:String = ( <![CDATA[
			]]> ).toString();
				
			var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
			var video:Hipervideo = xmlReader.extract();
			var elementArray:Array = video.elements;
			var playlistArray:Array = video.playlist;
			
			assertEquals(0, elementArray.length);
			assertEquals(0, playlistArray.length);
		}
		
	}
}