//
//  SearchCollectionViewController.m
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/11/11.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import "SearchCollectionViewController.h"

@interface SearchCollectionViewController ()

@end

@implementation SearchCollectionViewController

static NSString * const reuseIdentifier = @"SearchCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[SearchCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];//not need for tvOS!
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [moefmapi cancelRequest];
}
-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"nowtype:%@",self.searchtype);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
    songlist = [NSArray new];
    
    // Do any additional setup after loading the view.
    //    if (self.searchtype.length == 0) {
    //        self.searchtype = Type_Song_Search;
    //    }
    
    moefmapi = [[MoeFmAPI alloc] initWithApiKey:MFCkey delegate:self];
    
    //NSString *str = [NSString stringWithFormat:@"%@",self.keyword];
    //NSLog(@"strrrr:%@",str);
    if (page == 0) {
        page = 1;
    }
    [self startSeachWithKeyword:self.keyword WithType:self.searchtype WithPage:1];
    
    //[self.collectionView reloadData];

}
-(void)startSeachWithKeyword:(NSString *)keyword WithType:(NSString *)type WithPage:(NSInteger)pages{
    if ([keyword length]>0) {
        
        page = pages;
        NSString *url = @"";
        if ([type  isEqualToString:Type_Song_Search]) {
            url = [searchsuburl stringByAppendingFormat:@"&sub_type=%@",@"song"];
        }else{
            url = [searchwikiurl stringByAppendingFormat:@"&wiki_type=%@",@"music"];
        }
        
        NSString *keywordEncoded = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        
        
        url = [url stringByAppendingFormat:@"&keyword=%@",keywordEncoded];
        url = [url stringByAppendingFormat:@"&page=%ld",pages];
        [moefmapi requestJsonWithURL:url];
        url = nil;
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)api:(MoeFmAPI *)api readyWithJson:(NSDictionary *)json{
    
    if ([[json valueForKey:@"information"] valueForKey:@"count"] == [NSNumber numberWithInteger:0] && page <= 1) {
        //NSLog(@"count0");
        songlist = [NSArray new];
        //NSLog(@"songlist:%@",songlist);
        [self.collectionView reloadData];
    }else{
        if ([self.searchtype isEqual:Type_Song_Search]) {
            if ([json valueForKey:@"subs"] != [NSNull null]) {
                NSArray *arr = [json valueForKey:@"subs"];
                
                //remove songs that don't have mp3 files
                for (NSInteger i=0; i<[arr count]; i++) {
                    NSArray *arr2 = [arr objectAtIndex:i];
                    //NSLog(@"count:%ld arr2:%@",[[arr2 valueForKey:@"sub_upload"] count],arr2);
                    if ([[arr2 valueForKey:@"sub_upload"] count] > 0) {
                        //NSLog(@"yesithaveat:%ld",i);
                        songlist = [songlist arrayByAddingObject:arr2];
                        
                        arr2=nil;
                    }
                }
                arr = nil;
                
                
            }else{
                //NSLog(@"EndofPage");
            }
            
            
        }else{
            if ([json valueForKey:@"wikis"] != [NSNull null]) {
                songlist = [songlist arrayByAddingObjectsFromArray:[json valueForKey:@"wikis"]];
            }else{
                //NSLog(@"EndofPage");
            }
            
        }
        if (debugmode == YES) {
            NSLog(@"songlist:%@",songlist);
        }
        
        [self.collectionView reloadData];
        
    }
    
}
-(void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error{
    NSLog(@"error:%@",error);
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of items
    return [songlist count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SearchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    
    
    
    NSString *imageurl = @"";
    if ([self.searchtype isEqual:Type_Song_Search]) {
        cell.songtitle.text = [self htmlEntityDecode:[[songlist objectAtIndex:indexPath.row] valueForKey:@"sub_title"]];
        imageurl = [[[[songlist objectAtIndex:indexPath.row] valueForKey:@"wiki"] valueForKey:@"wiki_cover"] valueForKey:@"square"];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handleLongPress:)];
        [longPress setMinimumPressDuration:1.0];
        [cell addGestureRecognizer:longPress];
    }else{
        cell.songtitle.text = [self htmlEntityDecode:[[songlist objectAtIndex:indexPath.row] valueForKey:@"wiki_title"]];
        imageurl =[[[songlist objectAtIndex:indexPath.row] valueForKey:@"wiki_cover"] valueForKey:@"square"];
    }
    
        
    cell.songimage.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.songimage.image = image;
                });
            }
        }
        
    });

    
    
    
    cell.songimage.adjustsImageWhenAncestorFocused = YES;
    
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *sid = @"";
    if ([self.searchtype isEqual:Type_Song_Search]) {
       sid = [[songlist objectAtIndex:indexPath.row] valueForKey:@"sub_id"];
        
    }else{
        sid = [[songlist objectAtIndex:indexPath.row] valueForKey:@"wiki_id"];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.searchtype,@"SearchType",sid,@"IDs", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPSongNotification"
                                                        object:self
                                                      userInfo:dic];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UICollectionViewCell *selectedCell = sender.view;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:selectedCell];
        
        NSString *albumid = [[[songlist objectAtIndex:indexPath.row] valueForKey:@"wiki"] valueForKey:@"wiki_id"];
        if (debugmode == YES) {
            NSLog(@"playalbum:%@",albumid);
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:Type_Album_Search,@"SearchType",albumid,@"IDs", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPSongNotification"
                                                            object:self
                                                          userInfo:dic];
    }
    
    
    
    
}

//// Uncomment this method to specify if the specified item should be highlighted during tracking
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//	return YES;
//}
//
//
//
//// Uncomment this method to specify if the specified item should be selected
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height)
    {
        //LOAD MORE
        // you can also add a isLoading bool value for better dealing :D
        if (debugmode == YES) {
            NSLog(@"should load more");
        }
        
        page++;
        [self startSeachWithKeyword:self.keyword WithType:self.searchtype WithPage:page];
    }
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchstr = searchController.searchBar.text;
    //NSLog(@"strr2:%@",searchstr);
    if (self.searchtype.length > 0 && searchstr.length > 0 && self.keyword != searchstr) {
        if (page == 0) {
            page = 1;
        }
        self.keyword = searchstr;
        [self startSeachWithKeyword:searchstr WithType:self.searchtype WithPage:1];
    }else if (searchstr.length <= 0 || self.keyword <= 0){
        songlist = [NSArray new];
        [self.collectionView reloadData];
    }
    
}
-(NSString *)htmlEntityDecode:(NSString *)string{
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
