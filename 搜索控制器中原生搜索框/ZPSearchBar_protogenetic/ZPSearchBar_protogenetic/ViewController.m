//
//  ViewController.m
//  ZPSearchBar_protogenetic
//
//  Created by 赵鹏 on 2018/10/18.
//  Copyright © 2018 赵鹏. All rights reserved.
//

/**
 苹果在iOS8之后推出了新的搜索控件，即搜索控制器(UISearchController)，这个新的控件自带搜索框(UISearchBar)；
 
 搜索部分一般分为三个页面：原始数据呈现页、搜索页（点击搜索框之后键入搜索内容之前的页面）、搜索结果呈现页（在搜索框键入搜索内容以后的页面），上述的三个页面所对应的视图控制器可以分为以下的几种情况：
 1、原始数据呈现页、搜索页、搜索结果呈现页共同对应一个视图控制器（本Demo）；
 2、原始数据呈现页对应一个视图控制器，搜索页和搜索结果呈现页共同对应另外一个视图控制器（美团APP在首页中点击“美食”按钮后）；
 3、原始数据呈现、搜索页、搜索结果呈现页这三个页面分别对应三个不同的视图控制器。
 上述的1、2两种情况中只要是搜索页和搜索结果呈现页共同对应同一个视图控制器的话则在这个共同对应的视图控制器类中调用initWithSearchResultsController:方法创建UISearchController控件的时候后面的参数传入nil即可。上述的第3种情况中搜索页和搜索结果呈现页分别对应不同的视图控制器的话则在搜索页对应的那个视图控制器类中调用initWithSearchResultsController:方法创建UISearchController控件的时候后面的参数传入搜索结果呈现页所对应的那个视图控制器对象即可。
 
 这个Demo是按照"https://www.jianshu.com/p/aa9a153a5b58"和"https://www.jianshu.com/p/7e49a1c656e7"上面的内容来撰写的。
 */
#import "ViewController.h"
#import "Model.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *modelsMulArray;  //存储原始对象的可变数组
@property (nonatomic, strong) NSMutableArray *resultsMulArray;  //存储搜索结果的可变数组
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;  //搜索控制器

@end

@implementation ViewController

#pragma mark ————— 懒加载 —————
- (NSMutableArray *)modelsMulArray
{
    if (_modelsMulArray == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"plist"];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *tempMulArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray)
        {
            Model *model = [Model modelWithDict:dict];
            [tempMulArray addObject:model];
        }
        
        _modelsMulArray = tempMulArray;
    }
    
    return _modelsMulArray;
}

- (NSMutableArray *)resultsMulArray
{
    if (_resultsMulArray == nil)
    {
        _resultsMulArray = [NSMutableArray array];
    }
    
    return _resultsMulArray;
}

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //设置tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    /**
     创建UISearchController：
     如果想要让搜索结果显示在当前的视图控制器中的话则方法initWithSearchResultsController:后面的参数应传nil，如果想要让搜索结果显示在其他视图控制器上的话则方法后面的参数应传入相应的视图控制器的对象。
     */
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;  //当搜索框激活时是否添加一个透明的视图
    self.searchController.hidesNavigationBarDuringPresentation = NO;  //当搜索框激活时不隐藏导航栏
    self.searchController.searchResultsUpdater = self;  //设置搜索结果更新的代理(UISearchResultsUpdating)
    self.searchController.delegate = self;  //设置UISearchController的代理(UISearchControllerDelegate)
    
    //设置搜索框
    self.navigationItem.titleView = self.searchController.searchBar;  //把搜索框设置在导航栏上
//    self.tableView.tableHeaderView = self.searchController.searchBar;  //把搜索框设置为列表的头部
    self.searchController.searchBar.placeholder = @"请输入搜索内容";  //设置搜索框中的文本框的placeholder
    self.searchController.searchBar.delegate = self;  //设置UISearchBar的代理(UISearchBarDelegate)
}

