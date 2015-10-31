//
//  NowPlayingViewController.h
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/09/27.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoeFmPlayer.h"
#import "MoeFmAPI.h"



@interface NowPlayingViewController : UIViewController<MoeFmPlayerDelegate, MoeFmAPIDelegate>{

}

@property (assign, nonatomic) IBOutlet UILabel *songNameLabel;
@property (assign, nonatomic) IBOutlet UILabel *songInfoLabel;
@property (assign, nonatomic) IBOutlet UIProgressView *songProgressIndicator;
@property (assign, nonatomic) IBOutlet UIImageView *songArtworkImage;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *songArtworkLoadingIndicator;
@property (assign, nonatomic) IBOutlet UIActivityIndicatorView *songBufferingIndicator;
@property (assign, nonatomic) IBOutlet UIButton *playButton;
@property (assign, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)togglePlaybackState:(UIButton *)sender;
- (IBAction)nextTrack:(UIButton *)sender;
-(IBAction)refreshPlaylistbtn:(id)sender;
-(void)handleTap:(UITapGestureRecognizer *)sender;
@end
