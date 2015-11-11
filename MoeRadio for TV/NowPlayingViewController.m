//
//  NowPlayingViewController.m
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/09/27.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "MoeFmAPI.h"
#import "MoeFmPlayer.h"


#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
typedef enum {
    MFMPVC_NETWORK_ALERT = 0,
    MFMPVC_PLAYER_ERR_ALERT,
    MFMPVC_REQUEST_ERR_ALERT
} MFMPlayerViewAlertTags;

@interface NowPlayingViewController ()

@property (retain, nonatomic) MoeFmPlayer *player;
@property (retain, nonatomic) MoeFmAPI *playlistAPI;
@property (retain, nonatomic) MoeFmAPI *imageAPI;

- (MoeFmAPI *)createAPI;
@end

@implementation NowPlayingViewController
@synthesize songNameLabel = _songNameLabel;
@synthesize songInfoLabel = _songInfoLabel;
@synthesize songProgressIndicator = _songProgressIndicator;
@synthesize songArtworkImage = _songArtworkImage;
@synthesize songArtworkLoadingIndicator = _songArtworkLoadingIndicator;
@synthesize songBufferingIndicator = _songBufferingIndicator;
@synthesize playButton = _playButton;

@synthesize nextButton = _nextButton;

@synthesize player = _player;
@synthesize playlistAPI = _playlistAPI;
@synthesize imageAPI = _imageAPI;


- (UIView *)preferredFocusedView
{
    return self.nextButton;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Create APIs
    [self resetMetadataView];
    if(!self.playlistAPI){
        self.playlistAPI = [self createAPI];
    }
    if(!self.imageAPI){
        self.imageAPI = [self createAPI];
    }
    
    // Create player
    if(!self.player){
        self.player = [[MoeFmPlayer alloc] initWithDelegate:self];
    }
    page=0;
    //recive message from other view
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChangeSongNumberNotification:)
                                                 name:@"changeSongNumberNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePlayControlNotification:)
                                                 name:@"PlayControlNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePlayPSongNotification:)
                                                 name:@"PlayPSongNotification"
                                               object:nil];
    
    
    
    
    
    
    UITapGestureRecognizer *selectButtonGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    selectButtonGesture.allowedPressTypes = @[@(UIPressTypePlayPause)];//,@(UIPressTypeMenu)];
    [self.view addGestureRecognizer:selectButtonGesture];
    
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"toggle button pressed");
        [self startOrPause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(startOrPause)];//this is shit
    


}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
-(void)receivePlayPSongNotification:(NSNotification *)notify{
    if ([[[notify userInfo] valueForKey:@"SearchType"]isEqualToString:@"SongSearch"]) {
        songid = [[[notify userInfo] valueForKey:@"IDs"] stringValue];
        playmode = @"searchplaysong";
    }else{
        albumid = [[[notify userInfo] valueForKey:@"IDs"] stringValue];
        playmode = @"searchplaymusic";
    }
    
    
    [self refreshPlaylist];
}
-(void)receivePlayControlNotification:(NSNotification *)notify{
    //control form list
    [self startOrPause];
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
            
            NSLog(@"pressesBegan,item = %@", item);
        }
        
        switch (item.type) {
            case UIPressTypePlayPause:
                [self startOrPause];
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
- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        playmode = @"";
        [self refreshPlaylist];
    }
}
/* The iPod controls will send these events when the app is in the background */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //[[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (debugmode == YES) {
        NSLog(@"remoteControlReceived,type:%ld",(long)event.subtype);
    }
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self startOrPause];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self startOrPause];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self startOrPause];
            break;
        case UIEventSubtypeRemoteControlStop:
            [self startOrPause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
        
        default:
            break;
    }

}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Allow application to recieve remote control
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //[self becomeFirstResponder]; // this enables listening for events
    //[self resetMetadataView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    //play at start
    [self start];
    
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - View Updater

- (void) updateMetadata:(NSDictionary *)metadata
{
    NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
    
    // Update Song Title
    self.songNameLabel.text = [self htmlEntityDecode:[metadata objectForKey:@"sub_title"]];
    if([self.songNameLabel.text length] == 0) {
        self.songNameLabel.text = @"未知歌曲";
    }
    [nowPlayingInfo setValue:self.songNameLabel.text forKey:MPMediaItemPropertyTitle];
    
    // Update Artist
    NSString *artist = [metadata objectForKey:@"artist"];
    if([artist length] == 0) {
        artist = @"未知艺术家";
    }
    [nowPlayingInfo setValue:artist forKey:MPMediaItemPropertyArtist];
    
    // Update Album
    NSString *album = [metadata objectForKey:@"wiki_title"];
    if([album length] == 0) {
        album = @"未知专辑";
    }
    [nowPlayingInfo setValue:album forKey:MPMediaItemPropertyAlbumTitle];
    
    self.songInfoLabel.text = [self htmlEntityDecode:[NSString stringWithFormat:@"%@ / %@", artist, album]];
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
    
    // Update image async
    NSString *coverSize = nil;
    coverSize = @"large";
    NSString *imageAddress = [[metadata objectForKey:@"cover"] objectForKey:coverSize];
    NSURL *imageURL = [NSURL URLWithString:imageAddress];
    
    //NSLog(@"Requesting image");
    if(self.imageAPI.isBusy){
        [self.imageAPI cancelRequest];
        NSLog(@"Image API request canceled");
    }
    
    BOOL status = [self.imageAPI requestImageWithURL:imageURL];
    if(status == NO){
        // Fail to establish connection
        NSLog(@"Unable to create connection for %@", imageURL);
    }
    else {
        [self.songArtworkLoadingIndicator startAnimating];
    }
}

