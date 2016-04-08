//  Copyright 2015 Microsoft Corporation
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "ODXActionController.h"
#import "ODXTextViewController.h"
#import "MSGraphSDK.h"

@implementation ODXActionController

+ (void)shareItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
   viewController:(UIViewController *)viewController
       completion:(shareCompletionHandler)completion
{
   UIAlertController *shareViewController = [ODXActionController shareControllerWithViewCompletion:^(UIAlertAction *action){
       [[[[[[client me] drive] items:item.entityId] createLinkWithType:@"view" scope:nil] request] executeWithCompletion:completion];
                                                         }
                                                                                    editCompletion:^(UIAlertAction *action){
                                                                                        [[[[[[client me] drive] items:item.entityId] createLinkWithType:@"edit" scope:nil] request] executeWithCompletion:completion];
                                                         }];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [viewController presentViewController:shareViewController animated:YES completion:nil];
    });
}

+ (UIAlertController *)shareControllerWithViewCompletion:(void (^)(UIAlertAction *action))viewCompletion
                                          editCompletion:(void (^)(UIAlertAction *))editCompletion
{
    UIAlertController *shareController = [UIAlertController alertControllerWithTitle:@"What kind of Link?"
                                               message:nil
                                               preferredStyle:UIAlertControllerStyleAlert];
    
    shareController.title = @"What Kind of Link?";
    
    UIAlertAction *viewAction = [UIAlertAction actionWithTitle:@"View Only"
                                                         style:UIAlertActionStyleDefault
                                                       handler:viewCompletion];
    
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit"
                                                         style:UIAlertActionStyleDefault
                                                       handler:editCompletion];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){}];
    [shareController addAction:viewAction];
    [shareController addAction:editAction];
    [shareController addAction:cancel];
    return shareController;
}

+ (void)createNewFolderWithParentId:(NSString*)parentId
                             client:(MSGraphClient *)client
                     viewController:(UIViewController *)viewController
                         completion:(MSGraphDriveItemCompletionHandler)completion;
{
    UIAlertController *newFolder = [UIAlertController alertControllerWithTitle:@"Create New Folder" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [newFolder addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"New Folder";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            UITextField *folderName =  newFolder.textFields.firstObject;
            MSGraphDriveItem *newFolder = [[MSGraphDriveItem alloc] initWithDictionary:@{[MSNameConflict rename].key : [MSNameConflict rename].value}];
            newFolder.name = folderName.text;
            newFolder.folder = [[MSGraphFolder alloc] init];
            [[[[[[client me] drive] items:parentId] children] request] addDriveItem:newFolder withCompletion:completion];
        }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [newFolder addAction:ok];
    [newFolder addAction:cancel];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [viewController presentViewController:newFolder animated:YES completion:nil];
    });
}

+ (void)deleteItem:(MSGraphDriveItem *)item
        withClient:(MSGraphClient *)client
    viewController:(UIViewController *)parentViewController
        completion:(deleteItemCompletion)completion;
{
    UIAlertController *deleteController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@",item.name]
                                                                              message:@"This action is final"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [[[[[client me] drive] items:item.entityId] requestWithOptions:@[[MSIfMatch entityTags:item.eTag]]] deleteWithCompletion:completion];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [deleteController addAction:deleteAction];
    [deleteController addAction:cancelAction];
   
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:deleteController animated:YES completion:nil];
    });
}
                   

+ (void) createLocalPlainTextFileWithParent:(MSGraphDriveItem *)parent
                                     client:(MSGraphClient *)client
                             viewController:(UIViewController *)parentViewController;
{
    UIAlertController *newFile = [UIAlertController alertControllerWithTitle:@"Create New Text file" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [newFile addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"NewFile";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *fileName =  newFile.textFields.firstObject;
        NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSData *textFile = [@"Foo Bar Baz Qux" dataUsingEncoding:NSUTF8StringEncoding];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName.text];
        
        [textFile writeToFile:filePath atomically:YES];
        ODXTextViewController *newController = [parentViewController.storyboard instantiateViewControllerWithIdentifier:@"FileViewController"];
        newController.filePath = filePath;
        newController.client = client;
        newController.parentItem = parent;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [parentViewController.navigationController pushViewController:newController animated:YES];
        });
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [newFile addAction:ok];
    [newFile addAction:cancel];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:newFile animated:YES completion:nil];
    });
}

