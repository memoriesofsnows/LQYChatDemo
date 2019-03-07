//
//  LQYInputMoreContainerView.m
//  IDoTo
//
//  Created by luoyuan on 2019/2/20.
//  Copyright © 2019年 luoyuan. All rights reserved.
//

#import "LQYInputMoreContainerView.h"
#import "LQYPageView.h"
#import "LQYMoreItem.h"

NSInteger LQYMaxItemCountInPage = 8;
NSInteger LQYButtonItemWidth = 75;
NSInteger LQYButtonItemHeight = 85;
NSInteger LQYPageRowCount     = 2;
NSInteger LQYPageColumnCount  = 4;
NSInteger LQYButtonBegintLeftX = 11;

@interface LQYInputMoreContainerView () <LQYPageViewDataSource>

@property (nonatomic, strong) NSArray<UIButton *> *buttons;
@property (nonatomic, strong) NSArray<LQYMoreItem *> *items;

@property (nonatomic, strong) LQYPageView *pageView;

@end

@implementation LQYInputMoreContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageView = [[LQYPageView alloc] initWithFrame:CGRectZero];
        _pageView.dataSource = self;
        [self addSubview:_pageView];
    }
    return self;
}


- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(size.width, 216.f);
}


- (void)setMoreButtons
{
    NSMutableArray *buttons = [NSMutableArray array];
    _items = @[[LQYMoreItem item:@"onTapMediaItemPicture:" normalImage:[UIImage imageNamed:@"bk_media_picture_normal"] selectedImage:[UIImage imageNamed:@"bk_media_picture_nomal_pressed"] title:@"相册"],
                       [LQYMoreItem item:@"onTapMediaItemShoot:" normalImage:[UIImage imageNamed:@"bk_media_shoot_normal"] selectedImage:[UIImage imageNamed:@"bk_media_shoot_pressed"] title:@"拍摄"],
               [LQYMoreItem item:@"onNothing:" normalImage:nil selectedImage:nil title:nil],
               [LQYMoreItem item:@"onNothing:" normalImage:nil selectedImage:nil title:nil]];
    
    [_items enumerateObjectsUsingBlock:^(LQYMoreItem *item, NSUInteger idx, BOOL *stop) {
        
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = idx;
        [btn setImage:item.normalImage forState:UIControlStateNormal];
        [btn setImage:item.selectedImage forState:UIControlStateHighlighted];
        [btn setTitle:item.title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(76, -75, 0, 0)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [buttons addObject:btn];
        
    }];
    _buttons = buttons;
}

- (void)setFrame:(CGRect)frame {
    CGFloat originalWidth = self.frame.size.width;
    [super setFrame:frame];
    if (originalWidth != frame.size.width)
    {
        self.pageView.frame = self.bounds;
        [self.pageView reloadData];
    }
    
}

- (void)loadDefaultData {
    [self setMoreButtons];
    [self.pageView reloadData];
}

- (void)dealloc
{
    _pageView.dataSource = nil;
}


#pragma mark PageViewDataSource
- (NSInteger)numberOfPages: (LQYPageView *)pageView
{
    NSInteger count = [_buttons count] / LQYMaxItemCountInPage;
    count = ([_buttons count] % LQYMaxItemCountInPage == 0) ? count : count + 1;
    return MAX(count, 1);
}

- (UIView*)mediaPageView:(LQYPageView*)pageView beginItem:(NSInteger)begin endItem:(NSInteger)end
{
    UIView *subView = [[UIView alloc] init];
    NSInteger span = (self.frame.size.width - LQYPageColumnCount * LQYButtonItemWidth) / (LQYPageColumnCount + 1);
    CGFloat startY          = LQYButtonBegintLeftX;
    NSInteger coloumnIndex = 0;
    NSInteger rowIndex = 0;
    NSInteger indexInPage = 0;
    for (NSInteger index = begin; index < end; index ++)
    {
        UIButton *button = [_buttons objectAtIndex:index];
        [button addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        //计算位置
        rowIndex    = indexInPage / LQYPageColumnCount;
        coloumnIndex= indexInPage % LQYPageColumnCount;
        CGFloat x = span + (LQYButtonItemWidth + span) * coloumnIndex;
        CGFloat y = 0.0;
        if (rowIndex > 0)
        {
            y = rowIndex * LQYButtonItemHeight + startY + 15;
        }
        else
        {
            y = rowIndex * LQYButtonItemHeight + startY;
        }
        [button setFrame:CGRectMake(x, y, LQYButtonItemWidth, LQYButtonItemHeight)];
        [subView addSubview:button];
        indexInPage ++;
    }
    return subView;
}

- (UIView*)oneLineMediaInPageView:(LQYPageView *)pageView
                       viewInPage: (NSInteger)index
                            count:(NSInteger)count
{
    UIView *subView = [[UIView alloc] init];
    NSInteger span = (self.frame.size.width - count * LQYButtonItemWidth) / (count + 1);
    
    for (NSInteger btnIndex = 0; btnIndex < count; btnIndex ++)
    {
        UIButton *button = [_buttons objectAtIndex:btnIndex];
        [button addTarget:self action:@selector(onTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        CGRect iconRect = CGRectMake(span + (LQYButtonItemWidth + span) * btnIndex, 58, LQYButtonItemWidth, LQYButtonItemHeight);
        [button setFrame:iconRect];
        [subView addSubview:button];
    }
    return subView;
}

- (UIView *)pageView:(LQYPageView *)pageView viewInPage: (NSInteger)index
{
    if ([_buttons count] == 2 || [_buttons count] == 3) //一行显示2个或者3个
    {
        return [self oneLineMediaInPageView:pageView viewInPage:index count:[_buttons count]];
    }
    
    if (index < 0)
    {
        assert(0);
        index = 0;
    }
    NSInteger begin = index * LQYMaxItemCountInPage;
    NSInteger end = (index + 1) * LQYMaxItemCountInPage;
    if (end > [_buttons count])
    {
        end = [_buttons count];
    }
    return [self mediaPageView:pageView beginItem:begin endItem:end];
}

#pragma mark - button actions
- (void)onTouchButton:(id)sender
{
    NSInteger index = [(UIButton *)sender tag];
    LQYMoreItem *item = _items[index];
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(onTapMoreItem:)]) {
        BOOL handled = [_actionDelegate onTapMoreItem:item];
        if (!handled) {
            NSAssert(0, @"invalid item selector!");
        }
    }
    
}

@end