- (void) updateArtworkWithImage:(UIImage *)image
{
    self.songArtworkImage.image = image;
    [self.songArtworkLoadingIndicator stopAnimating];
    
    
    
    
    
}

- (void) resetMetadataView
{
    self.songNameLabel.text = @"加载中……";
    self.songInfoLabel.text = @"请等待……（>人<）";
    //self.songArtworkImage.image = [UIImage imageNamed:@"cover_large.png"];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [self.songProgressIndicator setProgress:1 animated:YES];//ios5
    }
    else {
        self.songProgressIndicator.progress = 1;
    }
}

#pragma mark - Player Controls

- (void)start{
    [self.player start];
}

- (void)pause{
    [self.player pause];
}

- (void)startOrPause{
    [self.player startOrPause];
}

- (void)stop{
    [self.player stop];
}

- (void)next{
    [self.player stop];
    [self.player next];
}

- (void)previous{
    [self.player previous];
}

#pragma mark - Actions

- (IBAction)togglePlaybackState:(UIButton *)sender
{
    [self startOrPause];
}



- (IBAction)nextTrack:(UIButton *)sender
{
    [self next];
}




#pragma mark - MoeFmPlayer Delegates

- (void)player:(MoeFmPlayer *)player needToUpdatePlaylist:(NSArray *)currentplaylist
{
    //NSLog(@"Requesting playlist");
    if(self.playlistAPI.isBusy){
        NSLog(@"Playlist API is busy, try again later");
        return;
    }
    ++page;
    NSString *url = [playlisturl stringByAppendingFormat:@"&page=%ld",page];
    if ([playmode isEqualToString:@"searchplaysong"]){
        url = [url stringByAppendingFormat:@"&song=%@",songid];
    }else if ([playmode isEqualToString:@"searchplaymusic"]){
        url = [url stringByAppendingFormat:@"&music=%@",albumid];
    }
    
    BOOL status = [self.playlistAPI requestListenPlaylistWithURL:url];
    if(status == NO){
        // Fail to establish connection
        NSLog(@"Unable to create connection for playlist");
    }
}

- (void)player:(MoeFmPlayer *)player updateProgress:(float)percentage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [self.songProgressIndicator setProgress:percentage animated:YES];//ios5
    }
    else {
        self.songProgressIndicator.progress = percentage;
    }
}

- (void)player:(MoeFmPlayer *)player updateMetadata:(NSDictionary *)metadata
{
    [self updateMetadata:metadata];
}

- (void)player:(MoeFmPlayer *)player stateChangesTo:(AudioStreamerState)state
{
    switch (state) {
        case AS_WAITING_FOR_DATA:
            self.playButton.alpha = 1;
            //self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
            [self.songBufferingIndicator startAnimating];
            break;
        case AS_BUFFERING:
            //self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
            self.playButton.alpha = 1;
            [self.songBufferingIndicator startAnimating];
            break;
        case AS_PLAYING:
            self.playButton.alpha = 1;
            //self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
            [self.songBufferingIndicator stopAnimating];
            break;
        case AS_PAUSED:
            self.playButton.alpha = 1;
            //self.playButton.imageView.image = [UIImage imageNamed:@"play.png"];
            [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
            [self.songBufferingIndicator stopAnimating];
            break;
        case AS_STOPPED:
            //self.playButton.imageView.image = [UIImage imageNamed:@"play.png"];
            [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
            self.playButton.alpha = 1;
            [self.songBufferingIndicator stopAnimating];
            break;
            
        default:
            break;
    }
}

- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发现错误" message:error preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //NSLog(@"closed");
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    page=0;
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark - MoeFmAPI Delegates

- (MoeFmAPI *)createAPI
{
    return [[MoeFmAPI alloc] initWithApiKey:MFCkey
                                   delegate:self];
}

- (void)api:(MoeFmAPI *)api readyWithPlaylist:(NSArray *)playlist
{
    [self.player setPlaylist:playlist];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:playlist forKey:@"playlist"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewNotification"
                                                        object:self
                                                        userInfo:dic];
    
}

- (void)api:(MoeFmAPI *)api readyWithImage:(UIImage *)image{
    [self updateArtworkWithImage:image];
}

- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发现错误" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //NSLog(@"closed");
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    page=0;
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)player:(MoeFmPlayer *)player updatetrackmun:(NSInteger)trackmun{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:trackmun] forKey:@"songnum"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NowPlayingNumNotification"
                                                        object:self
                                                      userInfo:dic];
}
-(void)receiveChangeSongNumberNotification:(NSNotification *) notification{
    NSInteger songnum = [[[notification userInfo] valueForKey:@"songnum"] integerValue];
    [self stop];
    [self.player startTrack:songnum];
}

-(void)refreshPlaylist{
    [self resetMetadataView];
    [self stop];
    
    if (debugmode == YES) {
        NSLog(@"Player Reseting...");
    }
    
    self.playlistAPI = nil;
    self.imageAPI = nil;
    self.player = nil;
    
    if(!self.playlistAPI){
        self.playlistAPI = [self createAPI];
    }
    if(!self.imageAPI){
        self.imageAPI = [self createAPI];
    }
    
    // Create player
    if(!self.player){
        self.player = [[MoeFmPlayer alloc] initWithDelegate:self];
    }
    page = 0;
    [self next];
}
-(IBAction)refreshPlaylistbtn:(id)sender{
    playmode = @"";
    [self refreshPlaylist];
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
