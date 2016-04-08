//
//  ViewController.m
//  SimpleTest
//
//  Created by Miguel Ángel Pérez Martínez on 1/19/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import "ViewController.h"
#import "MSGraphSDKNXOAuth2.h"
#import "MSGraphSDK.h"
@import UIKit;

volatile BOOL testIsDone = NO;

@interface ViewController () {
    MSGraphClient *graphClient;
}

@end

@implementation ViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableTests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell" forIndexPath:indexPath];
    NSString *sdkName= [self.availableTests objectAtIndex:indexPath.row];
    cell.textLabel.text = sdkName;
    
    return cell;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.availableTests = [[NSMutableArray alloc] init];
    
    //[self loadInitialData];

    // TODO: Determine what scopes are needed to get all the tests working. Some are not supported in AADV2 right now.
    [[NXOAuth2AuthenticationProvider sharedAuthProvider] setClientId:@"a48e2727-9cc2-449e-ba32-05ddebb0a16d"
                                                          scopes:@[@"openid",
                                                                   @"offline_access",
                                                                   @"email",
                                                                   @"profile",
                                                                   @"https://graph.microsoft.com/User.Read",
                                                                   @"https://graph.microsoft.com/Contacts.ReadWrite",
                                                                   @"https://graph.microsoft.com/Files.ReadWrite",
                                                                   @"https://graph.microsoft.com/Mail.ReadWrite",
                                                                   @"https://graph.microsoft.com/Mail.Send",
                                                                   @"https://graph.microsoft.com/Calendars.ReadWrite",
//                                                                   @"https://graph.microsoft.com/Directory.ReadWrite",
//                                                                   @"https://graph.microsoft.com/Group.Read",
         ]];
    
    [[NXOAuth2AuthenticationProvider sharedAuthProvider] loginWithViewController:nil completion:^(NSError *error) {
        if (!error) {
            [MSGraphClient setAuthenticationProvider:[NXOAuth2AuthenticationProvider sharedAuthProvider]];
            graphClient = [MSGraphClient client];
            
            [self runTest:@selector(getMe)];
            
            [self runTest:@selector(getMeContacts)];
            [self runTest:@selector(getMeContactFolders)];
            [self runTest:@selector(addMeContactFolders)];
            [self runTest:@selector(getMessages)];
            [self runTest:@selector(getMessagesNextPage)];
            [self runTest:@selector(getInbox)];  // Known folders extension method
            [self runTest:@selector(addMessage)];
            [self runTest:@selector(sendMessage)];//action
            [self runTest:@selector(uploadAttachment)];
            [self runTest:@selector(getMeContactFoldersWithTop)];
            [self runTest:@selector(getMeContactFoldersById)];
            [self runTest:@selector(getMessagesSelect)];
            [self runTest:@selector(updateMessage)];
            [self runTest:@selector(addContact)];
            [self runTest:@selector(createEvent)];  // enums
            [self runTest:@selector(reminderView)];//functions
            [self runTest:@selector(getCalendarView)]; //test parameters
            [self runTest:@selector(getMessagesNextPage)];
            [self runTest:@selector(getDriveApproot)];
            [self runTest:@selector(createAndGetFileWithStream)];
            [self runTest:@selector(downloadUserPhoto)];
            
//            [self runTest:@selector(getMemberGroups)];
//            [self runTest:@selector(testGroupRef)];
        }
    }];
}

- (void)runTest:(SEL)test {
    testIsDone = NO;
    ((void (*)(id, SEL))[self methodForSelector:test])(self, test);
    while (!testIsDone) {
        sleep(1);
    }
}

- (void) logAndUpdate: (NSString *) message{
    NSLog(@"%@",message);
    [self.availableTests addObject:message];
    [self.tableView reloadData];
    testIsDone = YES;
}

