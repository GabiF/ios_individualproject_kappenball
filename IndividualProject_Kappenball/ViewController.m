//
//  ViewController.m
//  IndividualProject_Kappenball
//
//  Created by Gabriel Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import "ViewController.h"

#define GAME_SCREEN_WIDTH    736
#define GAME_SCREEN_HEIGHT   275

@interface ViewController ()

@end

@implementation ViewController

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
    // Initialize all the variables
    [self initializeVariables];
}

-(IBAction)pauseBtnPressed
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
    self.ball.xCoord = GAME_SCREEN_WIDTH/2.0;
    self.ball.yCoord = self.ballImageView.frame.size.height/2.0;
    
    // Initialize the appData model
    self.appData.score = 0;
    self.appData.avgEnergy = 0;
    self.appData.currentEnergy = 0;
    self.appData.randomness = 0.0;
}

-(void)moveBall
{
    
    // so here I only calculate the new values and update the model, which will fire that observeValueForKeyPath
    // calculate the new x and new y
    float x = self.ball.xCoord;
    float y = self.ball.yCoord;
    
    y = y + 0.2;
    if(y < GAME_SCREEN_HEIGHT)
    {
        // well these values I have to get empirically, by trial-and-error. cause we don't know the exact coordinates of spikes, walls, holes
        // but I'll just make it go down until it reaches the bottom of the view, and then reset
        self.ball.xCoord = x;
        self.ball.yCoord = y;
    }
    else
    {
        [self initializeVariables];
    }
    
    // call the update method for the screen
    
}

// so this is the method that says "Look at x and y and see if they change". if they do, call **
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
    [appData addObserver:self forKeyPath:@"randomness" options:NSKeyValueObservingOptionNew context:nil];
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
     */
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

// Interface update method
-(void)updateInterface
{
    
}


/* Predefined methods (editable) */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ball = [[BallModel alloc]initWithX:(GAME_SCREEN_WIDTH/2.0) Y:0.0];
    [self connectBallModel:self.ball];
    self.appData = [[AppDataModel alloc]init];
    //[self connectAppDataModel:self.appData];
    
    // Create the background imageview
    CGRect backgroundRect = CGRectMake(0.0, 0.0, GAME_SCREEN_WIDTH, GAME_SCREEN_HEIGHT);
    UIImage* backgroundImag = [UIImage imageNamed:@"field.png"];
    
    UIImageView* background = [[UIImageView alloc]initWithFrame:backgroundRect];
    [background setImage:backgroundImag];
    // Set the backgroundImageView of the viewcontroller to be the above one and add it to the view
    self.backgroundImageView = background;
    [self.viewCenter addSubview:self.backgroundImageView];
    
    UIImage* ballImag = [UIImage imageNamed:@"ball.png"];
    UIImageView* ball = [[UIImageView alloc]initWithImage:ballImag];
    // Set the ballImageView of the viewcontroller to be the above one and add it to the view
    self.ballImageView = ball;
    [self.viewCenter addSubview:self.ballImageView];
    
    [self initializeVariables];
    
    // start the timer
    self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
