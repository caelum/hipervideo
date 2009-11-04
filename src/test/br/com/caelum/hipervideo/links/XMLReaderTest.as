package test.br.com.caelum.hipervideo.links
{
	import asunit.framework.TestCase;
	
	import br.com.caelum.hipervideo.links.XMLReader;
	
	public class XMLReaderTest extends TestCase
	{
		
		private var xmlStr:String = ( <![CDATA[
			<links>
				<link>
					<content type="text">Site da caelum</content>
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
					<content>Informacoes Gerais em um combo</content>
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
			assertEquals(2, linkArray.length);
		}
		
		public function testReadLinkContents():void {
			assertEquals("Site da caelum", linkArray[0].content);
			assertEquals("Informacoes Gerais em um combo", linkArray[1].content);
		}
		
		public function testReadLinkTime():void {
			assertEquals(10, linkArray[0].startTime);
			assertEquals(80, linkArray[0].endTime);
			assertEquals(3601, linkArray[1].startTime);
			assertEquals(4210.5, linkArray[1].endTime);			
		}
		
		public function testReadLinkPosition():void {
			assertEquals(50, linkArray[0].topLeft_x);
			assertEquals(70, linkArray[0].topLeft_y);
			assertEquals(100, linkArray[0].bottomRight_x);
			assertEquals(130, linkArray[0].bottomRight_y);
			assertEquals(150, linkArray[1].topLeft_x);
			assertEquals(170, linkArray[1].topLeft_y);
			assertEquals(1100, linkArray[1].bottomRight_x);
			assertEquals(1130, linkArray[1].bottomRight_y);
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