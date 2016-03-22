class GFxProjectedItemUI extends GFxMoviePlayer;


var GFXObject Information;

function bool Start(optional bool StartPaused = false)
{	


    super.Start();
    Advance(0.0);
	
    Information = GetVariableObject("Information");

    RenderTextureMode = GFxRenderTextureMode.RTM_AlphaComposite;
    return true;	
}


defaultproperties
{    
    bDisplayWithHudOff = false
}