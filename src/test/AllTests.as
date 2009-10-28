package test
{
	import asunit.framework.TestCase;
	
	public class AllTests extends TestCase
	{
		public function AllTests()
		{
			super();
		}
			
		public function testThatShouldPass():void {
			assertTrue(true);
			assertEquals(5, 5);
		}
		
		public function testThatShouldFail():void
		{
			assertEquals(5, 3);
		}

	}
}