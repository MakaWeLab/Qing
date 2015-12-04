//
//  PK10GamePlayer.m
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10GamePlayer.h"
#import <ReactiveCocoa.h>
#import "PK10GamePlayerItem.h"
#import "PK10GamePlayerScence1.h"
#import <Masonry.h>

@interface PK10GamePlayer ()

@property (nonatomic,strong) NSMutableArray* players;

@property (nonatomic,strong) dispatch_source_t timer;

@property (nonatomic,strong) dispatch_queue_t queue;

@property (nonatomic,strong) PK10GamePlayerScence1* scence1;

@property (nonatomic,assign) BOOL isPlaying;

@end

@implementation PK10GamePlayer

-(instancetype)initWithLine:(NSInteger)line
{
    if (self = [super init]) {
        self.line = line;
        self.scence1 = [[PK10GamePlayerScence1 alloc]initWithRoad:line];
        [self addSubview:self.scence1];
        [self.scence1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.bounds = CGRectMake(0, 0, LINE_WIDTH, LINE_HEIGHT*line);
        self.players = [NSMutableArray array];
        self.clipsToBounds = YES;
        for (NSInteger i = 0; i<line; i++) {
            PK10GamePlayerItem* item = [PK10GamePlayerItem instanceFromNib];
            [self addSubview:item];
            item.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"red_%ld",i+1]];
            item.bounds = CGRectMake(0,0, LINE_HEIGHT - 2, LINE_HEIGHT-2);
            item.center = CGPointMake(LINE_WIDTH - LINE_HEIGHT, i*LINE_HEIGHT + LINE_HEIGHT/2);
            [self.players addObject:item];
        }
    }
    return self;
}

-(void)begin
{
    self.isPlaying = YES;
    @weakify(self);
    __block int timeout=0; //倒计时时间
    timeout = self.leftTime*20;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.queue = queue;
    self.timer= dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),.05*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout==0){ //倒计时结束，关闭
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                @strongify(self);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                @strongify(self);
                [self roadEngine];
                [self appendDistance];
            });
            timeout-=1;
        }
    });
    dispatch_resume(_timer);
}

-(void)roadEngine
{
    for (PK10GamePlayerItem* item in self.players) {
        CGRect frame = item.frame;
        frame.origin.x += 2 - item.speed;
        
        if (!self.isPlaying) {
            if (frame.origin.x < item.finishX && item.speed >= 2) {
                NSInteger scale = ((item.finishX - frame.origin.x )/2)/20;
                item.speed = 2 - scale;
            }else if (frame.origin.x >item.finishX && item.speed <= 2) {
                NSInteger scale = ((frame.origin.x - item.finishX)/2)/20;
                item.speed = 2 + scale;
            }
            if (ABS(frame.origin.x - item.finishX) < 1) {
                frame.origin.x = item.finishX;
                item.speed = 2;
            }
        }else {
            if (frame.origin.x < 50) {
                frame.origin.x = 50;
                item.speed = -2;
            }
            if (frame.origin.x > LINE_WIDTH - LINE_HEIGHT) {
                frame.origin.x = LINE_WIDTH - LINE_HEIGHT;
                item.speed = 4;
            }
        }
        item.frame = frame;
    }
}

-(void)appendDistance
{
    
    [self randomAppend];
}

-(void)getSuperStar
{
    
}

static NSInteger lock = 90;
-(void)randomAppend
{
    if (!self.isPlaying) {
        return;
    }
    lock++;
    if (lock<90) {
        return;
    }
    lock = 0;
    for (PK10GamePlayerItem* item in self.players) {
        if (item.speed > 4 ) {
            static BOOL innerLock = YES;
            innerLock = !innerLock;
            if (innerLock) {
                item.speed += 1;
                continue;
            }
        }
        NSInteger distance = abs(((int)arc4random())%100);
        item.speed = distance/40.0 - .5;
        if (distance%3==0) {
            item.speed += 2;
        }
        if (distance%5 == 0) {
            item.speed -= 2;
        }
    }
}

-(void)stopPlayWithResult:(NSArray*)result
{
    self.isPlaying = NO;
    NSInteger rank = 0;
    for (NSString* string in result) {
        NSInteger index =[string integerValue] -1;
        PK10GamePlayerItem* item = self.players[index];
        item.finishX = rank*LINE_HEIGHT*1.1 + LINE_WIDTH - self.line* LINE_HEIGHT*1.1;
        rank++;
    }
}

@end
