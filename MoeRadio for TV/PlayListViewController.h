//
//  PlayListViewController.h
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/09/27.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"


@interface PlayListViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>{
    NSArray *playlist1;
}

//@property (nonatomic, strong) IBOutlet UITableView *tableView1;
-(IBAction)refrashlist:(id)sender;
- (void)initPlaylist:(NSArray *)playlist;

@end
