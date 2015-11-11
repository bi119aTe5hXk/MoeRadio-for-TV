//
//  SearchCollectionViewController.h
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/11/11.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoeFmAPI.h"
#import "API.h"
#import "SearchCollectionViewCell.h"
@interface SearchCollectionViewController : UICollectionViewController<UISearchResultsUpdating,MoeFmAPIDelegate,UISearchControllerDelegate>{
    MoeFmAPI *moefmapi;
    NSInteger page;
    NSArray *songlist;
}
@property (nonatomic, strong) NSString *keyword;
@end
