//
//  CrawlersViewController.m
//  Qing
//
//  Created by Maka on 15/11/18.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "CrawlersViewController.h"
#import "CrawlersCollectionCell.h"
#import <Masonry.h>
#import "TFHpple.h"
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <ReactiveCocoa.h>
#import "PopShowImageView.h"
#import "CustomWebViewController.h"
#import <FLAnimatedImage.h>
#import "MCDownloadOperation.h"

@interface CrawlersViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView* collectionView;

@property (nonatomic,strong) NSMutableArray* dataSource;

@property (nonatomic,strong) NSString* startString;

@property (nonatomic,strong) NSString* endString;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) NSOperationQueue* operationQueue;

@end

@implementation CrawlersViewController

-(instancetype)initWithUrlStartString:(NSString *)startString endString:(NSString *)endString
{
    if (self = [super init]) {
        self.startString = startString;
        self.endString = endString;
        self.dataSource = [NSMutableArray array];
        self.page = 1;
        self.operationQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}

-(void)refreshDataWithUrl:(NSString*)url
{
    [self.dataSource removeAllObjects];
    NSData *htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    TFHpple *xpathparser = [[TFHpple alloc]initWithHTMLData:htmlData];
    NSArray *array = [xpathparser searchWithXPathQuery:@"//li[@class='t2']"];
    [self.dataSource addObjectsFromArray:array];
}

-(void)appendData
{
    self.page+=1;
    NSString* url = [NSString stringWithFormat:@"%@%ld%@?id=%d",self.startString,(long)self.page,self.endString,arc4random()%1000000];
    NSData *htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    TFHpple *xpathparser = [[TFHpple alloc]initWithHTMLData:htmlData];
    NSArray *array = [xpathparser searchWithXPathQuery:@"//li[@class='t2']"];
    if (array.count == 0) {
        self.page -= 1;
        return;
    }
    [self.dataSource addObjectsFromArray:array];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* url = [NSString stringWithFormat:@"%@%ld%@?id=%d",self.startString,(long)self.page,self.endString,arc4random()%1000000];
    [self refreshDataWithUrl:url];
    
    UICollectionViewFlowLayout* flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flow];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CrawlersCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CrawlersCollectionCell"];
    
    @weakify(self);
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self appendData];
    }];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(loadWebview)];
}

-(void)loadWebview
{
    CustomWebViewController* webView = [[CustomWebViewController alloc]init];
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFHppleElement* element = self.dataSource[indexPath.row];
    TFHppleElement* a = [element firstChildWithClassName:@"tupian"];
    NSString* imgSrc = [[[a firstChild] attributes] objectForKey:@"src"];
    CrawlersCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CrawlersCollectionCell" forIndexPath:indexPath];
    [cell.cImageView sd_setImageWithURL:[NSURL URLWithString:imgSrc]];
    cell.cLabel.text = @"";
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    TFHppleElement* element = self.dataSource[indexPath.row];
    TFHppleElement* a = [element firstChildWithClassName:@"tupian"];
    NSString* imgSrc = [[[a firstChild] attributes] objectForKey:@"src"];
    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imgSrc];
    if (image) {
        [PopShowImageView showPopShowImageViewWithImage:image];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height;
    
    CGFloat width = (screenWidth - 20)/3;
    CGFloat height = width*1.2;
    return CGSizeMake(width, height);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

@end
