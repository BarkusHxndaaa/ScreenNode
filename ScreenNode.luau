--!strict
local RunService = game:GetService('RunService');

local Camera = workspace.CurrentCamera;

local ScreenNode = {};
ScreenNode.__index = ScreenNode;

local ApplyProperties:(Instance,{[string]:any}) -> () = function(Object,Properties)
    assert(typeof(Properties) == 'table');
    for i,v in Properties do
        pcall(function()
            Object[i] = v;
        end);
    end;
end;

local CreateClass:(string) -> GuiObject = function(ClassName)
    local Success,Object = pcall(function()
        return Instance.new(ClassName);
    end);

    if not Object:IsA('GuiObject') then
        Object:Destroy();
        return Instance.new('Frame');
    end;

    if not Success then
        return Instance.new('Frame');
    end;

    return Object;
end;

function ScreenNode.new(Object:GuiObject|string,Properties:{[string]:any}?,WorldPosition:Vector3)
    assert(RunService:IsClient(),`ScreenNode can only be created on the client`);
    assert(typeof(WorldPosition) == 'Vector3',`ScreenNode - WorldPosition is not a Vector3`);
    local self = setmetatable({},ScreenNode);

    if typeof(Object) == 'string' then
        self.Object = CreateClass(Object);
    else
        assert(Object:IsA('GuiObject'),'ScreenNode - did not pass a valid object')
        self.Object = Object;
    end;
    self.Position = WorldPosition;
    self.CameraDataCache = {XHalf = Camera.ViewportSize.X / 2, ClampedY = Camera.ViewportSize.Y - (Camera.ViewportSize.Y * 0.075)};
    self.IsOnScreen = true;
    self.OnScreenChanged = Instance.new('BindableEvent');

    if Properties then
        ApplyProperties(self.Object,Properties);
    end;
    self.Object.AnchorPoint = Vector2.new(0.5,0.5);

    return self;
end;

function ScreenNode:Render()
    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(self.Position);
    if ScreenPosition.Z < 0 then
        local FixedXPosition = self.CameraDataCache.XHalf - ScreenPosition.X;
        ScreenPosition = Vector3.new(self.CameraDataCache.XHalf + FixedXPosition,Camera.ViewportSize.Y);
    end;

    if OnScreen ~= self.IsOnScreen then
        self.OnScreenChanged:Fire(OnScreen);
        self.IsOnScreen = OnScreen;
    end;

    self.Object.Position = UDim2.fromOffset(math.clamp(ScreenPosition.X,0,Camera.ViewportSize.X),math.clamp(ScreenPosition.Y,0,self.CameraDataCache.ClampedY));
end;

function ScreenNode:StartRendering()
    assert(self.Object,`ScreenNode - Tried to render with no UI object found - {debug.traceback()}`);
    if typeof(self.RenderUpdate) == 'RBXScriptConnection' then return end;
    self.Object.Visible = true;
    self.RenderUpdate = RunService.RenderStepped:Connect(function()
        self:Render();
    end);
end;

function ScreenNode:StopRendering(HideObject:boolean?)
    if typeof(self.RenderUpdate) == 'RBXScriptConnection' then
        self.RenderUpdate:Disconnect();
    end;
    self.Object.Visible = HideObject or false;
end;

function ScreenNode:Destroy()
    for i,v in self do
        if typeof(v) == 'RBXScriptConnection' then
            v:Disconnect();
        elseif typeof(v) == 'table' then
            table.clear(v);
        elseif typeof(v) == 'Instance' then
            v:Destroy();
        end;
        self[i] = nil;
    end;
end;

return ScreenNode;
