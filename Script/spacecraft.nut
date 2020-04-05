/*!
	@short	spacecraft
	@author	DG
*/

//gFFenergy <- 1000
Include("Script/globals.nut")

class	spacecraft
{
	g_timer		= 0

	lt_step	 	= 6 //lateral translation step
	v_step		= 6 //vertical translation step
	tOffset		= 2
	tLaps		= 0.00
	rLaps		= 0
	r_step 		= 50 //rotation step
	max_barrel	= 10 //angle de tilt max
	gFFON		= 0
	armed		= 0
	gMaxEnergy  = 1000
	vibTimer	= g_clock
	FFitem		= 0
	FFcolShape	= 0
	FFopacityStep = 0.04
	position	= 0

	camera 		= 0
	ShipScreenPosition = 0

	t_left		= false
	t_right 	= false
	t_up 		= false
	t_down 		= false
	t_rotate	= "none"


//	========================================================================================================
	function	ItemSetCaptured(captured_item, by_item)
//	========================================================================================================
	{
//		ItemSetParent(captured_item, by_item)
		ItemSetCollisionMask(captured_item, 0)
		ItemGetScriptInstance(captured_item).captured = 1
//		local sPos = ItemGetPivot(by_item)
//		local cPos = ItemGetPivot(captured_item)
		ItemGetScriptInstance(captured_item).cst_ship1 = SceneAddPointConstraint(ItemGetScene(by_item), "shipcst1", by_item, captured_item, Vector(0,-10,5), Vector(0,10,10))
		ItemGetScriptInstance(captured_item).cst_ship2 = SceneAddPointConstraint(ItemGetScene(by_item), "shipcst2", by_item, captured_item, Vector(0,-15,10), Vector(0,15,20))
//		SceneAddPointConstraint(ItemGetScene(by_item), "shipcst", by_item, captured_item, Vector(0,5,0), Vector(0,-15,0))
//		ItemPhysicSetAngularFactor(captured_item, Vector(0,0,0))

//		ItemPhysicResetTransformation(captured_item, cPos, Vector(0,0,0))

		armed = 1
	}

//	========================================================================================================
	function	OnUpdate(item)
//	========================================================================================================
	{

		local	keyboard 	= GetKeyboardDevice(),
				mouse 		= GetMouseDevice(),
				pad 		= GetInputDevice("xinput0"),

// Read pad input values
				padx 		= DeviceInputValue(pad, DeviceAxisX),
				pady 		= DeviceInputValue(pad, DeviceAxisY),
				pads 		= DeviceInputValue(pad, DeviceAxisS),
				padlt 		= DeviceInputValue(pad, DeviceAxisLT),
				padrt 		= DeviceInputValue(pad, DeviceAxisRT)
// Touch controls

		local usePad

		if (!("usePad" in getroottable()))
			usePad = 1

		if (("useMouse" in getroottable()) && (useMouse == 1))
		{
//			DeviceInputSetValue(mouse, DeviceAxisX, 0.5)
//			DeviceInputSetValue(mouse, DeviceAxisY, 0.5)
		}

// Read mouse input values
		if (("useMouse" in getroottable()) && (useMouse == 1))
		{
			local	old_mx = DeviceInputLastValue(mouse, DeviceAxisX),
					old_my = DeviceInputLastValue(mouse, DeviceAxisY)
			local	mx = DeviceInputValue(mouse, DeviceAxisX),
					my = DeviceInputValue(mouse, DeviceAxisY)
		}

		if (TickToSec(g_clock-vibTimer) >= 1)
		{
			DeviceSetEffect(pad, DeviceEffectVibrate, 0.0)
			vibTimer = g_clock
		}





		usePad = 1
		if (ItemIsCommandListDone(item))
		{

//Get the rotation matrix of the camera to compensate for the roll
		local camRotM = ItemGetRotationMatrix(CameraGetItem(camera))
		local shipRotM = ItemGetRotationMatrix(item)

		local position = ItemGetWorldPosition(item)
		local wLimit = SceneGetScriptInstance(g_scene).worldLimit

		if (position.x < wLimit.min.x)
			ItemSetPosition(item, Vector(0, position.y, position.z))
		if (position.x > wLimit.max.x)
			ItemSetPosition(item, Vector(0, position.y, position.z))
		if (position.y < wLimit.min.y)
			ItemSetPosition(item, Vector(position.x, 0, position.z))
		if (position.y > wLimit.max.y)
			ItemSetPosition(item, Vector(position.x, 0, position.z))

		position = ItemGetWorldPosition(item)


// Read touch
		t_left = t_right = t_up = t_down = t_rotate = false

		if	(IsTouchPlatform())
			for	(local n = 0; n < 4; ++n)
			{
				local touch_device = GetInputDevice("touch" + n)
				if (DeviceWasKeyDown(touch_device, KeyButton0))
				{
					local	_touch_pos_x = DeviceInputValue(touch_device, DeviceAxisX),
							_touch_pos_y = DeviceInputValue(touch_device, DeviceAxisY)	

					if (_touch_pos_x > 0.8) t_right = true 
					if (_touch_pos_x < 0.2) t_left = true 
					if (_touch_pos_y > 0.8) t_up = true 
					if (_touch_pos_y < 0.2) t_down = true 

					if ((_touch_pos_x > 0.5) && (_touch_pos_x < 0.8) && (_touch_pos_y > 0.4) && (_touch_pos_y < 0.6) ) t_rotate = "right"
					if ((_touch_pos_x < 0.5) && (_touch_pos_x > 0.2) && (_touch_pos_y > 0.4) && (_touch_pos_y < 0.6)) t_rotate = "left"

				}
			}



// Translations
			if	((DeviceIsKeyDown(keyboard, KeyLeftArrow)) || (usePad&&(padx < 0.0 )) || (DeviceIsKeyDown(pad, KeyLeftArrow)) || t_left )
			{
//				ItemSetPosition(item, Vector(position.x-1, position.y, position.z).ApplyMatrix(camRotM))
				local p = Vector(-tOffset,0,0).ApplyMatrix(camRotM)
				if ((position.x + p.x > wLimit.min.x) && (position.x + p.x < wLimit.max.x) && (position.y + p.y < wLimit.max.y) && (position.y + p.y > wLimit.min.y))
				{
					ItemSetCommandList(item, "offsetposition " + tLaps + "," + p.x + "," + p.y + "," + p.z + ";")
					MixerPlaySoundFast(g_mixer, snd_t)
				}
			}

			if	((DeviceIsKeyDown(keyboard, KeyRightArrow)) || (usePad&&(padx > 0.0 )) || (DeviceIsKeyDown(pad, KeyRightArrow)) || t_right )
			{
				local p = Vector(tOffset,0,0).ApplyMatrix(camRotM)
				if ((position.x + p.x > wLimit.min.x) && (position.x + p.x < wLimit.max.x) && (position.y + p.y < wLimit.max.y) && (position.y + p.y > wLimit.min.y))
				{
					ItemSetCommandList(item, "offsetposition " + tLaps + "," + p.x + "," + p.y + "," + p.z + ";")
					MixerPlaySoundFast(g_mixer, snd_t)
				}
//				ItemSetCommandList(item, "offsetposition " + duration + ",36,0,0;")
			}

			if	((DeviceIsKeyDown(keyboard, KeyUpArrow)) || (usePad&&(pady > 0.0 )) || (DeviceIsKeyDown(pad, KeyUpArrow)) || t_down )
			{
				local p = Vector(0,tOffset,0).ApplyMatrix(camRotM)
				if ((position.x + p.x > wLimit.min.x) && (position.x + p.x < wLimit.max.x) && (position.y + p.y < wLimit.max.y) && (position.y + p.y > wLimit.min.y))
				{
					ItemSetCommandList(item, "offsetposition " + tLaps  + "," + p.x + "," + p.y + "," + p.z + ";")
					MixerPlaySoundFast(g_mixer, snd_t)
				}
			}

			if	((DeviceIsKeyDown(keyboard, KeyDownArrow)) || (usePad&&(pady < 0.0 )) || (DeviceIsKeyDown(pad, KeyDownArrow)) || t_up )
			{
				local p = Vector(0,-tOffset,0).ApplyMatrix(camRotM)
				if ((position.x + p.x > wLimit.min.x) && (position.x + p.x < wLimit.max.x) && (position.y + p.y < wLimit.max.y) && (position.y + p.y > wLimit.min.y))
				{
					ItemSetCommandList(item, "offsetposition " + tLaps  + "," + p.x + "," + p.y + "," + p.z + ";")
					MixerPlaySoundFast(g_mixer, snd_t)
				}
			}

// Rotations

			if	(DeviceIsKeyDown(keyboard, KeyA) || pads < 0.0 || t_rotate == "right")
			{
//				local rotation = ItemGetRotation(item).ApplyMatrix(camRotM)
//				rotation = RadianToDegree(rotation.z+Deg(90))
				local rotation = RadianToDegree(ItemGetRotation(item).z+Deg(90))
				ItemSetCommandList(item, "torotation " + rLaps + ",0,0," + rotation + ";")
				MixerPlaySoundFast(g_mixer, snd_r)
			}

			if	(DeviceIsKeyDown(keyboard, KeyD) || pads > 0.0 || t_rotate == "left")
			{
				local rotation = RadianToDegree(ItemGetRotation(item).z-Deg(90))
				ItemSetCommandList(item, "torotation " + rLaps + ",0,0," + rotation + ";")
				MixerPlaySoundFast(g_mixer, snd_r)
			}
		}

if (debug)
{
	if	(DeviceIsKeyDown(keyboard, KeyQ)) gLifes++
	if	(DeviceIsKeyDown(keyboard, KeyW)) gLifes--
}



		// Shield Activated
/*
		if	((DeviceIsKeyDown(keyboard, KeyC)) ||  (usePad&&(padrt > 0.0)))
			{
				//sound feedback
				local shield  = ResourceFactoryLoadSound(g_factory, snd_fx_shield)
				if ((!gFFON) && (!armed)) //if force field is off and ship is not armed
				{
					MixerSoundStart(g_mixer, shield)
//					ItemSetSelfMask(FFcolShape, 3)
					ItemSetCollisionMask(FFcolShape, 4)
//					SetShieldShape(item, "mesh")
					gFFON = 1
				}
				
				try{
					if (gFFenergy > 0)
						{
							gFFenergy -= 1 
							ItemSetOpacity(FFitem  , Clamp(ItemGetOpacity(FFitem) + FFopacityStep,0,1))
						}
					if (gFFenergy <= 0)
						{
							gFFenergy = 0
							local channel = MixerStreamStart(g_mixer,"data/noenergy.ogg")
							MixerChannelSetGain(g_mixer, channel, 0.8)
							MixerChannelSetLoopMode(g_mixer, channel, LoopNone )
							ItemSetOpacity(FFitem  , Clamp(ItemGetOpacity(FFitem) - FFopacityStep,0,1))
						}
					}catch(e){}
			}
		else
			{
				//let the shield active until it is totally invisible
				if (ItemGetOpacity(FFitem) <= 0 )
					if (gFFON)
					{
						gFFON = 0
					}

				if (TickToSec(g_clock-g_timer) >= 0.01)
				{
					g_timer = g_clock
					try{
						if (gFFenergy < gMaxEnergy)
							gFFenergy++
						}
					catch(e){}
				}
			}
*/
	}

//	========================================================================================================
	function	SetShieldShape(item, shape)
//	========================================================================================================
	{
		local currentShape = ItemGetShapeFromIndex( item, 0)
        local size			= Vector(0,0,0)
		local minmax 		= ItemGetMinMax(item)
		size.x = minmax.max.x -  minmax.min.x
		size.y = minmax.max.y -  minmax.min.y
		size.z = minmax.max.z -  minmax.min.z

		if (shape == "sphere")
			ShapeSetSphere(currentShape,size.x)

		if (shape == "cube")
			ShapeSetBox(currentShape,size)

		if (shape == "mesh")
			ShapeSetMesh(currentShape, "Mesh/Spacecraft_LOPOLY.nmg")

//		ShapeSetPosition(currentShape, (minmax.max).Lerp(0.5, minmax.min))
		ItemSetup(item)
	}



//	========================================================================================================
	function	OnCollision(item, with_item)
//	========================================================================================================
	{

//		local mat = GeometryGetMaterialFromIndex(ItemGetGeometry(item), 0)
//		MaterialSetSelf(mat, Vector(1,0,0,1))

		if ( g_clock - ResetColTimer >= SecToTick(1) ) //disable the collision for 1 sec
		{
			gCam_shake = 1

			//vibration
			local pad = GetInputDevice("xinput0")
			if (gVibrate == 1)
				DeviceSetEffect(pad, DeviceEffectVibrate, 0.2)

			// Update beatScore
			if (SceneGetScriptInstance(ItemGetScene(item)).beatScore > 0)
				SceneGetScriptInstance(ItemGetScene(item)).beatScore--

			// Update Lifes
			if ((!gFFON) || (gFFenergy < 1))	gLifes += -1
			if (gLifes <= 0)	gLifes = 0
			
			ResetColTimer = g_clock
		}
	}

//	========================================================================================================
	function	OnPhysicStep(item,dt)
//	========================================================================================================
	{

	}



