package test.links
{
	import asunit.framework.TestCase;
	
	import links.XMLReader;
	
	public class XMLReaderTest extends TestCase
	{
			
		public function testReadListOfLinksFromXML():void {
			var xmlStr:String = ( <![CDATA[
				<links>
					<link>
						<startTime>100</startTime>
						<endTime>200</endTime>
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
						<startTime>1100</startTime>
						<endTime>1200</endTime>
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
				
			var xmlReader:XMLReader = new XMLReader(new XML(xmlStr));
			var linkArray:Array = xmlReader.extract();
			
			assertEquals(100, linkArray[0].startTime);
			assertEquals(200, linkArray[0].endTime);
			assertEquals(50, linkArray[0].topLeft_x);
			assertEquals(70, linkArray[0].topLeft_y);
			assertEquals(100, linkArray[0].bottomRight_x);
			assertEquals(130, linkArray[0].bottomRight_y);
			
			assertEquals(1100, linkArray[1].startTime);
			assertEquals(1200, linkArray[1].endTime);
			assertEquals(150, linkArray[1].topLeft_x);
			assertEquals(170, linkArray[1].topLeft_y);
			assertEquals(1100, linkArray[1].bottomRight_x);
			assertEquals(1130, linkArray[1].bottomRight_y);
			
			assertEquals(2, linkArray.length);
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