+ (void) uploadNewFileWithParent:(MSGraphDriveItem *)parent
                          client:(MSGraphClient *)client
                  viewController:(UIViewController *)parentViewController
                            path:(NSURL*)filePath
               completionHandler:(MSGraphDriveItemUploadCompletionHandler)completionHandler;
{
    NSString *fileName = [[filePath lastPathComponent] stringByRemovingPercentEncoding];
    if (![[fileName pathExtension] isEqualToString:@"txt"]){
        fileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
    }
    
    [ODXActionController uploadFileWithContentRequest:[[[[[client me] drive] items:parent.entityId] itemByPath:fileName] contentRequest] fileURL:filePath completion:completionHandler];
}

+ (void) updateFileContent:(MSGraphDriveItem *)item
            viewControlelr:(UIViewController *)parentViewController
                    client:(MSGraphClient *)client
                      path:(NSURL *)filePath
                completion:(MSGraphDriveItemUploadCompletionHandler)completionHandler;
{
    [ODXActionController uploadFileWithContentRequest:[[[[client me] drive] items:item.entityId] contentRequestWithOptions:@[[MSIfMatch entityTags:item.cTag]]] fileURL:filePath completion:completionHandler];
}

+ (void)uploadFileWithContentRequest:(MSGraphDriveItemContentRequest*)contentRequest
                              fileURL:(NSURL*)fileURL
                           completion:(MSGraphDriveItemUploadCompletionHandler)completion
{
    [contentRequest uploadFromFile:fileURL completion:completion];
}

+ (void) moveItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
   viewController:(UIViewController *)parentViewController
   completion:(void(^)(MSGraphDriveItem *response, NSError *error))completionHandler;
{
    
    UIAlertController *moveItemController = [UIAlertController alertControllerWithTitle:@"Move Item" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [moveItemController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter Path from root";
    }];
    
    UIAlertAction *moveAction= [UIAlertAction actionWithTitle:@"Move" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = moveItemController.textFields.firstObject;
        NSString *servicePath = textField.text;
        NSString *fullPath = [NSString stringWithFormat:@"/drive/root:/%@", servicePath];
        MSGraphItemReference *parentRef = [[MSGraphItemReference alloc] init];
        parentRef.path = fullPath;
        MSGraphDriveItem *updatedItem = [[MSGraphDriveItem alloc] init];
        updatedItem.parentReference = parentRef;
        [[[[[client me] drive] items:item.entityId] request] update:updatedItem withCompletion:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [moveItemController addAction:moveAction];
    [moveItemController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:moveItemController animated:YES completion:nil];
    });
}

+ (void) copyItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
   viewController:(UIViewController *)parentViewController
       completion:(void (^)(MSGraphDriveItem *item, NSError *error))completionHandler;
{
    [ODXActionController copyItem:item withClient:client conflictBehaviour:nil viewController:parentViewController completion:completionHandler];
}

+ (void) copyItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
conflictBehaviour:(MSNameConflict *)conflictBehaviour
   viewController:(UIViewController *)parentViewController
       completion:(void (^)(MSGraphDriveItem *item, NSError *error))completionHandler;
{
    UIAlertController *copyItemController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@" Copy %@", item.name]
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [copyItemController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter Path from root";
    }];
    
    UIAlertAction *moveAction= [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = copyItemController.textFields.firstObject;
        NSString *servicePath = textField.text;
        NSString *fullPath = [NSString stringWithFormat:@"/drive/root:/%@", servicePath];
        MSGraphItemReference *parentRef = [[MSGraphItemReference alloc] init];
        parentRef.path = fullPath;
        item.parentReference = parentRef;
        MSGraphDriveItemCopyRequest *copyRequest = [[[[[client me] drive] items:item.entityId] copyWithName:item.name parentReference:parentRef] request];
        if (conflictBehaviour){
            copyRequest = [copyRequest nameConflict:conflictBehaviour];
        }
        [copyRequest executeWithCompletion:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [copyItemController addAction:moveAction];
    [copyItemController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:copyItemController animated:YES completion:nil];
    });
}

+ (void)renameItem:(MSGraphDriveItem *)item
        withClient:(MSGraphClient *)client
    viewController:(UIViewController *)parentViewController
   completion:(void(^)(MSGraphDriveItem *response, NSError *error))completionHandler
{
    UIAlertController *renameItemController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@" Rename %@", item.name]
                                                                                  message:nil
                                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    [renameItemController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter New Name";
    }];
    
    UIAlertAction *rename= [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = renameItemController.textFields.firstObject;
        NSString *newName = textField.text;
        MSGraphDriveItem *updatedItem= [[MSGraphDriveItem alloc] init];
        updatedItem.name = newName;
        [[[[[client me] drive] items:item.entityId] request] update:updatedItem withCompletion:completionHandler];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [renameItemController addAction:rename];
    [renameItemController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [parentViewController presentViewController:renameItemController animated:YES completion:nil];
    });
    
}

@end
