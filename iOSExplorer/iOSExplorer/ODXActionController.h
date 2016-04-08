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


#import <Foundation/Foundation.h>
#import <MSGraphSDK/MSGraphSDK.h>

typedef void (^shareCompletionHandler)(MSGraphPermission *permission, NSError *error);
typedef void (^deleteItemCompletion)(NSError *error);

@interface ODXActionController : NSObject

+ (void)shareItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
   viewController:(UIViewController *)viewController
       completion:(shareCompletionHandler)completion;

+ (void)createNewFolderWithParentId:(NSString*)parentId
                             client:(MSGraphClient *)client
                     viewController:(UIViewController *)parentViewController
                         completion:(MSGraphDriveItemCompletionHandler)completion;

+ (void)deleteItem:(MSGraphDriveItem *)item
        withClient:(MSGraphClient *)client
    viewController:(UIViewController *)parentViewcontroller
        completion:(deleteItemCompletion)completion;

+ (void) createLocalPlainTextFileWithParent:(MSGraphDriveItem *)parent
                                     client:(MSGraphClient *)client
                             viewController:(UIViewController *)parentViewController;

+ (void) uploadNewFileWithParent:(MSGraphDriveItem *)parent
                          client:(MSGraphClient *)client
                  viewController:(UIViewController *)parentViewController
                            path:(NSURL*)filePath
               completionHandler:(MSGraphDriveItemUploadCompletionHandler)completionHandler;

+ (void) updateFileContent:(MSGraphDriveItem *)item
            viewControlelr:(UIViewController *)parentViewController
                    client:(MSGraphClient *)client
                      path:(NSURL*)filePath
                completion:(MSGraphDriveItemUploadCompletionHandler)completionHandler;

+ (void) moveItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
   viewController:(UIViewController *)parentViewController
   completion:(void(^)(MSGraphDriveItem *response, NSError *error))completionHandler;

+ (void) copyItem:(MSGraphDriveItem *)item
       withClient:(MSGraphClient *)client
   viewController:(UIViewController *)parentViewController
        completion:(void (^)(MSGraphDriveItem *item, NSError *error))completionHandler;

+ (void)renameItem:(MSGraphDriveItem *)item
        withClient:(MSGraphClient *)client
    viewController:(UIViewController *)parentViewController
   completion:(void(^)(MSGraphDriveItem *response, NSError *error))completionHandler;

@end
