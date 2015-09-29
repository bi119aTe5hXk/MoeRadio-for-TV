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
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //_playlist1 = [NSArray new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReloadTableViewNotification:)
                                                 name:@"reloadTableViewNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNowPlayingNumNotification:)
                                                 name:@"NowPlayingNumNotification"
                                               object:nil];
   
    
}
-(void)viewWillAppear:(BOOL)animated{
    playlist1 = [NSArray new];
    
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
    NSLog(@"willrefreshtable");
    [self.tableView reloadData];
    //NSLog(@"PlayListList:%@",playlist1);
    
    
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
    
    
    return [playlist1 count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil){
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    
    if (indexPath.row == [playlist1 count]) {
        cell.textLabel.text = @"            Refrash List";
        cell.detailTextLabel.text = @"";
    }else{
        NSArray *arr = [playlist1 objectAtIndex:indexPath.row];
        
        // Update Song Title
        cell.textLabel.text = [self htmlEntityDecode:[arr valueForKey:@"sub_title"]];
        
        // Update Artist
        NSString *artist = [arr valueForKey:@"artist"];
        if([artist length] == 0) {
            artist = @"Unknown artist";
        }
        // Update Album
        NSString *album = [arr valueForKey:@"wiki_title"];
        if([album length] == 0) {
            album = @"Unknown album";
        }
        cell.detailTextLabel.text = [self htmlEntityDecode:[NSString stringWithFormat:@"%@ / %@", artist, album] ];
    }
    
    
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSString *songid = [[playlist1 objectAtIndex:indexPath.row] valueForKey:@"sub_id"];
    if (indexPath.row == [playlist1 count]) {
        [self refrashlist:nil];
    }else{
        NSInteger songnum = indexPath.row;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:songnum] forKey:@"songnum"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSongNumberNotification"
                                                            object:self
                                                          userInfo:dic];

    }
    
}
-(IBAction)refrashlist:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefrashPlayListNotification"
                                                        object:self];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
