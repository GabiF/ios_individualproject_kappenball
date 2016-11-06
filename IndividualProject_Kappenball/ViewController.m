//
//  ViewController.m
//  IndividualProject_Kappenball
//
//  Created by Gabriel Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// define the movement constants
static const float DT = 0.1;
static const float DECAY = 0.95;
static const float Y_VELOCITY = 0.75;

static const float BLOB_WIDTH = 40.0;
static const float BLOB_HEIGHT = 45.0;

/* Instance methods */

// Slider actions
-(IBAction)randSliderChanged
{
    // Get the value of the slider and store it in the appData randomness variable
    self.appData.randomness = self.randSlider.value;
}

// Buttons actions
-(IBAction)resetBtnPressed
{
    // Stop the timer and wait for the "START" button to be pressed
    [self stopMovementTimer];
    
    // Initialize all the variables
    [self initializeVariables];
    
    // Set the button's title to "START"
    [self.pauseBtn setTitle:@"START" forState:UIControlStateNormal];
}

-(IBAction)pauseBtnPressed
{
    // Determine if the pause button is in its initial state ("Start")
    if([self.pauseBtn.currentTitle compare:@"START"] == NSOrderedSame)
    {
        // Start the game
        [self startMovementTimer];
        
        // Set the button's title to "PAUSE"
        [self.pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
    }
    else
    {
        // Determine what is the status of the pause button ("Pause" or "Resume")
        if([self.pauseBtn.currentTitle compare:@"PAUSE"] == NSOrderedSame)
        {
            // Freeze the timer
            [self stopMovementTimer];
            
            // Set the button's title to "RESUME"
            [self.pauseBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        }
        else
        {
            // Restart the timer
            [self startMovementTimer];
            
            // Set the button's title to "PAUSE"
            [self.pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
        }
    }
}

-(IBAction)highscoresBtnPressed
{
    // empty
}

// Timer methods
-(void)startMovementTimer
{
    if(!(self.movementTimer.isValid))
    {
        self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
    }
}

-(void)stopMovementTimer
{
    [self.movementTimer invalidate];
}

// Initialization method
-(void)initializeVariables
{
    // Initialize the ball model
    self.ball.xCoord = self.viewCenter.frame.size.width / 2.0;
    self.ball.yCoord = 0.0;
    
    // Initialize the appData model
    self.appData.score = 0;
    self.appData.avgEnergy = 0;
    self.appData.currentEnergy = 0;
    self.appData.xVelocity = 0.0;
    self.appData.acceleration = 0.0;
}

-(void)moveBall
{
    // NOTE: So here I only calculate (and verify) the new values and update the model, which will possibly fire the observeValueForKeyPath method
    
    // Calculate the new x and new y
    // determine the new random behaviour on x-axis
    float rand = (arc4random() % 41) - 20.0;
    // determine new x-axis velocity
    float newXVelocity = self.appData.xVelocity * DECAY + self.appData.acceleration + self.appData.randomness * rand;
    // calculate new x
    float newX = self.ball.xCoord + newXVelocity * DT;
    // calculate new y
    float newY = self.ball.yCoord + Y_VELOCITY;
    
    // Determine if the new coordinates of the ball mean ball interacts with background: walls, spikes, holes
    if(newY < self.viewCenter.frame.size.height)
    {
        // well these values I have to get empirically, by trial-and-error. cause we don't know the exact coordinates of spikes, walls, holes
        // but I'll just make it go down until it reaches the bottom of the view, and then reset
        self.ball.xCoord = newX;
        self.ball.yCoord = newY;
    }
    else
    {
        [self initializeVariables];
    }
    
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    
    if([[touch view] isEqual:self.viewCenter])
    {
        CGPoint touchPoint = [touch locationInView:self.viewCenter];
        
        // Show the blob at the current touch point
        self.blobImageView.center = touchPoint;
        self.blobImageView.alpha = 0.8;
        
        // Determine the position of the touch w.r.t. the current position of the ball
        CGPoint ballCenter = CGPointMake(self.ball.xCoord, self.ball.yCoord);
        
        if(touchPoint.x < ballCenter.x)
        {
            // The touch was on the LHS of the ball
            self.appData.acceleration = 5.0;
        }
        else
        {
            // The touch was on the RHS of the ball
            self.appData.acceleration = -5.0;
        }
        
        // Determine the used energy
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if([[touch view] isEqual:self.viewCenter])
    {
        CGPoint touchPoint = [touch locationInView:self.viewCenter];
        // Move the position of the blob to the current touch point
        self.blobImageView.center = touchPoint;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Hide the blob
    self.blobImageView.alpha = 0.0;
    
    // Acceleration is 0 as there is no more touch on the screen
    self.appData.acceleration = 0.0;
    
    // Do something with the determined used energy
}

// so this is the method that says "Look at x and y and see if they change". if they do, call ** //TODO: delete this comment
-(void)connectBallModel:(BallModel*)ball
{
    [ball addObserver:self forKeyPath:@"xCoord" options:NSKeyValueObservingOptionNew context:nil];
    [ball addObserver:self forKeyPath:@"yCoord" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)connectAppDataModel:(AppDataModel*)appData
{
    [appData addObserver:self forKeyPath:@"score" options:NSKeyValueObservingOptionNew context:nil];
    [appData addObserver:self forKeyPath:@"avgEnergy" options:NSKeyValueObservingOptionNew context:nil];
    [appData addObserver:self forKeyPath:@"currentEnergy" options:NSKeyValueObservingOptionNew context:nil];
}

// ** this method automatically
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // and here is where I do the visual updates on the view
    // it's like a communication:
    /*
     C -> M: make this changes
     M: making the changes
     M -> C: I made the changes, you have to do your thing cause things changed in my fields
     C: ok, doing the visual changes
     */ //TODO: delete these comments
    
    // Check if one of the values in the ball model has changed
    if(([keyPath compare:@"xCoord"] == NSOrderedSame) || ([keyPath compare:@"yCoord"] == NSOrderedSame))
    {
        // If yes, then update the position of the ball on the screen
        CGPoint ballCenter = CGPointMake(self.ball.xCoord, self.ball.yCoord);
        self.ballImageView.center = ballCenter;
    }
    
    // Check if one of the values in the appData model has changed
    if([keyPath compare:@"score"] == NSOrderedSame)
    {
        // If yes, then update the value in the score label
        self.scoreLabel.text = [NSString stringWithFormat:@"%d",self.appData.score];
    }
    if([keyPath compare:@"avgEnergy"] == NSOrderedSame)
    {
        // If yes, then update the value in the average energy label
        self.avgEnergyLabel.text = [NSString stringWithFormat:@"%d",self.appData.avgEnergy];
    }
    if([keyPath compare:@"currentEnergy"] == NSOrderedSame)
    {
        // If yes, then update the value in the current energy label
        self.currEnergyLabel.text = [NSString stringWithFormat:@"%d",self.appData.currentEnergy];
    }
}

/* Predefined methods (editable) */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.ball = [[BallModel alloc]initWithX:(self.viewCenter.frame.size.width / 2.0) Y:0.0];
    [self connectBallModel:self.ball];
    self.appData = [[AppDataModel alloc]init];
    [self connectAppDataModel:self.appData];
    
    // Create the background imageview
    CGRect backgroundRect = CGRectMake(0.0, 0.0, self.viewCenter.frame.size.width, self.viewCenter.frame.size.height);
    UIImage* backgroundImag = [UIImage imageNamed:@"field.png"];
    UIImageView* background = [[UIImageView alloc]initWithFrame:backgroundRect];
    [background setImage:backgroundImag];
    // Set the backgroundImageView of the viewcontroller to be the above one and add it to the view
    self.backgroundImageView = background;
    [self.viewCenter addSubview:self.backgroundImageView];
    
    // Create the ball imageview
    UIImage* ballImag = [UIImage imageNamed:@"ball.png"];
    UIImageView* ball = [[UIImageView alloc]initWithImage:ballImag];
    // Set the ballImageView of the viewcontroller to be the above one and add it to the view
    self.ballImageView = ball;
    [self.viewCenter addSubview:self.ballImageView];
    
    // Create the blob imageview
    CGRect blobRect = CGRectMake(self.viewCenter.frame.size.width / 2.0, self.viewCenter.frame.size.height / 2.0, BLOB_WIDTH, BLOB_HEIGHT);
    UIImage* blobImag = [UIImage imageNamed:@"blob.png"];
    UIImageView* blob = [[UIImageView alloc]initWithFrame:blobRect];
    [blob setImage:blobImag];
    blob.alpha = 0.0;
    // Set the blobImageView of the viewcontroller to be the above one and add it to the view
    self.blobImageView = blob;
    [self.viewCenter addSubview:self.blobImageView];
    
    // Initialize all models variables
    [self initializeVariables];
    
    // Set the default value for the slider to be 0.0
    self.randSlider.value = 0.0;
    
    // start the timer
//    self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveBall) userInfo:nil repeats:YES]; //TODO: remove this part of code
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

// Override the method to set the preferred orientation style to landscape.
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // This will make the application run by default in landscape mode
    return UIInterfaceOrientationLandscapeLeft;
}

@end
