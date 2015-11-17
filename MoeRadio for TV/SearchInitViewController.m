//
//  SearchInitViewController.m
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/11/11.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import "SearchInitViewController.h"

@interface SearchInitViewController ()

@end

@implementation SearchInitViewController
- (UIView *)preferredFocusedView
{
    return self.kwfield;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    mode = @"";
    
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

-(IBAction)startSongSearch:(id)sender{
    mode = @"SongSearch";
    [self startSearch];
}
-(IBAction)startAlbumSearch:(id)sender{
    mode = @"AlbumSearch";
    [self startSearch];
}
-(void)startSearch{
    
    if ([self.kwfield.text length] > 0) {
        SearchCollectionViewController *resultsController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchCollectionViewController"];
        UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];
        searchController.searchResultsUpdater = resultsController;
        searchController.delegate = resultsController;
        searchController.searchBar.placeholder = NSLocalizedString(@"SEARCH_PLACEHOLDER", nil);
        searchController.searchBar.text = self.kwfield.text;
        resultsController.keyword = self.kwfield.text;
        resultsController.searchtype = mode;
        [self.view.window.rootViewController presentViewController:searchController animated:YES completion:^{
            NULL;
        }];
    }

}
@end
