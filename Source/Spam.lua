
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Services = ReplicatedStorage
    :WaitForChild("Shared")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
local PartyRF = Services:WaitForChild("PartyService"):WaitForChild("RF")
local ProximityRF = Services:WaitForChild("ProximityService"):WaitForChild("RF")
local start = os.clock()
local duration = 3.5
local conn
conn = RunService.RenderStepped:Connect(function()
    if os.clock() - start >= duration then
        conn:Disconnect()
        return
    end
    PartyRF.CreateParty:InvokeServer("Golem")
    ProximityRF.Functionals:InvokeServer(
        Workspace.Proximity.CreateParty
    )
    PartyRF.Activate:InvokeServer()
end)
