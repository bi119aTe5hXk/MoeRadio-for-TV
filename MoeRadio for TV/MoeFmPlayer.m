//
//  MoeFmPlayer.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MoeFmPlayer.h"
#import "AudioStreamer.h"

@interface MoeFmPlayer ()
@property (unsafe_unretained, nonatomic) NSObject <MoeFmPlayerDelegate> *delegate;
@property (strong, nonatomic) AudioStreamer *streamer;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) NSURL *audioURL;
@property (assign, nonatomic) NSUInteger trackNum;

@end


@implementation MoeFmPlayer
@synthesize playlist = _playlist;
@synthesize allowNetworkAccess = _allowNetworkAccess;

@synthesize delegate = _delegate;
@synthesize streamer = _streamer;
@synthesize updateTimer = _updateTimer;

@synthesize trackNum = _trackNum;


- (MoeFmPlayer *) initWithDelegate:(NSObject <MoeFmPlayerDelegate> *)delegate
{
	self = [super init];
	
	self.delegate = delegate;
    
	return self;
}

# pragma mark - Getter and Setter

- (void)setPlaylist:(NSArray *)playlist
{
	_playlist = playlist;
	self.trackNum = 0;
	[self stop];
	[self start];
}


# pragma mark - Streamer

- (void)createStreamerWithURL:(NSURL *)streamURL{
	
	if(self.streamer){
		[self destroyStreamer];
	}
    
	self.streamer = [[AudioStreamer alloc] initWithURL:streamURL];
    [self.streamer setMeteringEnabled:1];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(streamerStateChanged:)
                                                 name:ASStatusChangedNotification
                                               object:self.streamer];
    
	if (debugmode == YES) {
        NSLog(@"New streamer created:%@",streamURL);
    }
    
}

- (void)destroyStreamer{
	if(self.streamer){
		[self.streamer stop];
		self.streamer = nil;
		
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:self.streamer];
	}
}

- (void)toggleTimers:(BOOL)create {
	if (create) {
		if (self.streamer) {
			[self toggleTimers:NO];
			self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                                target:self
                                                              selector:@selector(updateProgress:)
                                                              userInfo:nil
                                                               repeats:YES];
            
            
		}
	}else {
		if (self.updateTimer){
            
			[self.updateTimer invalidate];
			self.updateTimer = nil;
		}
	}
}

- (void)streamerStateChanged:(NSNotification *)aNotification
{
	
	[self.delegate player:self stateChangesTo:[self.streamer state]];
	
	if ([self.streamer isPlaying]){
        if (debugmode == YES) {
            NSLog(@"Streamer is playing");
        }
        
        [self.streamer setMeteringEnabled:YES];
		[self toggleTimers:YES];
		return;
	}else if ([self.streamer isWaiting]){
        if (debugmode == YES) {
            NSLog(@"Streamer is waiting");
        }
        
        [self.streamer setMeteringEnabled:NO];
		[self toggleTimers:NO];
	}else if ([self.streamer isPaused]) {
        if (debugmode == YES) {
            NSLog(@"Streamer is paused");
        }
        
		[self toggleTimers:NO];
	}else if ([self.streamer isIdle]){
        if (debugmode == YES) {
            NSLog(@"Streamer is idle");
        }
        
		[self toggleTimers:NO];
	}
	
	if(self.streamer.errorCode != AS_NO_ERROR){
        if (debugmode == YES) {
            NSLog(@"Streamer stoped with error %@", [AudioStreamer stringForErrorCode:[self.streamer errorCode]]);
        }
		if([self.delegate respondsToSelector:@selector(player:stoppingWithError:)]){
			//[self.delegate player:self stoppingWithError:[AudioStreamer stringForErrorCode:[self.streamer errorCode]]];
		}
		[self stop];
        [self next];
	}
	
	if(self.streamer.stopReason == AS_STOPPING_EOF){
        if (debugmode == YES) {
            NSLog(@"Streamer reach EOF(End Of File), play next");
            NSLog(@"Log song because EOF problem");
        }
        
		[self next];
	}
    
}

- (void)updateProgress:(NSTimer *)timer{
	if(self.streamer){
		[self.delegate player:self updateProgress:self.streamer.progress / self.streamer.duration];
	}
}



- (void)updateMetadata{
    
	[self.delegate player:self updateMetadata:[self.playlist objectAtIndex:self.trackNum]];
    //[self.delegate player:self readyWithPlaylist:self.playlist];
    [self.delegate player:self updatetrackmun:self.trackNum];
}



- (void)start{
	if(!self.playlist){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	if(!self.streamer){
		NSDictionary *music = [self.playlist objectAtIndex:self.trackNum];
		NSString *audioAddress = [music objectForKey:@"url"];

		_audioURL = [NSURL URLWithString:audioAddress];
		[self createStreamerWithURL:_audioURL];
		[self updateMetadata];
	}
	if (![self.streamer isPlaying]) {
		[self.streamer start];
        if (debugmode == YES) {
            NSLog(@"Player start on track %ld", self.trackNum);
        }
	}
}
- (void)startTrack:(NSUInteger)trackNum{
	if(!self.streamer){}
	else if(trackNum == self.trackNum && [self.streamer isPlaying]){
		return;
	}
	else if([self.streamer isWaiting]){
		return;
	}
	
	if(trackNum >= [self.playlist count]){
		[self.delegate player:self needToUpdatePlaylist:self.playlist];
		return;
	}
	
	self.trackNum = trackNum;
	
	[self stop];
	[self start];
}
- (void)pause{
	if(self.streamer){
		[self.streamer pause];
        
	}
    if (debugmode == YES) {
        NSLog(@"Player pause");
    }
}
- (void)startOrPause{
	if(!self.streamer || [self.streamer isPaused] || [self.streamer isIdle]){
		[self start];
	}
	else if([self.streamer isPlaying]) {
		[self pause];
	}
}
- (void)stop{
	if(self.streamer){
		[self.streamer stop];
		[self destroyStreamer];
	}
    if (debugmode == YES) {
        NSLog(@"Player stop");
    }
}
- (void)next{
    //[self stop];
	[self startTrack:self.trackNum + 1];
}
- (void)previous{
    
//	if(self.streamer){
//		[self.streamer seekToTime:0];
//	}
//	else {
//		[self startTrack:self.trackNum - 1];
//	}
    
    if (self.trackNum == 0) {
        [self.streamer seekToTime:0];
        
    }else{
        [self startTrack:self.trackNum - 1];
    }
}
- (void)seektotime:(double)time{
    if (self.streamer.duration){
		double newSeekTime = (time / 100.0) * self.streamer.duration;
        if (debugmode == YES) {
            NSLog(@"SeekTime:%f",newSeekTime);
        }
		[self.streamer seekToTime:newSeekTime];
	}
}



@end
