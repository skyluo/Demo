//
//  SKYTableViewCell.m
//  Demo
//
//  Created by sky on 16/5/23.
//  Copyright © 2016年 sky luo. All rights reserved.
//

#import "SKYTableViewCell.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kAafterDelay 0.25

@interface SKYTableViewCell() <UIScrollViewDelegate>{
    
    UIButton *_deleteBtn;
    UIButton *_cancleBtn;
    
    UIButton *_preButton;
    UIButton *_lastButton;
    UIButton *_tapButton;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, weak) UITableView *containingTableView;

@end

@implementation SKYTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
                
        UIButton *cancleTmpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        cancleTmpBtn.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:cancleTmpBtn];
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-74, 0, 74, self.frame.size.height)];
        deleteBtn.backgroundColor = [UIColor redColor];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:deleteBtn];
        _deleteBtn= deleteBtn;
        
        UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-174, 0, 100, self.frame.size.height)];
        cancleBtn.backgroundColor = [UIColor grayColor];
        [cancleBtn setTitle:@"标记未读" forState:UIControlStateNormal];
        [cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:cancleBtn];
        _cancleBtn = cancleBtn;
        
        _deleteBtn.userInteractionEnabled = NO;
        _cancleBtn.userInteractionEnabled = NO;
        
        CGRect frame = CGRectMake(0, 0, kScreenWidth, self.frame.size.height);
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.scrollEnabled = YES;
        [self.contentView addSubview:self.scrollView];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.frame.size.height)];
        contentView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:contentView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth-20, self.frame.size.height)];
        label.text = @"test";
        [self.scrollView addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1/3.0, kScreenWidth, 1/3.0)];
        lineView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:lineView];
        
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) + 174, CGRectGetHeight(frame));
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCell)];
        tap.cancelsTouchesInView = NO;
        [self.scrollView addGestureRecognizer:tap];
    }
    
    return self;
}

#pragma mark - UITableViewCell overrides

- (void)didMoveToSuperview
{
    self.containingTableView = nil;
    UIView *view = self.superview;
    
    do {
        if ([view isKindOfClass:[UITableView class]])
        {
            self.containingTableView = (UITableView *)view;
            break;
        }
    } while ((view = view.superview));
}

#pragma mark - Event

- (void)selectCell {

    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    
    if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        cellIndexPath = [self.containingTableView.delegate tableView:self.containingTableView willSelectRowAtIndexPath:cellIndexPath];
    }
    
    if (cellIndexPath) {
        [self.containingTableView selectRowAtIndexPath:cellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if ([self.containingTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.containingTableView.delegate tableView:self.containingTableView didSelectRowAtIndexPath:cellIndexPath];
        }
    }
}

- (void)deleteAction {
    
    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    NSLog(@"删除 %ld", (long)cellIndexPath.row);
    
    [self cancleCellSelect];
}

- (void)cancleAction {
    
    NSIndexPath *cellIndexPath = [self.containingTableView indexPathForCell:self];
    NSLog(@"标记未读 %ld", (long)cellIndexPath.row);
    
    [self cancleCellSelect];
}

- (void)cancleCellSelect {
    
    if (_deleteBtn.userInteractionEnabled == NO) {
        return;
    }
    
    _deleteBtn.userInteractionEnabled = NO;
    _cancleBtn.userInteractionEnabled = NO;
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [self performSelector:@selector(cellScrollViewEnabled) withObject:nil afterDelay:kAafterDelay];
}

- (void)cellScrollViewEnabled {
    
    self.containingTableView.scrollEnabled = YES;
    
    _deleteBtn.userInteractionEnabled = YES;
    _cancleBtn.userInteractionEnabled = YES;
    
    self.scrollView.userInteractionEnabled = YES;
    
    if (_preButton) {
        [_preButton removeFromSuperview];
        _preButton = nil;
    }
    if (_lastButton) {
        [_lastButton removeFromSuperview];
        _lastButton = nil;
    }
    if (_tapButton) {
        [_tapButton removeFromSuperview];
        _tapButton = nil;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (targetContentOffset->x > 100) {
        [scrollView setContentOffset:CGPointMake(174, 0) animated:YES];
        self.scrollView.userInteractionEnabled = NO;
        _deleteBtn.userInteractionEnabled = YES;
        _cancleBtn.userInteractionEnabled = YES;
        
        if (_preButton) {
            [_preButton removeFromSuperview];
            _preButton = nil;
        }
        if (_lastButton) {
            [_lastButton removeFromSuperview];
            _lastButton = nil;
        }
        if (_tapButton) {
            [_tapButton removeFromSuperview];
            _tapButton = nil;
        }
        
        self.containingTableView.scrollEnabled = NO;
        
        UITableView *tableView = self.containingTableView;
        if (self.frame.origin.y != 0) {
            _preButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.origin.y)];
            [tableView addSubview:_preButton];
            _preButton.backgroundColor = [UIColor clearColor];
            [_preButton addTarget:self action:@selector(cancleCellSelect) forControlEvents:UIControlEventTouchDown];
        }
        if (tableView.contentSize.height > self.frame.origin.y + self.frame.size.height) {
            
            _lastButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                    self.frame.origin.y + self.frame.size.height,
                                                                    self.frame.size.width,
                                                                    tableView.contentSize.height-(self.frame.origin.y+self.frame.size.height))];
            [tableView addSubview:_lastButton];
            _lastButton.backgroundColor = [UIColor clearColor];
            [_lastButton addTarget:self action:@selector(cancleCellSelect) forControlEvents:UIControlEventTouchDown];
        }
        
        _tapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width - 174, self.frame.size.height)];
        [tableView addSubview:_tapButton];
        _tapButton.backgroundColor = [UIColor clearColor];
        [_tapButton addTarget:self action:@selector(cancleCellSelect) forControlEvents:UIControlEventTouchDown];
        
    } else {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

@end
