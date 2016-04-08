//
//  ViewController.h
//  SimpleTest
//
//  Created by Miguel Ángel Pérez Martínez on 1/19/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController


@property (nonatomic, strong) NSMutableArray *availableTests;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