- (void) getMe{
    [[[graphClient me] request] getWithCompletion:^(MSGraphUser *response, NSError *error){
        NSString * status;
        status = @"Failed";
        
        NSString *logMessage = @"Error - Unexpected";
        if (error == nil){
            MSGraphUser *myUser = response;
            if(myUser != nil && [myUser displayName] != nil){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMe", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMe", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }] ;
}

- (void) getMeContacts{
    [[[[graphClient me] contacts] request] getWithCompletion:^(MSCollection *contacts, MSGraphUserContactsCollectionRequest *nextRequest, NSError *error)
    {
        NSString * status;
        status = @"Failed";
        
        NSString *logMessage = @"Error - Unexpected";
        if (error == nil){
            if(contacts != nil && contacts.value.count > 0 && contacts.value[0] != nil){
                MSGraphContact *contact = contacts.value[0];
                NSString *name = [contact displayName];
                if(name != nil){
                    status = @"Passed";
                }
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMeContacts", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMeContacts", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}

- (void) getMeContactFolders{
    [[[[graphClient me] contactFolders] request] getWithCompletion:^(MSCollection *folders, MSGraphUserContactFoldersCollectionRequest *nextRequest, NSError *error) {
        NSString * status;
        status = @"Failed";
        
        NSString *logMessage = @"Error - Unexpected";
        if (error == nil){
            if(folders != nil && folders.value.count > 0 && folders.value[0] != nil){
                MSGraphContactFolder *contactFolder = folders.value[0];
                NSString *name = [contactFolder displayName];
                if(name != nil){
                    status = @"Passed";
                }
                
                logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMeContactFolders", status ];
            }else{
                logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: Unexpected result",@"getMeContactFolders", status];
            }
            
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMeContactFolders", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }] ;
}

- (void) getMeContactFoldersWithTop{
    [[[[[graphClient me] contactFolders] request] top:1] getWithCompletion:^(MSCollection *folders, MSGraphUserContactFoldersCollectionRequest *nextRequest, NSError *error) {
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(folders != nil && folders.value.count == 1 && folders.value[0] != nil){
                MSGraphContactFolder *contactFolder = folders.value[0];
                NSString *name = [contactFolder displayName];
                if(name != nil){
                    status = @"Passed";
                }
                
                logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMeContactFoldersWithTop", status ];
            }else{
                logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: Unexpected result",@"getMeContactFoldersWithTop", status];
            }
            
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMeContactFoldersWithTop", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
        
    }];
}

- (void) getMeContactFoldersById{
    
    [[[[[graphClient me] contactFolders] request] top:1] getWithCompletion:^(MSCollection *folders, MSGraphUserContactFoldersCollectionRequest *nextRequest, NSError *error) {
        
        if(folders != nil && folders.value.count > 0 && folders.value[0] != nil){
            MSGraphContactFolder *contactFolder = folders.value[0];
            
            NSString *contactFolderId = [contactFolder entityId];
            
            [[[[[graphClient me] contactFolders] contactFolder:contactFolderId ] request] getWithCompletion:^(MSGraphContactFolder *contactFolder, NSError *error) {
                NSString * status;
                status = @"Failed";
                
                NSString *logMessage = @"Error - Unexpected";
                
                if (error == nil){
                    if(contactFolder != nil){
                        NSString *name = [contactFolder displayName];
                        if(name != nil){
                            status = @"Passed";
                        }
                        
                        logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMeContactFoldersById", status ];
                    }else{
                        logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMeContactFoldersById", status, [error localizedDescription]];
                    }
                    
                    [self logAndUpdate:logMessage];
                }
            }];
            
        }
        
    }];
    
}

- (void) addMeContactFolders{
    MSGraphContactFolder *newContactFolder = [[MSGraphContactFolder alloc] init];
    newContactFolder.displayName = [@"Test" stringByAppendingString:[[NSUUID UUID] UUIDString]];
    [[[[graphClient me] contactFolders] request] addContactFolder:newContactFolder withCompletion:^(MSGraphContactFolder *folder, NSError *error) {
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(folder != nil && [folder displayName] != nil){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"addMeContactFolders", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"addMeContactFolders", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
        
    }];
}

- (void) addContact{
    MSGraphContact *newContact = [self getSampleContact];
    
    [[[[graphClient me] contacts] request] addContact:newContact withCompletion:^(MSGraphContact *contact, NSError *error) {
        
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(contact != nil &&
               [contact.displayName isEqualToString:newContact.displayName] &&
               ((NSUInteger)[contact.birthday timeIntervalSince1970] == (NSUInteger)[newContact.birthday timeIntervalSince1970]) &&
               contact.emailAddresses.count == newContact.emailAddresses.count)
            {
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"addContact", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"addContact", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
        
    }];
}

- (void) getMessages{
    [[[[graphClient me] messages] request] getWithCompletion:^(MSCollection *messages, MSGraphUserMessagesCollectionRequest *nextRequest, NSError *error) {
        
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(messages != nil && messages.value.count > 0 && messages.value[0] != nil){
                MSGraphMessage *message = messages.value[0];
                NSString *subject = [message subject];
                if(subject != nil){
                    status = @"Passed";
                }
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMessages", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMessages", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}

- (void) getMessagesNextPage{
    [[[[graphClient me] messages]  request] getWithCompletion:^(MSCollection *messages, MSGraphUserMessagesCollectionRequest *nextRequest, NSError *error) {
        
        __block NSString *logMessage = @"Error - Unexpected";
        
        if(error == nil){
            [nextRequest getWithCompletion:^(MSCollection *secondPage, MSGraphUserMessagesCollectionRequest *nextRequest, NSError *error) {
                
                NSString * status;
                status = @"Failed";
                
                if (error == nil){
                    if( ![[messages nextLink].query isEqualToString:[secondPage nextLink].query] ){
                        MSGraphMessage *message = messages.value[0];
                        NSString *subject = [message subject];
                        if(subject != nil){
                            status = @"Passed";
                        }
                    }
                    
                    logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMessagesNextPage", status ];
                }else{
                    logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMessagesNextPage", status, [error localizedDescription]];
                }
                
                [self logAndUpdate:logMessage];
                
            }];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMessagesNextPage", @"Failed", [error localizedDescription]];
            [self logAndUpdate:logMessage];
        }
        
    }];
}


- (void) getMessagesSelect{
    [[[[[graphClient me] messages] request] select:@"Subject"] getWithCompletion:^(MSCollection *messages, MSGraphUserMessagesCollectionRequest *nextRequest, NSError *error) {
        
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(messages != nil && messages.value.count > 0 && messages.value[0] != nil){
                MSGraphMessage *message = messages.value[0];
                NSString *subject = [message subject];
                NSDate *date = [message receivedDateTime];
                if(subject != nil && date == nil){
                    status = @"Passed";
                }
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMessagesSelect", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMessagesSelect", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}
- (void)getInbox {
    [[[[[graphClient me] mailFolders] inbox] request] getWithCompletion:^(MSGraphMailFolder *response, NSError *error) {
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(response != nil && response.displayName && response.displayName.length > 0) {
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getInbox", status ];
        } else {
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getInbox", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}

- (void) addMessage{
    
    MSGraphMessage *newMessage = [self getSampleMessage];
    
    [[[[graphClient me] messages] request] addMessage:newMessage withCompletion:^(MSGraphMessage *addedMessage, NSError *error) {
        
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(addedMessage != nil && ![addedMessage.subject isEqualToString:@""]){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"addMessage", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"addMessage", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}

- (void) sendMessage{
    
    MSGraphMessage *newMessage = [self getSampleMessage];
    
    [[[[graphClient me] sendMailWithMessage:newMessage saveToSentItems:TRUE] request] executeWithCompletion:^(NSDictionary *response, NSError *error) {
        
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(response != nil){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"sendMessage", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"sendMessage", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}

- (void) createEvent {
    MSGraphEvent *myEvent = [self getSampleEvent];
    [[[[[graphClient me] calendar] events] request] addEvent:myEvent withCompletion:^(MSGraphEvent *response, NSError *error) {
        if (!error) {
            if ([self eventMatches:myEvent otherEvent:response]) {
                [self logAndUpdate:[NSString stringWithFormat: @"Test: %@ - %@",@"createEvent", @"Passed"]];
            }
            else {
                [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"createEvent", @"Failed", @"Returned event does not match"]];
            }
        }
        else {
            [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"createEvent", @"Failed", [error localizedDescription]]];
        }
    }];
}

- (void) reminderView{
    NSString *start = @"2016-01-20T09:00:00Z";
    NSString *end = @"2016-01-31T09:00:00Z";
    
    [[[[graphClient me] reminderViewWithStartDateTime:start endDateTime:end] request] executeWithCompletion:^(MSCollection *reminders, MSGraphUserReminderViewRequest *nextRequest, NSError *error) {
        
        
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(reminders != nil){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"reminderView", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"reminderView", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
    }];
}

- (void) updateMessage{
    [[[[graphClient me] messages] request] getWithCompletion:^(MSCollection *messages, MSGraphUserMessagesCollectionRequest *nextRequest, NSError *error) {
        
        __block NSString * status = [[NSString alloc] init];
        status = @"Failed";
        
        __block NSString *logMessage = @"Error - Unexpected";
        if (error == nil){
            if(messages != nil && messages.value.count > 0 && messages.value[0] != nil){
                MSGraphMessage *message = messages.value[0];
                
                MSGraphMessage *messageToUpdate = [[MSGraphMessage alloc] init];
                [messageToUpdate setIsRead:true];
                [messageToUpdate setEntityId:[message entityId]];
                
                [[[[[graphClient me] messages] message:[message entityId]] request] update:messageToUpdate withCompletion:^(MSGraphMessage *updated, NSError *error) {
                    
                    if (error == nil){
                        NSString *subject = [updated subject];
                        if(subject != nil && [updated isRead]){
                            status = @"Passed";
                            logMessage = [NSString stringWithFormat: @"Test: %@ - %@",@"updateMessage", status];
                        }
                    }else{
                        logMessage = [NSString stringWithFormat: @"Test: %@ - %@ - Error: %@",@"updateMessage", status, [error localizedDescription] ];
                    }
                    [self logAndUpdate:logMessage];
                }];
            }
            
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"updateMessage", status, [error localizedDescription]];
            [self logAndUpdate:logMessage];
        }
        
        
    }];
}

- (void) getCalendarView{
    NSString *start = @"2016-01-20T09:00:00";
    NSString *end = @"2016-01-31T09:00:00";
    
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    MSQueryParameters *startParameter = [[MSQueryParameters alloc] initWithKey:@"StartDateTime" value:start];
    MSQueryParameters *endParameter = [[MSQueryParameters alloc] initWithKey:@"EndDateTime" value:end];
    
    [options addObject:startParameter];
    [options addObject:endParameter];
    
    [[[[graphClient me] calendarView] requestWithOptions:options] getWithCompletion:^(MSCollection *response, MSGraphUserCalendarViewCollectionRequest *nextRequest, NSError *error) {
        NSString * status;
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        
        if (error == nil){
            if(response != nil){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getCalendarView", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getCalendarView", status, [error localizedDescription]];
        }
        
        [self logAndUpdate:logMessage];
        
    }];
}

- (void) getMemberGroups{
    [[[graphClient me] request] getWithCompletion:^(MSGraphUser *response, NSError *error) {
        
        __block NSString * status;
        status = @"Failed";
        __block NSString *logMessage = @"Test: getMemberGroups Error - Unexpected";
        
        if (error == nil){
            if(response != nil){
                NSString *directoryObjectId= [response entityId];
                [[[[graphClient directoryObjects:directoryObjectId] getMemberGroupsWithSecurityEnabledOnly:false] request] executeWithCompletion:^(MSCollection *response, MSGraphDirectoryObjectGetMemberGroupsRequest *nextRequest, NSError *error) {
                    
                    if(error == nil && response != nil){
                        status = @"Passed";
                        logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"getMemberGroups", status ];
                    }else{
                        if(error != nil){
                            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMemberGroups", status, [error localizedDescription]];
                        }else{
                            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"getMemberGroups", status, @"Membergroups is nil"];
                        }
                        
                    }
                    
                    [self logAndUpdate:logMessage];
                }];
            }else{
                
                [self logAndUpdate:logMessage];
            }
        }else{
            
            [self logAndUpdate:logMessage];
        }
    }];
}

- (void)getDriveApproot {
    [[[[[[graphClient me] drive] special] approot] request] getWithCompletion:^(MSGraphDriveItem *response, NSError *error) {
        if (error != nil) {
            [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@", @"getDriveApproot", @"Failed", [error localizedDescription]]];
        }
        else {
            [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@",@"getDriveApproot", @"Passed" ]];
        }
    }];
}

- (void) createAndGetFileWithStream {
    MSGraphDriveItem *myItem = [self getFileItem];
    NSData *content =[@"Test Message content" dataUsingEncoding: NSUTF8StringEncoding];
    __block NSString * status = [[NSString alloc] init];
    status = @"Failed";
    
    
    [[[[[graphClient me] drive] items] request] addDriveItem:myItem withCompletion:^(MSGraphDriveItem *response, NSError *error) {
        
        if (error != nil) {
            [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@", @"createAndGetFileWithStream", status, [error localizedDescription]]];
        }
        else {
            [[[[[[graphClient me] drive] items] driveItem:response.entityId] contentRequest] uploadFromData: content completion: ^(MSGraphDriveItem *response, NSError *error) {
                
                if (error != nil) {
                    [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"createAndGetFileWithStream", status, [error localizedDescription]]];
                }
                else
                {
                    [[[[[[graphClient me] drive] items] driveItem:response.entityId] contentRequest] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
                        NSString *logMessage = @"Error - Unexpected";
                        if (error == nil){
                            if(response != nil){
                                status = @"Passed";
                            }
                            
                            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"createAndGetFileWithStream", status ];
                        }else{
                            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"createAndGetFileWithStream", status, [error localizedDescription]];
                        }
                        [self logAndUpdate:logMessage];
                    }];
                    
                }
            }];
        }
    }];
    
}

- (void) testGroupRef {
    
    __block NSString * status = [[NSString alloc] init];
    status = @"Failed";
    
    [[[graphClient me] request] getWithCompletion:^(MSGraphUser *me, NSError *error) {
        if(error==nil) {
            [[[graphClient groups] request] getWithCompletion:^(MSCollection *response, MSGraphGroupsCollectionRequest *nextRequest, NSError *error) {
            
                if(error==nil) {
                    
                    MSGraphGroup *firstGroup = response.value[0];
            
                    [[[[[graphClient groups:firstGroup.entityId] members] references] request] addDirectoryObject:me withCompletion:^(MSGraphDirectoryObject *response, NSError *error) {
                        
                        if(error==nil)
                        {
                            status = @"Passed";
                            [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"testGroupRef", status, [error localizedDescription]]];
                        }
                        else [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"testGroupRef", status, [error localizedDescription]]];
                        
                    }];
                
                }
                else [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"testGroupRef", status, [error localizedDescription]]];
            
            }];
        }
        else [self logAndUpdate:[NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"testGroupRef", status, [error localizedDescription]]];
    }];
}

- (void) downloadUserPhoto {
    
    [[[graphClient me] photoValue] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSString * status = [[NSString alloc] init];
        status = @"Failed";
        NSString *logMessage = @"Error - Unexpected";
        if (error == nil){
            if(response != nil){
                status = @"Passed";
            }
            
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"downloadUserPhoto", status ];
        }else{
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"downloadUserPhoto", status, [error localizedDescription]];
        }
        [self logAndUpdate:logMessage];
    }];
    
}

- (void)uploadAttachment {
    __block NSString * status;
    status = @"Failed";
    __block NSString *logMessage = @"Error - Unexpected";
    
    MSGraphMessage *newMessage = [self getSampleMessage];
    
    [[[[graphClient me] messages] request] addMessage:newMessage withCompletion:^(MSGraphMessage *addedMessage, NSError *error) {
        if (error){
            logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"uploadAttachment", status, [error localizedDescription]];
            [self logAndUpdate:logMessage];
        }else{
            MSGraphAttachment *newAttachment = [self getSampleAttachment];
            [[[[[graphClient me] messages:addedMessage.entityId] attachments] request] addAttachment:newAttachment withCompletion:^(MSGraphAttachment *response, NSError *error) {
                if (error) {
                    logMessage = [NSString stringWithFormat:@"Test: %@ - %@ - Error: %@",@"uploadAttachment", status, [error localizedDescription]];
                    [self logAndUpdate:logMessage];
                }
                else {
                    status = @"Passed";
                    logMessage = [NSString stringWithFormat:@"Test: %@ - %@",@"uploadAttachment", status];
                    [self logAndUpdate:logMessage];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MSGraphMessage *) getSampleMessage{

    MSGraphRecipient *recipient = [[MSGraphRecipient alloc] init];
    recipient.emailAddress = [[MSGraphEmailAddress alloc] init];
    recipient.emailAddress.name = @"MSGraph Test Account";
    recipient.emailAddress.address = @"msgraphiostest@gmail.com";
    
    MSGraphMessage *newMessage = [[MSGraphMessage alloc] init];
    newMessage.subject = [NSString stringWithFormat:@"My test mail %u", arc4random()];
    newMessage.toRecipients = @[recipient];
    
    MSGraphItemBody *itemBody = [[MSGraphItemBody alloc] init];
    [itemBody setContent:@"This is the mail content"];
    [itemBody setContentType:MSGraphBodyTypeText];
    newMessage.body = itemBody;
    
    return newMessage;
}

- (MSGraphAttachment*)getSampleAttachment {
    MSGraphFileAttachment *attachment = [[MSGraphFileAttachment alloc] init];
    attachment.name = @"TestAttachment.txt";
    attachment.contentType = @"application/octet-stream";
    attachment.size = (int)@"Hi this is a sample attachment!".length;
    attachment.isInline = NO;
    attachment.contentBytes = @"SGkgdGhpcyBpcyBhIHNhbXBsZSBhdHRhY2htZW50IQ==";  // "Hi this is a sample attachment!"
    
    return attachment;
}

- (MSGraphContact *) getSampleContact{
    MSGraphContact *newContact = [[MSGraphContact alloc] init];
    [newContact setBirthday: [NSDate date]];
    [newContact setDisplayName:@"MyFriend"];
    [newContact setGivenName:@"GivenName"];
    
    MSGraphEmailAddress *contactAddress = [[MSGraphEmailAddress alloc] init];
    contactAddress.address = @"msgraphiostest@gmail.com";
    
    newContact.emailAddresses = @[contactAddress];
    
    return newContact;
}

- (MSGraphDriveItem *)getFileItem {
    
    NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".txt"];
    
    MSGraphFile *file = [[MSGraphFile alloc]init];
    
    MSGraphDriveItem *item = [[MSGraphDriveItem alloc] init];
    [item setFile:file];
    [item setName:fileName];
    
    return item;
}

- (MSGraphEvent *)getSampleEvent {
    MSGraphEvent *event = [[MSGraphEvent alloc] init];
    event.subject = @"Event Subject";
    event.body = [[MSGraphItemBody alloc] init];
    event.body.contentType = [MSGraphBodyType text];
    event.body.content = @"Event Body";
    event.importance = [MSGraphImportance normal];
    event.type = [MSGraphEventType seriesMaster];
    event.start = [[MSGraphDateTimeTimeZone alloc] init];
    event.start.dateTime = @"2016-04-04T19:46:48.142000-0700";
    event.start.timeZone = @"America/New_York";
    event.end = [[MSGraphDateTimeTimeZone alloc] init];
    event.end.dateTime = @"2016-04-04T20:46:48.142000-0700";
    event.end.timeZone = @"America/New_York";
    event.recurrence = [[MSGraphPatternedRecurrence alloc] init];
    event.recurrence.pattern = [[MSGraphRecurrencePattern alloc] init];
    event.recurrence.pattern.interval = 1;
    event.recurrence.pattern.type = [MSGraphRecurrencePatternType weekly];
    event.recurrence.pattern.daysOfWeek = @[[MSGraphDayOfWeek monday], [MSGraphDayOfWeek thursday]];
    event.recurrence.range = [[MSGraphRecurrenceRange alloc] init];
    event.recurrence.range.type = [MSGraphRecurrenceRangeType noEnd];
    event.recurrence.range.startDate = [MSDate date];
    
    return event;
}

- (BOOL) eventMatches:(MSGraphEvent*)left otherEvent:(MSGraphEvent*)right {
    if (![left.subject isEqualToString:right.subject]
        || left.body.contentType != right.body.contentType
        || left.body.contentType.enumValue != right.body.contentType.enumValue
        || ![left.body.content isEqualToString:right.body.content]
        || left.importance != right.importance
        || left.type != right.type
        || left.recurrence.pattern.interval != right.recurrence.pattern.interval
        || left.recurrence.pattern.type != right.recurrence.pattern.type
        || left.recurrence.pattern.daysOfWeek.count != right.recurrence.pattern.daysOfWeek.count
        || left.recurrence.range.type != right.recurrence.range.type)
    {
        return NO;
    }
    
    for (MSGraphDayOfWeek *dayLeft in left.recurrence.pattern.daysOfWeek) {
        BOOL found = NO;
        for (MSGraphDayOfWeek *dayRight in right.recurrence.pattern.daysOfWeek) {
            if (dayLeft == dayRight) {
                found = YES;
                break;
            }
        }
        if (!found) {
            return NO;
        }
    }
    return YES;
}

@end
