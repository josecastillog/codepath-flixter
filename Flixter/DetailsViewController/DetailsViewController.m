//
//  DetailsViewController.m
//  Flixter
//
//  Created by Jose Castillo Guajardo on 6/15/22.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.synopsisLabel sizeToFit];
    [self.titleLabel sizeToFit];
    self.titleLabel.text = self.detailDict[@"title"];
    self.synopsisLabel.text = self.detailDict[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.detailDict[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    self.posterImage.image = nil;
    [self.posterImage setImageWithURL:posterURL];
    [self.backImage setImageWithURL:posterURL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
