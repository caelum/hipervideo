package test
{
	import asunit.framework.TestSuite;
	
	import test.br.com.caelum.hipervideo.reader.XMLReaderTest;
	
	public class AllTests extends TestSuite
	{
		public function AllTests()
		{
			super();
			addTest(new XMLReaderTest());
		}

	}
}