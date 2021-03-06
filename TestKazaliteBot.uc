class TestKazaliteBot extends GameAIController;

var Actor Target;
var() Vector TempDest;

var int CreditWorth;

var DemoPawns Player1;
var DemoPawns P;

var AdvKitPlayerController PlayerCon;
var bool bheadshot;
var float HearingDistance;
var bool Seen1Player;

var Pawn thePlayer; //variable to hold the target pawn
 var float DistanceToPlayer;
var float AttackDistance;
// Zombie sound variables
var() SoundCue FollowSound; // Only heard in third person however there is no third person.
var() SoundCue AttackSound;
var Vector MTarget;
var int OffsetX;
var int OffsetY;
var bool Alerted;

  function CalculateFinalHealth()
{
   if(Pawn.Health <= 0)
   {
     ConsoleCommand("Suicide");
   }
}

 function Alert()
{
  local DemoPawn PersonToKill;

  if(Alerted == false)
  {
    foreach AllActors(class'DemoPawn', PersonToKill)
    {
      Target = PersonToKill;
      GoToState('Follow');
      
      Alerted = true;
    }
  }
  else
  return;
}

 state SuprisedState
{
   function Suprise()
{

   local DemoPawns ZG;

   ZG = DemoPawns(Pawn);


   //WorldInfo.Game.Broadcast(self,"Suprised!!!");

  // ZG.FullBodyAnimSlot.PlayCustomAnim('BoredB', 1.0, 0.2, 0.2, false, TRUE);

   foreach VisibleCollidingActors(class'DemoPawns', Player1, 845)
   //** Search for pawn within a certain radius and turn around to where the shot
   //** originated from.
   {

       if(Player1 != None)//** Continually check to make sure the Player is still connected.
       {
          Pawn.SetDesiredRotation(Rotator(Normal(Player1.Location)));
          GotoState('Idle');//** Going to state idle will allow for the pawn to "SEE" the player when the zombie turns around.
       }
   }
}
   Begin:

   Suprise();

}
auto state Idle
{
    event SeePlayer (Pawn Seen)
    {
         local float Distance;

        super.SeePlayer(Seen);
                PlaySound(FollowSound);
       

        Target = Seen;
        Seen1Player = true;

        Distance = Vsize(Target.Location - Pawn.Location);
        P = DemoPawns(Pawn);

        if(Distance < P.SightDistance )
        {
        GotoState('Follow');
        PlaySound(SoundCue'ZombiesSounds.Moan.zombiemoan_Cue');

        if(Alerted == false )
        {
           SetTimer(1.0, false ,'AlertNearbyZombies');
        }

         if(Pawn.Health <= 0)
                            {
                              Pawn.Destroy();
                              Destroy();
                            }
        }
    }
    



Begin:


  P = DemoPawns(Pawn);

  if (P.bRandomMovement == true) // If randome/active movement is set to true
  {
     //make a random offset, some distance away
     OffsetX = Rand(500)-Rand(500);
     OffsetY = Rand(500)-Rand(500);

       //some distance left or right and some distance in front or behind
     MTarget.X = Pawn.Location.X + OffsetX;
     MTarget.Y = Pawn.Location.Y + OffsetY;
       //so it doesnt fly up n down
       MTarget.Z = Pawn.Location.Z;

      GoToState('MoveAbout');
   }
}


 state MoveAbout
{
   // If you see the player while randomly moving...
  event SeePlayer (Pawn Seen)
    {
         local float Distance;
        
        super.SeePlayer(Seen);
        Target = Seen;
        Seen1Player = true;
        
                 PlaySound(AttackSound);

        Distance = Vsize(Target.Location - Pawn.Location);
        P = DemoPawns(Pawn);
        // Check how far away you are first....
        if(Distance < P.SightDistance )
        {
        GotoState('Follow');
        //Incase you died but you dont know it...
         if(Pawn.Health <= 0)
                            {
                              Pawn.Destroy();
                              Destroy();
                            }
        }
         
    }

Begin:

    P = DemoPawns(Pawn);

    MoveTo(MTarget);
    Sleep(P.RandomInterval);
    GoToState('Idle');
}


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

}

 event SeePlayer(Pawn SeenPlayer) //bot sees player
{
          if (thePlayer ==none) //if we didnt already see a player
          {
		thePlayer = SeenPlayer; //make the pawn the target
		GoToState('Follow'); // trigger the movement code
          }
}


