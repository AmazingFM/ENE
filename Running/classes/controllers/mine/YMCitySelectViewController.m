//
//  YMCitySelectViewController.m
//  Running
//
//  Created by 张永明 on 16/10/2.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCitySelectViewController.h"

#import "YMCity.h"

@interface YMCitySelectViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_mainTableView;
    
    NSString *cityLevel;
    
    UIActivityIndicatorView *indicator;
}

@property (nonatomic,retain) NSMutableArray<YMCity *> *dataArr;
@end

@implementation YMCitySelectViewController

- (NSMutableArray<YMCity *> *)dataArr
{
    if (_dataArr==nil) {
        _dataArr = [NSMutableArray<YMCity *> new];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cityLevel = @"1";
    
    self.navigationItem.title = @"选择城市";
    self.view.backgroundColor = rgba(247, 247, 247, 1.0);
    
    self.navigationItem.rightBarButtonItem = createBarItemTitle(@"取消",self, @selector(dismiss));
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:indicator];

    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(kYMBorderMargin, kYMTopBarHeight, g_screenWidth-2*kYMBorderMargin, g_screenHeight-kYMTopBarHeight) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _mainTableView.separatorColor = [UIColor lightGrayColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.scrollEnabled = YES;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    
    _mainTableView.tableFooterView = [[UIView alloc] init];
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_mainTableView];
    
    [self getProvinceList];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if ([cityLevel intValue]==1) {
        cell.textLabel.text = self.dataArr[indexPath.row].province;
    } else if ([cityLevel intValue]==2) {
        cell.textLabel.text = self.dataArr[indexPath.row].city;
    }else  if ([cityLevel intValue]==3) {
        cell.textLabel.text = self.dataArr[indexPath.row].town;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMCity *cityItem = self.dataArr[indexPath.row];
    
    if ([cityLevel intValue]==1) {
        [self getCityList:cityItem.province_code];
    } else if ([cityLevel intValue]==2) {
        [self getTownList:cityItem.city_code];
    }else  if ([cityLevel intValue]==3) {
        if ([self.delegate respondsToSelector:@selector(didSelectCity:)]) {
            [self.delegate didSelectCity:cityItem];
            [self dismiss];
        }
    }
}

#pragma mark 网络请求
- (void)getProvinceList
{
    [self getParameters];
    
    self.params[@"level"]=cityLevel;
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=CityQuery"] parameters:self.params success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                
                int nCount = [dataDict[@"total_count"] intValue];
                if (nCount>0) {
                    NSArray<YMCity *> *cityArr = [YMCity objectArrayWithKeyValuesArray:dataDict[@"city_list"]];
                    [self.dataArr removeAllObjects];
                    [self.dataArr addObjectsFromArray:cityArr];
                    [_mainTableView reloadData];
                }
            } else {
                //
            }
        }
    } failure:^(NSError *error) {
        //
    }];

}
- (void)getCityList:(NSString *)cityCode
{
    [self getParameters];
    
    self.params[@"level"] = @"2";
    self.params[@"province_code"] = cityCode;
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=CityQuery"] parameters:self.params success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                
                int nCount = [dataDict[@"total_count"] intValue];
                if (nCount>0) {
                    cityLevel = @"2";
                    NSArray<YMCity *> *cityArr = [YMCity objectArrayWithKeyValuesArray:dataDict[@"city_list"]];
                    [self.dataArr removeAllObjects];
                    [self.dataArr addObjectsFromArray:cityArr];
                    [_mainTableView reloadData];
                }
            } else {
                //
            }
        }
    } failure:^(NSError *error) {
        //
    }];
    
}

- (void)getTownList:(NSString *)townCode
{
    [self getParameters];

    self.params[@"level"] = @"3";
    self.params[@"city_code"] = townCode;
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=CityQuery"] parameters:self.params success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                
                int nCount = [dataDict[@"total_count"] intValue];
                if (nCount>0) {
                    cityLevel = @"3";
                    NSArray<YMCity *> *cityArr = [YMCity objectArrayWithKeyValuesArray:dataDict[@"city_list"]];
                    [self.dataArr removeAllObjects];
                    [self.dataArr addObjectsFromArray:cityArr];
                    [_mainTableView reloadData];
                }
            } else {
                //
            }
        }
    } failure:^(NSError *error) {
        //
    }];
    
}

@end
