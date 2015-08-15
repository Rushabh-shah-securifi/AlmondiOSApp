#import <UIKit/UIKit.h>
@class SFIHorizontalValueSelectorView;

@protocol SFIHorizontalValueSelectorViewDelegate <NSObject>

- (void)selector:(SFIHorizontalValueSelectorView *)valueSelector didSelectRowAtIndex:(NSInteger)index;

@end

@protocol SFIHorizontalValueSelectorViewDataSource <NSObject>
- (NSInteger)numberOfRowsInSelector:(SFIHorizontalValueSelectorView *)valueSelector;
- (UIView *)selector:(SFIHorizontalValueSelectorView *)valueSelector viewForRowAtIndex:(NSInteger)index;
- (CGRect)rectForSelectionInSelector:(SFIHorizontalValueSelectorView *)valueSelector;
- (CGFloat)rowHeightInSelector:(SFIHorizontalValueSelectorView *)valueSelector;
- (CGFloat)rowWidthInSelector:(SFIHorizontalValueSelectorView *)valueSelector;
@optional
- (UIView *)selector:(SFIHorizontalValueSelectorView *)valueSelector viewForRowAtIndex:(NSInteger)index selected:(BOOL)selected;
@end



@interface SFIHorizontalValueSelectorView : UIView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) IBOutlet NSObject<SFIHorizontalValueSelectorViewDelegate> *delegate;
@property (nonatomic, assign) IBOutlet NSObject<SFIHorizontalValueSelectorViewDataSource> *dataSource;
@property (nonatomic, assign) BOOL shouldBeTransparent;
@property (nonatomic, assign) BOOL horizontalScrolling;
@property (nonatomic, strong) NSString *selectedImageName;
@property (nonatomic, assign) BOOL debugEnabled;
@property (nonatomic, assign) BOOL decelerates;

- (void)selectRowAtIndex:(NSUInteger)index;
- (void)selectRowAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)reloadData;

@end
