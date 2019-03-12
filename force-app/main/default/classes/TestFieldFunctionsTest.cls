/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-07
 */

@IsTest
private class TestFieldFunctionsTest {

    private static TestRecordSource testRecordSource = new TestRecordSource();
    private static String accountName = 'Test Account';

    @IsTest
    static void appendRandomNumber() {
        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName(),
                        Value__c = accountName
                )
        });

        Account result = (Account)testRecordSource.getObject(Account.SObjectType).withoutInsert();

        System.assert(result.Name.contains(accountName));
        System.assert(result.Name.length() > accountName.length());
    }

    @IsTest
    static void createRecord() {
        // Create a standard variant of Account
        appendRandomNumber();

        Test_Record_Generator__mdt metadata = testRecordSource.addTemporaryMetadata(
                new Test_Record_Generator__mdt(
                        Apex_Class__c = TestMetadataRecordGenerator.class.getName(),
                        SObject__c = 'Account',
                        Variant__c = 'With Parent'
                ));
        testRecordSource.addTemporaryMetadataFields(new List<Test_Record_Generator_Field__mdt>{
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'Name',
                        Apex_Class__c = TestFieldFunctions.AppendRandomNumber.class.getName(),
                        Value__c = accountName
                ),
                new Test_Record_Generator_Field__mdt(
                        Test_Record_Generator__c = metadata.Id,
                        Field__c = 'ParentId',
                        Apex_Class__c = TestFieldFunctions.CreateRecord.class.getName(),
                        Apex_Class_Parameters__c = '{"sObjectType": "Account"}'
                )
        });

        Account testAccount = (Account)testRecordSource
                .getObject(Account.SObjectType)
                .asVariant('With Parent')
                .withInsert();

        Account parent = [SELECT Id FROM Account WHERE Id != :testAccount.Id];

        System.assertEquals(parent.Id, testAccount.ParentId);
    }
}