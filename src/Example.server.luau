local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupServiceWrapper = require(ReplicatedStorage.GroupServiceWrapper)

local UserId = 24941
local GroupId = 107778

-- Func Testing
print(GroupServiceWrapper:GetGroupInfo(GroupId))
print(GroupServiceWrapper:GetPlayerGroups(UserId))
print(GroupServiceWrapper:GetPlayerRolesInGroup(UserId, GroupId))
print(GroupServiceWrapper:HasRole(UserId, GroupId, 255))
print(GroupServiceWrapper:GetPlayerHighestRole(UserId, GroupId))
print(GroupServiceWrapper:GetPlayerLowestRole(UserId, GroupId))
print(GroupServiceWrapper:PlayerHasRoleGreaterThan(UserId, GroupId, 250))
print(GroupServiceWrapper:PlayerHasRoleLessThan(UserId, GroupId, 250))
print(GroupServiceWrapper:GetPlayerHighestRoleName(UserId, GroupId))
print(GroupServiceWrapper:IsPlayerInGroup(UserId, GroupId))