package test
{
	import asunit.framework.TestSuite;
	
	import test.links.XMLReaderTest;
	
	public class AllTests extends TestSuite
	{
		public function AllTests()
		{
			super();
			addTest(new XMLReaderTest());
		}

	}
}