state Follow
{
    ignores SeePlayer;
    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;

        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Target );
        class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Target,32 );

        // Find path
        return NavigationHandle.FindPath();
    }
Begin:

          PlaySound(FollowSound);

    if( NavigationHandle.ActorReachable( Target) )
    {
        FlushPersistentDebugLines();
        //Direct move
        MoveToward( target,target );
        
        if(Pawn.Health <= 0 || P == None)
                            {
                              Destroy();
                              P.Destroy();
                            }
    }
    else if( FindNavMeshPath() )
    {


        NavigationHandle.SetFinalDestination(Target.Location);
        FlushPersistentDebugLines();
      //  NavigationHandle.DrawPathCache(,TRUE);
        
        // move to the first node on the path
        if(!NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()))
        {
          GoToState('Begin');
        }
        else if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            if ( !NavigationHandle.GetNextMoveLocation ( TempDest, Pawn.GetCollisionRadius()))
            {
              MoveToward( target,target );
              GoTo('Begin');
            }
            else
            {
          //     DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
           //   DrawDebugSphere(TempDest,16,20,255,0,0,true);
               MoveTo( TempDest);
            }
        }
    }

    else
    {
        //We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        GotoState('Idle');
        Seen1Player = false;
    }  //Check Attack distance...
    if (VSize(Pawn.Location - target.Location) <= 206)
{
    GotoState('Attacking'); //Start attacking when close enough to the player.
}
else
{
    goto 'Begin';
}

}


state HeardNoise //Hearing Treshhold is generally 1000 can be edited in the editor...

{


      function CheckNoise()
      {
         local DemoPawns ZG;

         ZG = DemoPawns(Pawn);
                 PlaySound(AttackSound);
         if(Seen1Player == true)
         {
         }
         else
         {
              foreach AllActors(class'AdvKitPlayerController', PlayerCon)
              {

               if (PlayerCon.MadeNoise == true)
               {
                                                                            //doubling hearing treshhold. Seems more realistic
                   foreach VisibleCollidingActors (class'DemoPawns',Player1, 2000)
                        {
                            Pawn.SetDesiredRotation(Rotator(Normal(Player1.Location)));
                            PlayerCon.MadeNoise = false;

                            //** Going to state idle will allow for the pawn to "SEE" the player when the zombie turns around.
                        }

               }

               } // Play that awesome suprised look.. like huh what... who there?
           //   ZG.TopHalfAnimSlot.PlayCustomAnim('BoredA', 1.0, 0.2, 0.2, false, TRUE);
         }
      }


      Begin:
         Sleep(0.f);
         CheckNoise();
         GoToState('Idle');
         // Again if we dont know we are dead... kill ourselves
         if(Pawn.Health <= 0)
                            {
                              ConsoleCommand("Suicide");
                            }




}

state Attacking
{

    function TakePlayerDamage()
    {
       local DemoPawns ZG;

       ZG = DemoPawns(Pawn);


       if (Target != None) //** Continualy check if player is still alive
       {

                 `log("IM HURTING YOU!!!!");// 10 damage should be enough, because 20 zombies attacking you may get pretty bad.
                 Target.TakeDamage(10, self, Location, vect(0,0,0), class'DmgType_Crushed');
                 PlaySound(AttackSound);
            ZG.FullBodyAnimSlot.PlayCustomAnim('KazaliteAxeAttack_CorrectedFBX01', 1.0, 0.2, 0.2, false, true); //Play attack animation
              GoToState('Follow');

       }
       else
       {
         //Nothing
       }
    }
    Begin:
        Sleep(0.5);
        TakePlayerDamage();
        GoToState('Idle');

}

defaultproperties
{
  AttackDistance = 100
  FollowSound = SoundCue'ZombiesSounds.Moan.zombiemoan_Cue'
  AttackSound = SoundCue'ZombiesMonsters.Tyrant.Tyrant_IdleGrowl_Cue'
  CreditWorth = 200
  Seen1Player = false
  bheadshot = false
  Alerted = false

}