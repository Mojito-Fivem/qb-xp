# qb-xp
XP System for QBCore Framework

## How to install
Add the following to your QBCore/Server/Player.lua:62
```
PlayerData.metadata["xp"] = PlayerData.metadata["xp"] ~= nil and PlayerData.metadata["xp"] or 0
PlayerData.metadata["rank"] = PlayerData.metadata["rank"] ~= nil and PlayerData.metadata["rank"] or 0
```
#### Do not ask me how to implement this, if you cannot figure out how to use exports then do not attempt, I will not help you with it.
