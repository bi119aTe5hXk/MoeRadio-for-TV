//
//  PlayListViewController.m
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/09/27.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import "PlayListViewController.h"



@implementation PlayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
     //self.clearsSelectionOnViewWillAppear = YES;
    //self.navigationController.navigationBar.hidden = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //_playlist1 = [NSArray new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsMultipleSelection = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadTableViewNotification:)
                                                 name:@"reloadTableViewNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNowPlayingNumNotification:)
                                                 name:@"NowPlayingNumNotification"
                                               object:nil];

    UITapGestureRecognizer *selectButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    selectButtonGesture.allowedPressTypes = @[[NSNumber numberWithInteger:UIPressTypePlayPause]];
    [self.view addGestureRecognizer:selectButtonGesture];

    
}
-(void)handleTap:(UITapGestureRecognizer *)sender {
    if (debugmode == YES) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            NSLog(@"button pressed");
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            NSLog(@"button released");
        }
    }
    
    
}
- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(nullable UIPressesEvent *)event {
    
    for (UIPress *item in presses)
    {
        if (debugmode == YES) {
            
            NSLog(@"item = %@", item);
        }
        
        switch (item.type) {
            case UIPressTypePlayPause:
                //[self startOrPause];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayControlNotification"
                                                                    object:self
                                                                  userInfo:nil];
                break;
            case UIPressTypeMenu:
                return [super pressesEnded:presses withEvent:event];
                break;
            default:
                break;
        }
        
        
    }
//    if (((UIPress *)[presses anyObject]).type == UIPressTypeMenu) {
//        return [super pressesEnded:presses withEvent:event];
//    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    //playlist1 = [NSArray new];
    
}

- (void)receiveReloadTableViewNotification:(NSNotification *) notification
{
    NSDictionary *dic = [notification userInfo];
    [self initPlaylist:[dic objectForKey:@"playlist"]];
}
-(void)receiveNowPlayingNumNotification:(NSNotification *) notification{
    if ([playlist1 count] >0) {
        NSInteger songnum = [[[notification userInfo] valueForKey:@"songnum"] integerValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:songnum inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
    }
    
}
- (void)initPlaylist:(NSArray *)playlist{
    playlist1 = playlist;
    [self.tableView reloadData];
    //NSLog(@"PlayListList:%@",playlist1);
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    
    return [playlist1 count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil){
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    
    NSArray *arr = [playlist1 objectAtIndex:indexPath.row];
    
    // Update Song Title
    cell.textLabel.text = [self htmlEntityDecode:[arr valueForKey:@"sub_title"]];
    
    // Update Artist
    NSString *artist = [arr valueForKey:@"artist"];
    if([artist length] == 0) {
        artist = @"未知艺术家";
    }
    // Update Album
    NSString *album = [arr valueForKey:@"wiki_title"];
    if([album length] == 0) {
        album = @"未知专辑";
    }
    cell.detailTextLabel.text = [self htmlEntityDecode:[NSString stringWithFormat:@"%@ / %@", artist, album] ];
    
    
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger songnum = indexPath.row;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:songnum] forKey:@"songnum"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSongNumberNotification"
                                                        object:self
                                                      userInfo:dic];
    
}
- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


-(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    string = [string stringByReplacingOccurrencesOfString:@"&rarr;" withString:@"→"];
    string = [string stringByReplacingOccurrencesOfString:@"&larr;" withString:@"←"];
    string = [string stringByReplacingOccurrencesOfString:@"&darr;" withString:@"↓"];
    string = [string stringByReplacingOccurrencesOfString:@"&uarr;" withString:@"↑"];
    string = [string stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"…"];
    string = [string stringByReplacingOccurrencesOfString:@"&infin;" withString:@"∞"];
    string = [string stringByReplacingOccurrencesOfString:@"&mu;" withString:@"μ"];
    string = [string stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"];
    string = [string stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"”"];
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"“"];
    string = [string stringByReplacingOccurrencesOfString:@"&middot;" withString:@"·"];
    string = [string stringByReplacingOccurrencesOfString:@"&minus;" withString:@"−"];
    string = [string stringByReplacingOccurrencesOfString:@"&times;" withString:@"×"];
    string = [string stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"’"];
    return string;
}
@end
