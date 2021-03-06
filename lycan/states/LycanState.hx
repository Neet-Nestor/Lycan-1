package lycan.states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import lycan.util.MasterCamera;
import lycan.core.LG;

// Base state for all substates in a game
class LycanState extends FlxSubState {
	public var uiGroup(default, null):FlxSpriteGroup;
	public var uiCamera(default, null):FlxCamera;
	public var worldCamera(default, null):MasterCamera;

	public var worldZoom(default, set):Float;
	public var baseZoom:Float;

	public var zoomTween(default, null):FlxTween;

	// Tweens that should be cancelled before another tween of the same ID plays
	public var exclusiveTweens:Map<String, FlxTween>;
	
	public var overlay:FlxSprite;
	public var overlayColor(default, set):FlxColor;
	
	// TODO use these
	public var onEnter:FlxTypedSignal<LycanState->Void>;
	public var onExit:FlxTypedSignal<LycanState->Void>;
	
	// TODO
	public var rootState(get, never):LycanRootState;
	public var parentState(get, never):LycanState;
	
	override public function create():Void {
		super.create();
		
		exclusiveTweens = new Map<String, FlxTween>();
		
		// Cameras TODO messy removal of original camera
		worldCamera = new MasterCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y),
		                         FlxG.camera.width, FlxG.camera.height, FlxG.camera.zoom);
		uiCamera = new FlxCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y),
		                         FlxG.camera.width, FlxG.camera.height, FlxG.camera.zoom);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.remove(FlxG.camera);
		FlxG.camera = worldCamera;
		FlxG.cameras.add(worldCamera);
		FlxG.cameras.add(uiCamera);
		
		FlxCamera.defaultCameras = [worldCamera];

		baseZoom = worldCamera.zoom;
		worldZoom = 1;
		
		// UI
		uiGroup = new FlxSpriteGroup();
		uiGroup.scrollFactor.set(0, 0);
		uiGroup.cameras = [uiCamera];
		add(uiGroup);
		overlay = new FlxSprite();
		overlay.scrollFactor.set();
		overlayColor = FlxColor.BLACK;
		overlay.alpha = 0;
		uiGroup.add(overlay);
		
		// Signals
		onEnter = new FlxTypedSignal<LycanState->Void>();
		onExit = new FlxTypedSignal<LycanState->Void>();
	}

	override public function destroy():Void {
		super.destroy();

		// TODO fix camera setup - make sure we don't cause mem leaks by leaving refs to cameras on state + on FlxG
		FlxG.cameras.remove(worldCamera);
		FlxG.cameras.remove(uiCamera);

		FlxCamera.defaultCameras = [];

	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		LG.lateUpdate.dispatch(dt);
	}
	
	override public function switchTo(state:FlxState):Bool {
		if (Std.is(state, LycanState)) {
			onExit.dispatch(cast state);
		}
		return super.switchTo(state);
		// TODO figure out where in flixel we need to dispatch onEnter
	}
	
	public function exclusiveTween(id:String, object:Dynamic, values:Dynamic, duration:Float = 1, ?options:TweenOptions):FlxTween {
		if (exclusiveTweens.exists(id)) {
			exclusiveTweens.get(id).cancel();
		}
		var tween:FlxTween = FlxTween.tween(object, values, duration, options);
		exclusiveTweens.set(id, tween);
		return tween;
	}

	public function zoomTo(zoom:Float, duration:Float = 0.5, ?ease:Float->Float):FlxTween {
		if (ease == null) {
			ease = FlxEase.quadInOut;
		}
		if (zoomTween != null) {
			zoomTween.cancel();
		}
		zoomTween = FlxTween.tween(this, { worldZoom: zoom }, duration, { type: FlxTweenType.ONESHOT, ease: ease } );
		return zoomTween;
	}

	// Sets world and camera zoom
	private function set_worldZoom(worldZoom:Float):Float {
		worldCamera.zoom = baseZoom * worldZoom;
		
		return this.worldZoom = worldZoom;
	}
	
	private function set_overlayColor(color:FlxColor):FlxColor {
		overlayColor = color;
		overlay.makeGraphic(FlxG.width, FlxG.height, color, true, "lycan.states.LycanState.overlay");
		return color;
	}
	
	private function get_parentState():LycanState {
		return cast _parentState;
	}
	
	private function get_rootState():LycanRootState {
		return LycanRootState.get;
	}
	
	// TODO autotweening
	// TODO camera targeting
	// TODO sound fading
}