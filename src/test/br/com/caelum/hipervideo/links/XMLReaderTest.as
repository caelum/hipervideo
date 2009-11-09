package test.br.com.caelum.hipervideo.links
{
	import asunit.framework.TestCase;
	
	import br.com.caelum.hipervideo.links.XMLReader;
	
	public class XMLReaderTest extends TestCase
	{
		
		private var xmlStr:String = ( <![CDATA[
			<links>
				<link>
					<content type="text">Conteúdo em texto</content>
					<tooltip>Tooltip do link 1</tooltip>
					<url>http://algum-link.com</url>
					<thumbnail>Thumbnail do link 1</thumbnail>
					<startTime>00:00:10</startTime>
					<endTime>00:01:20</endTime>
					<topLeft>
						<x>50</x>
						<y>70</y>
					</topLeft>
					<bottomRight>
						<x>100</x>
						<y>130</y>
					</bottomRight>
				</link>
				<link>
					<content type="text" textColor="0xFF0000" backgroundColor="0xFFFFFF">Teste de cores</content>
					<url>http://link-qualquer.com</url>
					<thumbnail>imagem_das_cores.jpg</thumbnail>
					<startTime>00:00:10</startTime>
					<endTime>00:01:20</endTime>
					<topLeft>
						<x>50</x>
						<y>70</y>
					</topLeft>
					<bottomRight>
						<x>100</x>
						<y>130</y>
					</bottomRight>
				</link>
				<link>
					<content type="image">http://link-para-imagem.com</content>
					<startTime>01:00:01</startTime>
					<endTime>01:10:10.5</endTime>
					<topLeft>
						<x>150</x>
						<y>170</y>
					</topLeft>
					<bottomRight>
						<x>1100</x>
						<y>1130</y>
					</bottomRight>
				</link>
			</links>
		]]> ).toString();

		private var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
		private var linkArray:Array = xmlReader.extract();
					
		public function testReadCorrectNumberOfLinksFromXML():void {
			assertEquals(3, linkArray.length);
		}
		
		public function testReadLinkContents():void {
			assertEquals("Conteúdo em texto", linkArray[0].content);
			assertEquals("Teste de cores", linkArray[1].content);
			assertEquals("http://link-para-imagem.com", linkArray[2].content);
		}
		
		public function testReadLinkTime():void {
			assertEquals(10, linkArray[0].startTime);
			assertEquals(80, linkArray[0].endTime);
			assertEquals(3601, linkArray[2].startTime);
			assertEquals(4210.5, linkArray[2].endTime);			
		}
		
		public function testReadLinkPosition():void {
			assertEquals(50, linkArray[0].topLeft_x);
			assertEquals(70, linkArray[0].topLeft_y);
			assertEquals(100, linkArray[0].bottomRight_x);
			assertEquals(130, linkArray[0].bottomRight_y);
			assertEquals(150, linkArray[2].topLeft_x);
			assertEquals(170, linkArray[2].topLeft_y);
			assertEquals(1100, linkArray[2].bottomRight_x);
			assertEquals(1130, linkArray[2].bottomRight_y);
		}
		
		public function testVerifyContentType():void {
			assertEquals("text", linkArray[0].contentType);
			assertEquals("text", linkArray[1].contentType);
			assertEquals("image", linkArray[2].contentType);
		}
		
		public function testReadTextColor():void {
			assertEquals(0xFFFFFF, linkArray[0].textColor);
			assertEquals(0, linkArray[0].backgroundColor);
			assertEquals(false, linkArray[0].hasBackgroundColor);
			
			assertEquals(0xFF0000, linkArray[1].textColor);
			assertEquals(0xFFFFFF, linkArray[1].backgroundColor);
			assertEquals(true, linkArray[1].hasBackgroundColor);
		}
		
		public function testReadTooltip():void {
			assertEquals("Tooltip do link 1", linkArray[0].tooltip);
		}
		
		public function testTooltipIsUrlIfNoTooltipSpecified():void {
			assertEquals("http://link-qualquer.com", linkArray[1].tooltip);
		}
		
		public function testReadLinkURL():void {
			assertEquals("http://algum-link.com", linkArray[0].url);
			assertEquals("http://link-qualquer.com", linkArray[1].url);
		}
		
		public function testReadThumbnail():void {
			assertEquals("Thumbnail do link 1", linkArray[0].thumbnail);
			assertEquals("imagem_das_cores.jpg", linkArray[1].thumbnail);
		}
		
		public function testReadThumbnailDefaultWhenItIsNotInformed():void {
			assertEquals("thumbs/defaultThumb.jpg", linkArray[2].thumbnail);
		}

		public function testReadXMLWithNoLinks():void {
			var xmlStr:String = ( <![CDATA[
				<links>
				</links>
			]]> ).toString();
				
			var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
			var linkArray:Array = xmlReader.extract();
			
			assertEquals(0, linkArray.length);
		}
		
		public function testReadEmptyXML():void {
			var xmlStr:String = ( <![CDATA[
			]]> ).toString();
				
			var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
			var linkArray:Array = xmlReader.extract();
			
			assertEquals(0, linkArray.length);
		}
		
	}
}