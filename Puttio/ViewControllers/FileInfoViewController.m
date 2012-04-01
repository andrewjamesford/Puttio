//
//  FileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MoviePlayer.h"

@interface FileInfoViewController() {
    id _item;
    NSString *streamPath;
    BOOL stopRefreshing;
}
@end


@implementation FileInfoViewController 
@synthesize titleLabel;
@synthesize additionalInfoLabel;
@synthesize streamButton;
@synthesize thumbnailImageView;
@synthesize progressView;
@dynamic item;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    streamButton.enabled = NO;
}

- (void)setItem:(id)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }
    NSObject <ORDisplayItemProtocol> *object = item;
    titleLabel.text = object.name;
    _item = item;
    additionalInfoLabel.text = object.description;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[object.iconURL stringByReplacingOccurrencesOfString:@"shot/" withString:@"shot/b/"]]];
    NSLog(@"file contentType %@", object.contentType);
    if ([object.contentType isEqualToString:@"video/mp4"]) {
        [[PutIOClient sharedClient] getInfoForFile:_item :^(id userInfoObject) {
            if (![userInfoObject isMemberOfClass:[NSError class]]) {
                NSLog(@"json %@", userInfoObject);
            }
        }];
    }else{
    }
    [self getMP4Info];        
}

- (void)getMP4Info {
    [[PutIOClient sharedClient] getMP4InfoForFile:_item :^(id userInfoObject) {
        NSLog(@"response %@", userInfoObject);
        
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            streamPath = [userInfoObject valueForKeyPath:@"mp4.stream_url"];
            if (streamPath) {
                streamButton.enabled = YES;
            }else{
                NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
                if ([status isEqualToString:@"NotAvailable"]) {
                    additionalInfoLabel.text = @"Not streamable Yet";
                    [[PutIOClient sharedClient] requestMP4ForFile:_item];
                }
                if ([status isEqualToString:@"CONVERTING"]) {
                    additionalInfoLabel.text = @"Converting to MP4";
                    progressView.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                }
                if (!stopRefreshing) {
                    [self performSelector:@selector(getInfo) withObject:self afterDelay:1];                    
                }
            }
        }
    }];
}

- (id)item {
    return _item;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setThumbnailImageView:nil];
    [self setAdditionalInfoLabel:nil];
    [self setStreamButton:nil];
    [self setProgressView:nil];
    stopRefreshing = YES;
    [super viewDidUnload];
}

- (IBAction)backButton:(id)sender {
    
}

- (IBAction)streamButton:(id)sender {
    if (streamPath) {
        [MoviePlayer streamMovieAtPath:streamPath];
    }
}
@end
