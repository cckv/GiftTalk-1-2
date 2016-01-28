//
//  KVEssionViewController.m
//  GiftTalk
//
//  Created by kv on 16/1/10.
//  Copyright © 2016年 kv. All rights reserved.
//

#import "KVEssionViewController.h"
#import "KVHeaderItem.h"
#import "KVHtmlViewController.h"
#import "KVHomeCellItem.h"
#import "KVHomeCell.h"
#import "NSDictionary+PropertyCode.h"
@interface KVEssionViewController ()
// 数据模型
@property (nonatomic,strong) NSArray *headerDataArr;
@property (nonatomic,strong) NSArray *cellDataArr;
// view
@property (nonatomic,weak) UIView *headerView;
@property (nonatomic,weak) UIScrollView *scrollView1;
@property (nonatomic,weak) UIScrollView *scrollView2;


// 轮播器图片的个数
@property (nonatomic,assign) NSInteger count;

@end

@implementation KVEssionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];

    // 获取网络数据
    [self getData1];
    
    [KVHeaderItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
    [KVHomeCellItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
    [KVHomeCellItem mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"Template":@"template"};
    }];
    // 每一个 cell 的数据
    [self getData2];
    
    // 设置头部的图片轮播器
//    [self setHeaderView];
}
- (void)setHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    _headerView = headerView;
    
    // 创建轮播器1
    UIScrollView *scrollView1 = [[UIScrollView alloc]init];
    _scrollView1 = scrollView1;
    scrollView1.pagingEnabled = YES;

    scrollView1.contentSize = CGSizeMake(self.count * GTScreenWidth,0);
    scrollView1.frame = CGRectMake(0, 0, GTScreenWidth, 120);
    [headerView addSubview:scrollView1];
    // 1.添加按钮
    for (int i = 0; i < self.count; i++) {
        UIImageView *imgaeV = [[UIImageView alloc]init];
        [scrollView1 addSubview:imgaeV];
        imgaeV.tag = i;
        imgaeV.userInteractionEnabled = YES;
        imgaeV.frame = CGRectMake(GTScreenWidth*i, 0, GTScreenWidth, scrollView1.height);
        // 给图片添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageBtnClick:)];
        [imgaeV addGestureRecognizer:tap];
    }
    
    // 创建轮播器2
    UIScrollView *scrollView2 = [[UIScrollView alloc]init];
    _scrollView2 = scrollView2;
    scrollView2.showsHorizontalScrollIndicator = NO;
    CGFloat scrollconW = 70 * 6 + 10;
    scrollView2.frame = CGRectMake(0, 120, scrollconW, 80);
    [headerView addSubview:scrollView2];
    scrollView2.contentSize = CGSizeMake(480, 0);

    // 1. 添加按钮
    CGFloat btnW = 60;
    for (int i = 0; i < 6; i++) {
        UIButton *btn = [[UIButton alloc]init];
        [scrollView2 addSubview:btn];
        NSString *imageName = [NSString stringWithFormat:@"11%d",i+1];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.frame = CGRectMake(KVMargin+(KVMargin + btnW) * i, KVMargin, btnW, btnW);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.tableView.tableHeaderView = headerView;
}
- (void)getData1
{
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    NSString *urlStr = @"http://api.liwushuo.com/v2/banners?channel=iOS";

    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        
        [responseObject writeToFile:@"/Users/kv/Desktop/123.plist" atomically:YES];
        NSDictionary *data = responseObject[@"data"];
        
        NSArray *banners = data[@"banners"];
        
        _headerDataArr = [KVHeaderItem mj_objectArrayWithKeyValuesArray:banners];
        
        _count = _headerDataArr.count;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 设置头部的图片轮播器
            [self setHeaderView];
            
//            NSInvocationOperation
            
            [self setImage];
            
        });
        
        
        [SVProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}
- (void)getData2
{
    
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    NSString *urlStr = @"http://api.liwushuo.com/v2/channels/106/items?ad=1&gender=1&generation=0&limit=20&offset=0";
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        

        NSDictionary *data = responseObject[@"data"];
        
        NSArray *items = data[@"items"];
        
        _cellDataArr = [KVHomeCellItem mj_objectArrayWithKeyValuesArray:items];
        
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}
// 轮播器1添加图片
- (void)setImage
{
    for (int i = 0;  i< self.count; i++) {
        KVHeaderItem *item = self.headerDataArr[i];
        UIImageView *imageV = self.scrollView1.subviews[i];
        [imageV sd_setImageWithURL:[NSURL URLWithString:item.image_url]];
    }
}
#pragma mark - 数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellDataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    KVHomeCell *cell = [KVHomeCell createCell];
    KVHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell"];
    
    KVHomeCellItem *item = self.cellDataArr[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KVHtmlViewController *htmlVc = [[KVHtmlViewController alloc]init];
    
    KVHomeCellItem *item = self.cellDataArr[indexPath.row];
    htmlVc.urlStr = item.url;
    htmlVc.title = @"攻略详情";
    
    [self.navigationController pushViewController:htmlVc animated:YES];
}

// 初始化设置
- (void)initView
{
    self.tableView.contentInset = UIEdgeInsetsMake(30, 0, navigationBarH + tabBarH, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([KVHomeCell class]) bundle:nil] forCellReuseIdentifier:@"homeCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}
#pragma mark - 懒加载

#pragma mark - 监听事件
- (void)imageBtnClick:(UITapGestureRecognizer*)tap
{
    UIView *view = tap.view;
    KVHtmlViewController *htmlVc = [[KVHtmlViewController alloc]init];
    KVHeaderItem *item = self.headerDataArr[view.tag];
    htmlVc.urlStr = item.target_url;
    [self.navigationController pushViewController:htmlVc animated:YES];
}
- (void)btnClick:(UIButton*)btn
{
    NSLog(@"%s",__func__);
}
@end