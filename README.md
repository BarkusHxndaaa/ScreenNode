# ScreenNode
Open-source Luau module for ScreenNode - for use on Roblox


## API
```luau
ScreenNode.new(Object:GuiObject|string,Properties:{[string]:any}?,WorldPosition:Vector3)
```
Used to create a new ScreenNode. You can pass a pre-existing GuiObject or create a new class by passing the ClassName as a string. You can also apply properties.
**The anchor point of a ScreenNode will automatically be set to (0.5,0.5)**

```luau
ScreenNode:StartRendering()
```
Used to start rendering the ScreenNode. Will error if the ScreenNode GuoObject instance was destroyed.

```luau
ScreenNode:StopRendering()
```
Used to stop rendering the ScreenNode.

```luau
ScreenNode:Destroy()
```
Used to destroy the ScreenNode and all associated instances

# Events
```luau
local newScreenNode = ScreenNode.new('Frame',nil,Vector3.zero)
newScreenNode.OnScreenChanged.Event:Connect(function(onScreen:boolean)
  print(`Is on screen - {onScreen}`)
end)
```
A BindableEvent that is fired then the OnScreen value changes

If you have any issues, feel free to contact me on [Roblox](https://www.roblox.com/users/167251552/profile) or [Twitter](https://x.com/BarkusHxndaaa)
