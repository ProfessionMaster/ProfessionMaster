--
-- Copyright (c) 2023 Bryan Morabito, All Rights Reserved.
--

ProfessionMaster = ProfessionMaster or { }
PM = PM or { }
PM.items = PM.items or { }

ProfessionMaster.item_initializer = function()
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, button) 
        if IsControlKeyDown() and button == "RightButton" and self:GetParent():GetID() <= 5 then 
            local item_id = GetContainerItemID(self:GetParent():GetID(), self:GetID())
            -- todo
        end 
    end)
end
