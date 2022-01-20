@isTest
public class TestUtilsTest {
	
    @testSetup
    static void testSetup() {
        User testUser = TestUtils.adminUser;
        insert testUser;
    }
    
    static testMethod void testOne() {
        system.debug('Test One with runAs');
        system.runAs(TestUtils.adminUser) {
            
        }
    }
    
    static testMethod void testTwo() {
        system.debug('Test Two with runAs');
        system.runAs(TestUtils.adminUser) {
            
        }
    }
}