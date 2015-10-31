//
//  MoeFmAPI.m
//  Moe FM
//
//  Created by Greg Wang on 12-4-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "MoeFmAPI.h"
#import "API.h"

#define settimeout 10.0
typedef enum
{
	MFMAPI_JSON = 0,
	MFMAPI_PLAYLIST, 
	MFMAPI_IMAGE
} MoeFmAPIRequestType;

@interface MoeFmAPI ()
@property (assign, nonatomic, readwrite)BOOL isBusy;

@property (unsafe_unretained, nonatomic) NSObject <MoeFmAPIDelegate> *delegate;
@property (strong, nonatomic) NSString *apiKey;
@property (assign, nonatomic) MoeFmAPIRequestType requestType;
@property (strong, nonatomic) NSURLConnection *theConnection;
@property (strong, nonatomic) NSMutableData *receivedData;

- (BOOL)createConnectionWithURL:(NSURL *)url 
					requestType:(MoeFmAPIRequestType)type
				timeoutInterval:(NSTimeInterval)timeout;

@end


@implementation MoeFmAPI

@synthesize isBusy = _isBusy;
@synthesize allowNetworkAccess = _allowNetworkAccess;

@synthesize delegate = _delegate;
@synthesize apiKey = _apiKey;
@synthesize requestType = _requestType;
@synthesize theConnection = _theConnection;
@synthesize receivedData = _receivedData;

- (MoeFmAPI *) initWithApiKey:(NSString *)apiKey delegate:(NSObject <MoeFmAPIDelegate> *)delegate
{
	self = [super init];
	
	self.apiKey = apiKey;
	self.delegate = delegate;
	
	return self;
}



#pragma mark - NSURLConnection

- (BOOL)createConnectionWithURL:(NSURL *)url 
					requestType:(MoeFmAPIRequestType)type
				timeoutInterval:(NSTimeInterval)timeout
{
	
	self.isBusy = YES;
	// If currently having a connection, abort the new one
	if(self.theConnection){
		return NO;
	}
	
	// Create the request.
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                       timeoutInterval:timeout];
	self.requestType = type;
    
    
    
	// create the connection with the request
	// and start loading the data
	self.theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (self.theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		self.receivedData = [NSMutableData data];
	} else {
		// Inform the user that the connection failed.
		return NO;
	}
	return YES;
}

- (void)cancelConnection
{
	if(self.theConnection){
		[self.theConnection cancel];
		self.theConnection = nil;
		self.receivedData = nil;
		self.isBusy = NO;
	}
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // receivedData is declared as a method instance elsewhere
	self.theConnection = nil;
    self.receivedData = nil;
	
	self.isBusy = NO;
	
    if (debugmode == YES) {
        // inform the user
        NSLog(@"Connection failed! Error - %@ %@",
              [error localizedDescription],
              [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    }
	
	if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
		[self.delegate api:self requestFailedWithError:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"Succeeded! Received %ld bytes of data",[self.receivedData length]);
	
	if(self.requestType == MFMAPI_PLAYLIST){
		NSError* error;
        
		NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:self.receivedData]
                                                             options:kNilOptions
                                                               error:&error];
        if (debugmode == YES) {
            NSLog(@"%@",json);
        }
        
		if(json == nil){
			// TODO
            NSLog(@"Json data is nil");if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
                [self.delegate api:self requestFailedWithError:error];
            }
		}
		
		NSDictionary * response = [json objectForKey:@"response"];
		if(response == nil){
			// TODO
			NSLog(@"Response data is nil");
            if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
                [self.delegate api:self requestFailedWithError:error];
            }
		}
		
		NSArray* playlist = [response objectForKey:@"playlist"];
		if(playlist == nil){
			// TODO
			NSLog(@"Playlist data is nil");
            if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
                [self.delegate api:self requestFailedWithError:error];
            }
		}
		
		if([self.delegate respondsToSelector:@selector(api:readyWithPlaylist:)]){
			[self.delegate api:self readyWithPlaylist:playlist];
		}
	}
	else if(self.requestType == MFMAPI_IMAGE){
        
		UIImage *image = [[UIImage alloc] initWithData:self.receivedData];
		if([self.delegate respondsToSelector:@selector(api:readyWithImage:)]){
			[self.delegate api:self readyWithImage:image];
		}
	}
    else if (self.requestType == MFMAPI_JSON){
        NSError* error;
        
		NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:self.receivedData]
                                                             options:kNilOptions
                                                               error:&error];
        if (debugmode == YES) {
            NSLog(@"%@",json);
        }
        
		if(json == nil){
			// TODO
			NSLog(@"Json data is nil");
            if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
                [self.delegate api:self requestFailedWithError:error];
            }
		}
		
		NSDictionary * response = [json objectForKey:@"response"];
		if(response == nil){
			// TODO
			NSLog(@"Response data is nil");
            if([self.delegate respondsToSelector:@selector(api:requestFailedWithError:)]){
                [self.delegate api:self requestFailedWithError:error];
            }
		}
        if([self.delegate respondsToSelector:@selector(api:readyWithJson:)]){
			[self.delegate api:self readyWithJson:response];
		}

    }
	
	
    // release the connection, and the data object
    self.theConnection = nil;
    self.receivedData = nil;
	
	self.isBusy = NO;
}

# pragma mark - public methods

- (BOOL)requestJsonWithURL:(NSString *)urlstr
{
    urlstr = [urlstr stringByAppendingFormat:@"&api_key=%@",self.apiKey];
    
	NSURL *url = [NSURL URLWithString:urlstr];
    if (debugmode == YES) {
        NSLog(@"url:%@",url);
    }
    
	return [self createConnectionWithURL:url
							 requestType:MFMAPI_JSON
						 timeoutInterval:settimeout];
}

- (BOOL)requestImageWithURL:(NSURL *)url
{
    //[self cancelConnection];
	return [self createConnectionWithURL:url 
							 requestType:MFMAPI_IMAGE
						 timeoutInterval:settimeout];
}

- (BOOL)requestListenPlaylistWithPage:(NSInteger)page
{
    NSURL *url = [NSURL URLWithString:[playlisturl
                                       stringByAppendingFormat:@"&page=%ld&api_key=%@", page, self.apiKey]];
    
    return [self createConnectionWithURL:url
                             requestType:MFMAPI_PLAYLIST
                         timeoutInterval:10.0];
}
- (BOOL)requestListenPlaylistWithURL:(NSString*)urlstr
{
//    urlstr = [@playlisturl
//                        stringByAppendingFormat:@"&page=%ld&api_key=%@&fav=song", page, self.apiKey];
    urlstr = [urlstr stringByAppendingFormat:@"&api_key=%@",self.apiKey];
    
	NSURL *url = [NSURL URLWithString:urlstr];
    if (debugmode == YES) {
        NSLog(@"url:%@",url);
    }
    
	
    return [self createConnectionWithURL:url 
							 requestType:MFMAPI_PLAYLIST 
						 timeoutInterval:settimeout];
}


- (void)cancelRequest
{
	//if(self.theConnection == nil){
    [self.theConnection cancel];
    self.theConnection = nil;
	//}
    
}





@end
