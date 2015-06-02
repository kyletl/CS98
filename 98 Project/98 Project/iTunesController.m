//
//  iTunesController.m
//  98 Project
//
//  Created by Taylor Cathcart on 4/23/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "iTunesController.h"
#import "AppDelegate.h"

@interface iTunesController ()

@property (weak, nonatomic) IBOutlet UIButton *pickerStart;

@property (weak, nonatomic) MPMediaItemCollection *mediaSelection;

@end

@implementation iTunesController


- (IBAction)pickMusic:(id)sender {
    if (sender == self.pickerStart) {
        MPMediaPickerController *picker =
        [[MPMediaPickerController alloc]
         initWithMediaTypes: MPMediaTypeAnyAudio];
        
        [picker setDelegate: self];
        [picker setAllowsPickingMultipleItems: YES];
        picker.prompt =
        NSLocalizedString (@"Add songs to play",
                           "Prompt in media item picker");
        
        [self presentViewController: picker animated: YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    MPMediaPickerController *picker =
//    [[MPMediaPickerController alloc]
//     initWithMediaTypes: MPMediaTypeAnyAudio];
//    
//    [picker setDelegate: self];
//    [picker setAllowsPickingMultipleItems: YES];
//    picker.prompt =
//    NSLocalizedString (@"Add songs to play",
//                       "Prompt in media item picker");
//    
//    [self presentViewController: picker animated: YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
    
    [self dismissViewControllerAnimated: YES completion:nil];
    
    self.mediaSelection = collection;
    [self performSegueWithIdentifier: @"updateQueueSegue" sender: self];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated: YES completion:nil];
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString: @"updateQueueSegue"]) {
        NSLog(@"in iTunes, segue id is %@", segue.identifier);
//        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
//        QueueController *qController = (QueueController *)navController.topViewController;
        QueueController *qController = (QueueController *)segue.destinationViewController;
//        [qController updateQueueWithCollection: self.mediaSelection.items];
//        qController.freshQueueItems = self.mediaSelection.items;
//        self.mediaSelection = nil;
    }
}

@end
