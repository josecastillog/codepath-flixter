//
//  MovieViewController.m
//  Flixter
//
//  Created by Jose Castillo Guajardo on 6/15/22.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *movieTitlesSearch;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *movies;

@property (nonatomic, strong) NSArray *filteredData;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation MovieViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
}

- (void)networkAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Netowork Error"
                                   message:@"There was a network error"
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try Agian" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {[self fetchMovies];}];
     
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)fetchMovies {
    // 1. Create URL
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=4fb1894ebb595c4460d42983090843d8"];
    
    // 2. Create request
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    // 3. Create session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    // 4. Create our session task
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               [self networkAlert];
           }
           else {
               
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               self.movies = dataDictionary[@"results"];
               
               self.filteredData = self.movies;
               [self.tableView reloadData]; // Reload data in the tableview
               [self.activityIndicator stopAnimating];

           }
        [self.refreshControl endRefreshing]; // Ends refreshing animation
       }];
    
    // 5. Will send request
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MovieCell"
                                                                 forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredData[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];

    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];

    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {

        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];

    }
    else {
        self.filteredData = self.movies;
    }

    [self.tableView reloadData];
 
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        if ([[segue identifier] isEqualToString:@"details"])
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSDictionary *dataToPass = self.filteredData[indexPath.row];
            DetailsViewController *detailVC = [segue destinationViewController];
            detailVC.detailDict = dataToPass;
        }
}

@end
