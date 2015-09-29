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



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Create APIs
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChangeSongNumberNotification:)
                                                 name:@"changeSongNumberNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRefrashPlayListNotification:)
                                                 name:@"RefrashPlayListNotification"
                                               object:nil];

}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetMetadataView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self start];
    
    [self becomeFirstResponder];
}
- (BOOL)canBecomeFirstResponder {
    return YES;
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
    self.songNameLabel.text = [metadata objectForKey:@"sub_title"];
    if([self.songNameLabel.text length] == 0) {
        self.songNameLabel.text = @"Unknown song";
    }
    [nowPlayingInfo setValue:self.songNameLabel.text forKey:MPMediaItemPropertyTitle];
    
    // Update Artist
    NSString *artist = [metadata objectForKey:@"artist"];
    if([artist length] == 0) {
        artist = @"Unknown artist";
    }
    [nowPlayingInfo setValue:artist forKey:MPMediaItemPropertyArtist];
    
    // Update Album
    NSString *album = [metadata objectForKey:@"wiki_title"];
    if([album length] == 0) {
        album = @"Unknown album";
    }
    [nowPlayingInfo setValue:album forKey:MPMediaItemPropertyAlbumTitle];
    
    self.songInfoLabel.text = [NSString stringWithFormat:@"%@ / %@", artist, album];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        // Post to NowPlayingInfoCenter
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
    }
    
    // Update image async
    NSString *coverSize = nil;
    coverSize = @"large";
    NSString *imageAddress = [[metadata objectForKey:@"cover"] objectForKey:coverSize];
    NSURL *imageURL = [NSURL URLWithString:imageAddress];
    
    NSLog(@"Requesting image");
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
    self.songNameLabel.text = NSLocalizedString(@"DEFAULT_SONG", @"");;
    self.songInfoLabel.text = NSLocalizedString(@"DEFAULT_INFO_LABEL", @"");;
    self.songArtworkImage.image = [UIImage imageNamed:@"cover_large.png"];
    
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
    NSLog(@"Requesting playlist");
    if(self.playlistAPI.isBusy){
        NSLog(@"Playlist API is busy, try again later");
        return;
    }
    
    BOOL status = [self.playlistAPI requestListenPlaylistWithPage:0];
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
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            [self.songBufferingIndicator startAnimating];
            break;
        case AS_BUFFERING:
            //self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            self.playButton.alpha = 1;
            [self.songBufferingIndicator startAnimating];
            break;
        case AS_PLAYING:
            self.playButton.alpha = 1;
            //self.playButton.imageView.image = [UIImage imageNamed:@"pause.png"];
            [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
            [self.songBufferingIndicator stopAnimating];
            break;
        case AS_PAUSED:
            self.playButton.alpha = 1;
            //self.playButton.imageView.image = [UIImage imageNamed:@"play.png"];
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            [self.songBufferingIndicator stopAnimating];
            break;
        case AS_STOPPED:
            //self.playButton.imageView.image = [UIImage imageNamed:@"play.png"];
            [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
            self.playButton.alpha = 1;
            [self.songBufferingIndicator stopAnimating];
            break;
            
        default:
            break;
    }
}

- (void)player:(MoeFmPlayer *)player stoppingWithError:(NSString *)error
{
    
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
    //[self.playlistview initPlaylist:playlist];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:playlist forKey:@"playlist"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableViewNotification"
                                                        object:self
                                                        userInfo:dic];
    
}

- (void)api:(MoeFmAPI *)api readyWithImage:(UIImage *)image
{
    [self updateArtworkWithImage:image];
}

- (void)api:(MoeFmAPI *)api requestFailedWithError:(NSError *)error
{
    
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
    NSLog(@"songnum:%ld",songnum);
}
-(void)receiveRefrashPlayListNotification:(NSNotification *) notification{
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

    [self next];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
