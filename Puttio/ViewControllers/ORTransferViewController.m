//
//  ORTransferViewController.m
//  Puttio
//
//  Created by orta therox on 14/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORTransferViewController.h"
#import "ORExtendedTransferCell.h"

@interface ORTransferViewController (){
    NSArray *_transfers;
    NSTimer *_dataLoopTimer;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ORTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startTimer];
    [self setupGestures];
}

- (void)setupGestures {
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backSwipeRecognised:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognised:)];
    [self.view addGestureRecognizer:pinchGesture];
}

- (void)pinchGestureRecognised:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)backSwipeRecognised:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_dataLoopTimer invalidate];
}

- (void)startTimer {
    if (!_dataLoopTimer) {
        _dataLoopTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(beat) userInfo:nil repeats:YES];
        [_dataLoopTimer fire];
    }
}

- (void)beat {
    [self getTransfers];
}

- (void)getTransfers {
//    if (_transfers) return;
//    _transfers = [self stubbedTransfers];
    [self.tableView reloadData];

    // TODO: this
    [[PutIOClient sharedClient] getTransfers:^(NSArray *transfers) {
        _transfers = transfers;
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        NSLog(@"error %@", [error localizedDescription]);
    }];
}

- (NSArray *)stubbedTransfers {
    NSMutableArray *stubbies = [NSMutableArray array];
    for (int i = 0; i < 15; i++) {
        Transfer *transfer = [[Transfer alloc] init];
        transfer.name = [NSString stringWithFormat:@"Stub %i", i];
        transfer.percentDone = @( arc4random() % 100 );
        transfer.downSpeed = @( arc4random() % 100 );
        transfer.estimatedTime = @( arc4random() % 100 );
        transfer.displayName = transfer.name;
        
        [stubbies addObject:transfer];
    }
    return stubbies;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transfers.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = nil;
    cell = [aTableView dequeueReusableCellWithIdentifier:@"ExtendedTransferCell"];
    if (cell) {
        Transfer *item = _transfers[indexPath.row];
        ORExtendedTransferCell *theCell = (ORExtendedTransferCell *)cell;
        theCell.transfer = item;
    }
    return cell;
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end