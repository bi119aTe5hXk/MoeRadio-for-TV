//
//  SearchInitViewController.h
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/11/11.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCollectionViewController.h"
@interface SearchInitViewController : UIViewController<UISearchControllerDelegate>{
    NSString *mode;
}
@property (nonatomic, strong) IBOutlet UITextField *kwfield;
-(IBAction)startSongSearch:(id)sender;
-(IBAction)startAlbumSearch:(id)sender;
@end
