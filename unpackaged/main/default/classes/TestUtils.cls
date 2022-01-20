/**
 * From KG with love
 * 
 * 
 * 
 */ 
@isTest
public class TestUtils  {
    
    static final String PROD_ENVIRONMENT = 'Production';
    static final String SANDBOX_NAME_PREFIX = '--';
    static final String SANDBOX_NAME_END = '.';
    static final String TEST_USERNAME = 'f.lname@testuser.com';
    
    /**
    * @return The sandbox prefix when available
    */
    static String sandboxName {
        get {
            if(sandboxName == null) {
                String hostName = System.Url.getSalesforceBaseUrl().getHost();
                sandboxName = PROD_ENVIRONMENT; 
                
                if(isSandbox(hostName)){
                    Integer startIndex = hostName.indexOf(SANDBOX_NAME_PREFIX) + SANDBOX_NAME_PREFIX.length();
                    Integer endIndex = hostName.indexOf('.');
                    sandboxName = hostName.mid(startIndex, endIndex-startIndex);
                }
            }
            return sandboxName;
        }
        private set;
    }
    
    /**
    * @return true if the hostname contains the SANDBOX_NAME_PREFIX i.e. '--'
    */
    static Boolean isSandbox(String hostName){
        return hostName.indexOf(SANDBOX_NAME_PREFIX) != -1;
    }
    
    
    /**
     * 
     * 
     */ 
    static Organization orgInstance {
        get {
            if(orgInstance == null) {
                orgInstance = [SELECT LanguageLocaleKey, TimeZoneSidKey, DefaultLocalesidkey 
                               FROM Organization 
                               LIMIT 1];
            }
            return orgInstance;
        }
        private set;
    }
    
    /**
     * 
     * 
     */ 
    static Id adminProfileId {
        get {
            if(adminProfileId == null) {
                List<Profile> pList = [SELECT Id, createddate 
                                       FROM Profile 
                                       WHERE Name LIKE '%admin%' 
                                       ORDER BY CreatedDate ASC 
                                       LIMIT 1];
                system.assert(!pList.isEmpty(), 'No admin profile found in the org');
                adminProfileId = pList[0].Id;
            }
            return adminProfileId;
        }
        private set;
    }
    
    static User createAdminUser() {
        return createTestUser(adminProfileId, TEST_USERNAME, sandboxName);
    }
    

    /**
     * 
     * 
     */ 
    static User getAdminUser() {
        User tmpUser = getTestUser(TEST_USERNAME);
        if(tmpUser == null) {
            tmpUser = createAdminUser();
        }
        return tmpUser;
    }
    
    /**
     * 
     * 
     */ 
    public static User getTestUser(String username) {
        List<User> uList = [SELECT Id, Name, Email, Username 
                            FROM User 
                            WHERE Username = :username 
                            LIMIT 1];
        User tmpUser = !uList.isEmpty() ? uList[0] : null;
        System.Debug('Found Test User: ' + tmpUser);
        return tmpUser;
    }
    
    /**
     * 
     * 
     */ 
    public static User adminUser {
        get {
            if(adminUser == null) {
                adminUser = getAdminUser();
            }
            return adminUser;
        }
       private set;
    }
    
    /**
     * 
     * 
     */ 
    public static User createTestUser(Id profileId, String userName, String sandboxName) {
        system.assert(userName.contains('@'), 'Username doesn\'t match the expected email pattern, define an \'@\' in it.');
        system.assert(username.substringBefore('@').contains('.'), 'Username doesn\'t match the expected pattern, define a \'firstname.lastname@email.com\' format');
        system.assert(username.substringBefore('@').length() <= 8, 'firstname.lastname combination shoudln\'t exceed 8 characters (used for alias field completion with max length matching 8 chars)');
        User tmpUser = new User();
        tmpUser.firstName = userName.substringBefore('.');
        tmpUser.lastName = userName.substringBetween('.','@');
        tmpUser.Alias = tmpUser.FirstName + '.' + tmpUser.LastName;
        tmpUser.email = userName;
        tmpUser.Username = userName + '.' + sandboxName;
        tmpUser.profileId = profileId;
        tmpUser.TimeZoneSidKey = orgInstance.TimeZoneSidKey;
        tmpUser.LocaleSidKey = orgInstance.DefaultLocalesidkey;
        tmpUser.EmailEncodingKey = 'UTF-8';
        tmpUser.LanguageLocaleKey = orgInstance.LanguageLocaleKey;
        System.Debug('Created Test User: ' + tmpUser);
        return tmpUser;
    }
}