	function	OnRenderUser(item)
	{

/*		if (debug)
		{

			// Create a billboard matrix that will face the current view point and sit at the item position.
			local m = RendererGetViewMatrix(g_render)
			m.SetRow(3, ItemGetWorldPosition(item))

			// Set the world matrix and write.
			RendererSetWorldMatrix(g_render, m)

			local debugFont = LoadRasterFont(g_factory, "@core/fonts/profiler_base.nml", "@core/fonts/profiler_base")
			local p = ShipScreenPosition
			RendererWrite(g_render, debugFont, "X = " + position.x , p.x, p.y-0.1, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, debugFont, "Y = " + position.y , p.x, p.y-0.14, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))

			RendererWrite(g_render, debugFont, "x = " + p.x , p.x, p.y-0.18, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))
			RendererWrite(g_render, debugFont, "y = " + p.y , p.x, p.y-0.22, 0.4, true, WriterAlignRight, Vector(1, 1, 1, 1))
		}
*/

	}



	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
//	========================================================================================================
	function	OnSetup(item)
//	========================================================================================================
	{
		rLaps = SceneGetScriptInstance(ItemGetScene(item)).syncBit/2

//      ItemSetPhysicMode(item, PhysicModeDynamic)
		if ("gShipCanRoll" in getroottable())
			ItemPhysicSetAngularFactor(item, Vector(0,0,gShipCanRoll))
		else
			ItemPhysicSetAngularFactor(item, Vector(0,0,0))

		ItemPhysicSetLinearFactor(item, Vector(1,1,0))
//		ItemPhysicSetLinearFactor(item, Vector(1,1,1))
		ItemPhysicSetAngularFactor(item, Vector(1,0,1))

//		ItemSetLinearDamping(item,0.99)
		ItemSetAngularDamping(item,0)

		camera = SceneGetCurrentCamera(g_scene)

//		FFitem		= SceneFindItem(g_scene,"ForceField")
//		FFcolShape 	= SceneFindItem(g_scene,"ForceFieldCol")

//		ItemSetCollisionMask(FFcolShape, 0)

		ResetColTimer = g_clock
	}
}