#pragma mark ————— UITableViewDataSource —————
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    /**
     通过active属性的BOOL值来判断用户是否已经点击了搜索框。
     */
    if (self.searchController.active == YES && self.searchController.searchBar.text.length == 0)  //用户点击了搜索框并且还没有在搜索框中键入文本内容的时候
    {
        count = 0;
    }else if (self.searchController.active == YES && self.searchController.searchBar.text.length != 0)  //用户点击了搜索框并且已经在搜索框中键入了文本内容的时候
    {
        count = self.resultsMulArray.count;
    }else if (self.searchController.active == NO)  //用户没有点击搜索框的时候
    {
        count = self.modelsMulArray.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    if (self.searchController.active == YES && self.searchController.searchBar.text.length == 0)  //用户点击了搜索框并且还没有在搜索框中键入文本内容的时候
    {
        cell = nil;
    }else if (self.searchController.active == YES && self.searchController.searchBar.text.length != 0)  //用户点击了搜索框并且已经在搜索框中键入了文本内容的时候
    {
        Model *resultModel = [self.resultsMulArray objectAtIndex:indexPath.row];
        cell.textLabel.text = resultModel.name;
    }else if (self.searchController.active == NO)  //用户没有点击搜索框的时候
    {
        Model *model = [self.modelsMulArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.name;
    }
    
    return cell;
}

#pragma mark ————— UITableViewDelegate —————
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active == YES && self.searchController.searchBar.text.length == 0)  //用户点击了搜索框并且还没有在搜索框中键入文本内容的时候
    {
        return;
    }else if(self.searchController.active == YES && self.searchController.searchBar.text.length != 0)  //用户点击了搜索框并且已经在搜索框中键入了文本内容的时候
    {
        Model *resultModel = [self.resultsMulArray objectAtIndex:indexPath.row];
        NSLog(@"您点击了搜索结果中的%@", resultModel.name);
    }else if (self.searchController.active == NO)  //用户没有点击搜索框的时候
    {
        Model *model = [self.modelsMulArray objectAtIndex:indexPath.row];
        NSLog(@"您点击了原始数据中的%@", model.name);
    }
}

#pragma mark ————— UISearchResultsUpdating —————
/**
 用户在搜索框中输入一次内容，系统就会自动调用一次这个代理方法；
 在实际项目中，用户在搜索框输入内容后就会与后台进行交互，向后台发起请求并解析后台返回的数据，然后把数据显示在搜索结果呈现页面上。
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *inputStr = searchController.searchBar.text;
    NSLog(@"搜索框输入的文字为：%@", inputStr);
    
    if (self.resultsMulArray.count > 0)
    {
        [self.resultsMulArray removeAllObjects];
    }
    
    //假定跟后台交互后获取到的搜索结果是原始对象数组里面的前三个
    NSArray *modelsArray = (NSArray *)self.modelsMulArray;
    NSArray *resultsArray = [modelsArray subarrayWithRange:NSMakeRange(0, 3)];
    self.resultsMulArray = [resultsArray mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark ————— UISearchControllerDelegate —————
-(void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __func__);
}

-(void)willPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __func__);
}

-(void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __func__);
}

-(void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __func__);
}

-(void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%s", __func__);
}

#pragma mark ————— UISearchBarDelegate —————
//将要开始编辑搜索框中的文本内容的时候会调用这个方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"将要开始编辑搜索框中的文本内容了");
    
    return YES;
}

//已经开始编辑搜索框中的文本内容的时候会调用这个方法
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"已经开始编辑搜索框中的文本内容了");
}

//将要结束编辑搜索框中的文本内容的时候会调用这个方法
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"将要结束编辑搜索框中的文本内容了");
    
    return YES;
}

//已经结束编辑搜索框中的文本内容的时候会调用这个方法
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"已经结束编辑搜索框中的文本内容了");
}

//搜索框中的文本内容改变的时候会调用这个方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"搜索框中的文本内容改变了");
}

//搜索框中的文本内容改变前会调用这个方法，如果返回NO的话则不能为文本添加新的内容
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"搜索框中的文本内容改变前会调用这个方法");
    
    return YES;
}

//用户点击键盘上的“搜索”按钮时会调用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"用户点击了键盘上的“搜索”按钮");
}

//用户点击搜索框中右侧的图书按钮时会调用这个方法
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"用户点击了搜索框中右侧的图书按钮");
}

//用户点击取消按钮的时候会调用这个方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"用户点击了取消按钮");
}

//用户点击搜索框中右侧的搜索结果列表按钮时会调用这个方法
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"用户点击了搜索框中右侧的搜索结果列表按钮");
}

//用户点击搜索框的附属按钮视图中的切换按钮时会调用这个方法
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSLog(@"用户点击了搜索框的附属按钮视图中的切换按钮");
}

@end
