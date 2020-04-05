Include("Script/gui.nut")
Include("Script/globals.nut")
//Include("Script/ace_deleter.nut")


//Engine 
g_timer		  <- 0.0
g_clock_scale <- 0.0

//game state
pause		<- 0
current_scene <- 0

//=== achievements ===
achieved	<- []

g_sounds	<- []
g_geo		<- {}
g_patfs		<- []
g_patlocs		<- []


class	SchmupProject
{

	scene 		= 0
	chnl_title  = 0
	ready 		= 0
	Abutton		= 82
	StartButton = 93
	LB			= 95
	RB			= 98
	Up			= 19
	Down		= 20
	Left		= 21
	Right		= 22

//	========================================================================================================
	function	OnUpdate(project)
//	========================================================================================================
	{
		local	keyboard 	= GetKeyboardDevice(),
				pad 		= GetInputDevice("xinput0"),
				touched		= false

		if	(IsTouchPlatform())
			for	(local n = 0; n < 4; ++n)
			{
				local	touch_device = GetInputDevice("touch" + n)
				if (DeviceWasKeyDown(touch_device, KeyButton0)) touched = true 
			}

		if	( (!ready) && (DeviceIsKeyDown(keyboard, KeySpace) || DeviceWasKeyDown(pad, KeyStart) || touched) )
		{	
			touched = false
			ready = 1
			ProjectUnloadScene(project, scene)
			scene = ProjectInstantiateScene(project, "Scenes/Preload.nms")
			ProjectAddLayer(project, scene, 1)
			ready = 3
		}

		if ((ready == 3) && (DeviceIsKeyDown(keyboard, KeyEnter) || touched) )
//			if (ProjectSceneGetScriptInstanceFromClass(scene, "Preload").state == "preloaded")
		{
			touched = false
			ProjectUnloadScene(project, scene)
			scene = ProjectInstantiateScene(project, "Scenes/Level1.nms")
			ProjectAddLayer(project, scene, 1)
			MixerChannelStop(g_mixer,chnl_title)
			ready = 4
		}

		if	((ready) && (DeviceIsKeyDown(keyboard, KeyR)) || (DeviceIsKeyDown(pad, KeyButton1 )))
		{
			ProjectUnloadScene(project, scene)
			scene = ProjectInstantiateScene(project, "Scenes/Level1.nms")
			g_timer = g_clock
			ProjectAddLayer(project, scene, 1)
		}
			
	}

	/*!
		@short	OnRenderScene
		Called before rendering a scene layer.
	*/
	function	OnRenderScene(project, scene, layer)
	{
	}
	

	/*!
		@short	OnSetup
		Called when the project is about to be setup.
	*/
//	========================================================================================================
	function	OnSetup(project)
//	========================================================================================================
	{
//		g_clock_scale = EngineGetClockScale(g_engine)
//		EngineSetFixedDeltaFrame(g_engine,60)

		chnl_title = MixerStreamStart(g_mixer,snd_mu_title)

		MixerChannelSetGain(g_mixer, chnl_title, 0.8)
		MixerChannelSetLoopMode(g_mixer, chnl_title, LoopRepeat)

		scene = ProjectInstantiateScene(project, "Scenes/Title.nms")
		ProjectAddLayer(project, scene, 1)
	}
}