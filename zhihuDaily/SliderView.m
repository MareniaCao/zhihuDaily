//
//  ViewController.h
//  zhihuDaily
//
//  Created by Siegrain on 16/3/15.
//  Copyright © 2016年 siegrain.zhihuDaily. All rights reserved.
//

#import "SliderView.h"

@interface SliderView () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UIPageControl* pageControl;

@property (assign, nonatomic) CGSize viewSize;
@property (assign, nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSTimer* timer;

@property (assign, nonatomic) NSUInteger imageCount;
@property (strong, nonatomic) NSMutableArray<UIImageView*>* imageViews;
@end

@implementation SliderView
#pragma mark - Initialization
- (instancetype)init
{
    if (self = [super init]) {
        [self loadImages];
        if ([self.dataSource respondsToSelector:@selector(contentForSliderAtIndex:)])
            [self loadContents];
        [self addSubview:self.scrollView];
        [self bringSubviewToFront:self.pageControl];
        [self startTimer];

        self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    return self;
}

- (void)loadImages
{
    for (int i = 0; i < self.imageCount; i++) {
        UIImageView* imageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(i * self.viewSize.width, 0,
                              self.viewSize.width, self.viewSize.height)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        [self.scrollView addSubview:imageView];
        [self.imageViews addObject:imageView];

        //获取图片
        UIImage* image = [self.dataSource imageForSliderAtIndex:i];
        if (image != nil)
            imageView.image = image;
    }
}
- (void)loadContents
{
    for (int i = 0; i < self.imageCount; i++) {
        NSString* content = [self.dataSource contentForSliderAtIndex:i];
        if (content == nil)
            continue;
    }
}
- (UIPageControl*)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];

        _pageControl.numberOfPages = self.imageCount;
        CGSize pagerSize = [_pageControl sizeForNumberOfPages:self.imageCount];
        _pageControl.bounds = CGRectMake(0, 0, self.viewSize.width, pagerSize.height);
        _pageControl.center = CGPointMake(self.center.x, 130);
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        [_pageControl addTarget:self
                         action:@selector(pageChanged:)
               forControlEvents:UIControlEventValueChanged];

        [self addSubview:_pageControl];
    }
    return _pageControl;
}
- (UIScrollView*)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor redColor];

        [_scrollView
            setContentSize:CGSizeMake(self.viewSize.width * self.imageCount,
                               self.viewSize.height)];
        [_scrollView setPagingEnabled:true];

        UIButton* button = [[UIButton alloc]
            initWithFrame:CGRectMake(0, 0, _scrollView.contentSize.width,
                              _scrollView.contentSize.height)];
        button.titleLabel.text = @"";
        [button addTarget:self
                      action:@selector(sliderClicked)
            forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];

        // 禁止反弹效果，隐藏滚动条
        [_scrollView setBounces:false];
        [_scrollView setShowsVerticalScrollIndicator:false];
        [_scrollView setShowsHorizontalScrollIndicator:false];

        _scrollView.delegate = self;
    }
    return _scrollView;
}
#pragma mark - getters
- (NSUInteger)imageCount
{
    return [self.dataSource numberOfItemsInSliderView];
}

- (CGSize)viewSize
{
    return self.scrollView.bounds.size;
}

- (NSUInteger)pageIndex
{
    return self.scrollView.contentOffset.x / self.viewSize.width;
}
- (NSMutableArray<UIImageView*>*)imageViews
{
    if (_imageViews == nil) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}
#pragma mark - public methods
- (void)setImage:(UIImage*)image atIndex:(NSUInteger)index
{
    UIImageView* imageView = self.imageViews[index];
    if (imageView != nil)
        imageView.image = image;
}
#pragma mark - slider click event
- (void)sliderClicked
{
    if ([self.dataSource respondsToSelector:@selector(touchUpForSliderAtIndex:)])
        [self.dataSource touchUpForSliderAtIndex:self.pageControl.currentPage];
}

#pragma mark - Timer
- (void)startTimer
{
    self.timer =
        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:@selector(intervalTriggered)
                                       userInfo:nil
                                        repeats:true];
}
- (void)intervalTriggered
{
    int pageIndex = (self.pageControl.currentPage + 1) % self.imageCount;
    self.pageControl.currentPage = pageIndex;
    [self pageChanged:self.pageControl];
}

- (void)pageChanged:(UIPageControl*)pageControl
{
    CGFloat offsetX = pageControl.currentPage * self.viewSize.width;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:true];
}

#pragma mark - ScrollView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
{
    //拖拽时停止计时器
    [self.timer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView
                  willDecelerate:(BOOL)decelerate
{
    //拖拽结束重新开始
    [self startTimer];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    self.pageControl.currentPage = self.pageIndex;
}
@end