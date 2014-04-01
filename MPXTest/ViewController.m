//
//  ViewController.m
//  MPXTest
//
//  Created by Alec Hoffman on 22/03/2014.
//  Copyright (c) 2014 Alec Hoffman. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) submitAuthenticatedRest_PUT
{
    
    // it all starts with a manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // in my case, I'm in prototype mode, I own the network being used currently,
    // so I can use a self generated cert key, and the following line allows me to use that
    manager.securityPolicy.allowInvalidCertificates = YES;
    // Make sure we a JSON serialization policy, not sure what the default is
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // No matter the serializer, they all inherit a battery of header setting APIs
    // Here we do Basic Auth, never do this outside of HTTPS
    [manager.requestSerializer
     setAuthorizationHeaderFieldWithUsername:@"alec.hoffman@6xw.co"
     password:@"Frances1"];
    
    // Now we can just PUT it to our target URL (note the https).
    // This will return immediately, when the transaction has finished,
    // one of either the success or failure blocks will fire
    
    
    [manager
     GET: @"https://identity.auth.theplatform.eu/idm/web/Authentication/signIn?schema=1.0&form=json&_duration=28800000&_idleTimeout=3600000"
     parameters: nil
     success:^(AFHTTPRequestOperation *operation, id responseObject){
         NSLog(@"Submit response data: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"signInResponse"];
         NSString* token = [response objectForKey:@"token"];
         NSLog(@"token: %@", token);
         
         // Now set use the token
         
         [manager.requestSerializer clearAuthorizationHeader];
         [manager.requestSerializer
          setAuthorizationHeaderFieldWithUsername:@""
          password:token];
         
         // Call the API to return data   ******************
         
         [manager
          GET: @"http://data.media.theplatform.eu/media/data/Media?schema=1.6&form=json&byCustomValue=%7BpCNumber%7D%7B547926%7D"
          
          parameters: nil
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              
        
              // Load up the videos array
              videos = [responseObject objectForKey:@"entries"];
              
              
          
  
              
              
              [self.videosTableView reloadData];
              
  //            NSLog(@"API response data: %@", responseObject);
              
           } // success callback block
          
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"Error: %@", error);
              
          } // failure callback block
          ];
         
         // ******************************

         
     } // success callback block
     
     failure:^(AFHTTPRequestOperation *operation, NSError *error){
         NSLog(@"Error: %@", error);
     
     } // failure callback block
     ];
    
}


- (IBAction)testButtonPressed:(id)sender {
    [self submitAuthenticatedRest_PUT];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // NB No sections in this table
    
        return 1;

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    

        return [videos count];
  }





- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section


{
    

        return @"Videos";

    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VideoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //    int section = indexPath.section;
    int row = indexPath.row;
    
        
        NSDictionary *videoFile = [videos objectAtIndex:row];
        cell.textLabel.text = videoFile[@"title"];
   //     cell.imageView.image = [UIImage imageNamed:@"images.jpeg"];

    
    // Get the thumbnail
//  NSLog(@"URL: %@", videoFile);
    
    NSMutableArray *thumbnails = videoFile[@"media$thumbnails"];
    
    if (!([thumbnails count] == 0))
    {
    
    NSDictionary *thumbnail = [thumbnails objectAtIndex:0];
//    NSLog(@"URL: %@", thumbnail[@"plfile$streamingUrl"]);
    
    NSString *ImageURL = thumbnail[@"plfile$streamingUrl"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    cell.imageView.image = [UIImage imageWithData:imageData];
        
    }
 
    
    return cell;
    
}

@end
