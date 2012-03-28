//
//  ViewController.m
//  iCoruselTestExample
//
//  Created by Алексей Лобанов on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define NUMBER_OF_ITEMS (IS_IPAD? 19: 12)
#define NUMBER_OF_VISIBLE_ITEMS 10
#define ITEM_SPACING 300.0f
#define INCLUDE_PLACEHOLDERS NO

@interface ViewController () <UIActionSheetDelegate> {
    BOOL scrollEndAnimation;
}

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation ViewController

@synthesize carousel = _carousel;
@synthesize wrap;
@synthesize items;
@synthesize infoBlock = _infoBlock;

- (void)setUp
{
	//set up data
	wrap = NO;
    scrollEndAnimation = NO;
    
	self.items = [NSMutableArray array];
	for (int i = 0; i < NUMBER_OF_ITEMS; i++)
	{
		[items addObject:[NSNumber numberWithInt:i]];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self setUp];
	
	//configure carousel
    _carousel.decelerationRate = 0.2;
	_carousel.type = iCarouselTypeRotary;
	_carousel.perspective = -0.001;
	_carousel.viewpointOffset = CGSizeMake(0, 0);
	
	[_carousel reloadData];
	[_carousel scrollToItemAtIndex:18 animated:YES];
}

- (void) dealloc {
    _carousel.delegate = nil;
	_carousel.dataSource = nil;
	
    [_infoBlock release];
    [_carousel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)toggleOrientation
{
    //carousel orientation can be animated
    [UIView beginAnimations:nil context:nil];
    _carousel.vertical = !_carousel.vertical;
    [UIView commitAnimations];
    
    //update button
    NSLog(@"orientation: %@", _carousel.vertical? @"Vertical": @"Horizontal");
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0)
    {
        //map button index to carousel type
        iCarouselType type = buttonIndex;
        
        //carousel can smoothly animate between types
        [UIView beginAnimations:nil context:nil];
        _carousel.type = type;
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    //this also affects the appearance of circular-type carousels
    return NUMBER_OF_VISIBLE_ITEMS;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	UILabel *label = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
		view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page.png"]] autorelease];
		[view setTag:index];
		label = [[[UILabel alloc] initWithFrame:view.bounds] autorelease];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [label.font fontWithSize:50];
		[view addSubview:label];
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
    //set label
	//label.text = [[items objectAtIndex:index] stringValue];
	
	return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return INCLUDE_PLACEHOLDERS? 2: 0;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    if (scrollEndAnimation) {
        [self performSelectorOnMainThread:@selector(startAnimateInfoBlock) withObject:nil waitUntilDone:NO]; 
        scrollEndAnimation = NO;
    }
}

- (void) startAnimateInfoBlock {
    [UIView animateWithDuration: 0.3 animations:^{
        self.infoBlock.alpha = 1.0;
    }];
}

- (void) stopAnimateInfoBlock {
    [UIView animateWithDuration: 0.3 animations:^{
        self.infoBlock.alpha = 0.0;
    }];
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    [self stopAnimateInfoBlock];
    
    scrollEndAnimation = YES;
    
	if ([_carousel.visibleItemViews count] != 0){
		if (carousel.currentItemIndex <= 1) {
			for (int i = 4; i < 10; i++) {
				[(UIView*)[_carousel.visibleItemViews objectAtIndex:i] setHidden:YES];
			}
		} else {
			for (int i = 1; i < [_carousel.visibleItemViews count]; i++) {
				[(UIView*)[_carousel.visibleItemViews objectAtIndex:i] setHidden:NO];
			}
	 	}
		
		if (carousel.currentItemIndex >= [items count]-2) {
			for (int i = 0; i < 6; i++) {
				[(UIView*)[_carousel.visibleItemViews objectAtIndex:i] setHidden:YES];
			}
		}
	}
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	UILabel *label = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
		view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page.png"]] autorelease];
		[view setTag:index];
		label = [[[UILabel alloc] initWithFrame:view.bounds] autorelease];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		label.font = [label.font fontWithSize:50.0f];
		[view addSubview:label];
	}
	else
	{
		label = [[view subviews] lastObject];
	}
	
    //set label
	label.text = (index == 0)? @"[": @"]";
	
//	if (index == 0) {
//		[view setHidden:YES];
//	} else {
//		[view setHidden:NO];
//	}
	
	return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
	if (carousel.currentItemIndex == index) {
		NSLog(@"Click, %d", index);
	}
	
	[(UIView*)[_carousel viewWithTag:index] setHidden:YES];
}


- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return ITEM_SPACING;
}

- (CGFloat)carousel:(iCarousel *)carousel itemAlphaForOffset:(CGFloat)offset
{
	//set opacity based on distance from camera
	float alphaOffset = 1.0f - fminf(fmaxf(offset, 0.0f), 0.0f);
	
	NSLog(@"%f", alphaOffset);
	
    return alphaOffset;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return wrap;
}

@end
