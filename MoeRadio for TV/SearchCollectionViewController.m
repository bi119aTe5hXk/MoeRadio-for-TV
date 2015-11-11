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
    //[self.collectionView registerClass:[SearchCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
    
    
    // Do any additional setup after loading the view.
    
    moefmapi = [[MoeFmAPI alloc] initWithApiKey:MFCkey delegate:self];
    
    NSString *str = [NSString stringWithFormat:@"%@",self.keyword];
    NSLog(@"strrrr:%@",str);
    [self startSeachWithKeyword:self.keyword];
    
    //[self.collectionView reloadData];
}
-(void)startSeachWithKeyword:(NSString *)keyword{
    if ([keyword length]>0) {
        page = 0;
        NSString *url = @"";
        
        url = [searchsuburl stringByAppendingFormat:@"&sub_type=%@",@"song"];
        
        NSString *keywordEncoded = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
        
        
        url = [url stringByAppendingFormat:@"&keyword=%@",keywordEncoded];
        page++;
        url = [url stringByAppendingFormat:@"&page=%ld",page];
        [moefmapi requestJsonWithURL:url];
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
    songlist = [json valueForKey:@"subs"];
    NSLog(@"songlist:%@",songlist);
    [self.collectionView reloadData];
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
    
    
    cell.songtitle.text = [[songlist objectAtIndex:indexPath.row] valueForKey:@"sub_title"];
    cell.songimage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[[songlist objectAtIndex:indexPath.row] valueForKey:@"wiki"] valueForKey:@"wiki_cover"] valueForKey:@"small"]]]];
    cell.songimage.adjustsImageWhenAncestorFocused = YES;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *songid = [[songlist objectAtIndex:indexPath.row] valueForKey:@"sub_id"];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:songid forKey:@"sub_id"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPSongNotification"
                                                        object:self
                                                      userInfo:dic];
    //[self dismissViewControllerAnimated:YES completion:nil];
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
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchstr = searchController.searchBar.text;
    self.keyword = searchstr;
    NSLog(@"strr2:%@",searchstr);
    [self startSeachWithKeyword:searchstr];
}

@end
