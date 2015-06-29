
#import "ViewController.h"
#import <Foundation/Foundation.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize scrollView = _scrollView;
@synthesize mapView = _mapView;
@synthesize directionsView = _directionsView;

// reference tutorial:
// http://www.raywenderlich.com/10518/how-to-use-uiscrollview-to-scroll-and-zoom-content
- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"map.png"];
    self.mapView = [[MapView alloc] initWithImage:image];
    self.mapView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [self.scrollView addSubview:self.mapView];
    self.scrollView.contentSize = image.size;
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSingleTapped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapRecognizer];
    
    NSError *err = nil;
    NSString *html =
        @"<div style='font-size:11pt;font-family:sans-serif;'>"
         "I am a <b>map</b>!"
         "</div>";
    self.directionsView.attributedText =
        [[NSAttributedString alloc]
            initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
            documentAttributes:nil
            error:&err];
    self.directionsView.layer.borderWidth = 2.0f;
    self.directionsView.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    
    [self centerScrollViewContents];
    
    // try to position map around center of campus
    float zoomConstant = 1.6;
    [self.scrollView zoomToRect:CGRectMake(1300-self.scrollView.bounds.size.width/2*zoomConstant, 400-self.scrollView.bounds.size.height/2*zoomConstant, self.scrollView.bounds.size.width*zoomConstant, self.scrollView.bounds.size.height*zoomConstant) animated:false];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.mapView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.mapView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.mapView];
    
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mapView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (void)scrollViewSingleTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.mapView];
    [_mapView handleUserTapOnX:pointInView.x OnY:pointInView.y];
    [_mapView setNeedsDisplay];
}

@end
