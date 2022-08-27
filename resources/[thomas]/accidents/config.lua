Config = {}
-- The belt 

-- Disable/enable sounds
Config.Sounds = true
Config.LoopSound = false
Config.Volume = 0.1
-- Min: 0.0 Max: 1.0

-- Disable/enable Notifications
Config.Notification = true
Config.Strings = {seatbelt_on = '~g~Ceinture Attachée', seatbelt_off = '~r~Ceinture Détachée'}
-- Change to your own translations.

-- Disable/enable blinker image
Config.Blinker = true

-- Seatbelt button (docs.fivem.net/docs/game-references/controls)
Config.Control = 311

-- KM/H (must be have decimal value)
Config.Speed = 55.0

Config.AlarmOnlySpeed = true
Config.AlarmSpeed = 25

-- Accident effects

-- Amount of Time to Blackout, in milliseconds
-- 2000 = 2 seconds
Config.BlackoutTime = 4000

--[[ Config.Effect = {
    Time = {8 ,13 ,19 ,25 ,33},
    Damage = {15, 25, 45, 65, 100}
    Speed = {20, 45, 65,95, 130}
} ]]

Config.EffectTimeLevel1 = 5
Config.EffectTimeLevel2 = 15
Config.EffectTimeLevel3 = 40
Config.EffectTimeLevel4 = 50
Config.EffectTimeLevel5 = 60

-- Enable blacking out due to vehicle damage
-- If a vehicle suffers an impact greater than the specified value, the player blacks out
Config.BlackoutDamageRequiredLevel1 = 20
Config.BlackoutDamageRequiredLevel2 = 30
Config.BlackoutDamageRequiredLevel3 = 40
Config.BlackoutDamageRequiredLevel4 = 50
Config.BlackoutDamageRequiredLevel5 = 50

-- Enable blacking out due to speed deceleration
-- If a vehicle slows down rapidly over this threshold, the player blacks out
Config.BlackoutSpeedRequiredLevel1 = 40 -- Speed in MPH
Config.BlackoutSpeedRequiredLevel2 = 45
Config.BlackoutSpeedRequiredLevel3 = 50
Config.BlackoutSpeedRequiredLevel4 = 60
Config.BlackoutSpeedRequiredLevel5 = 70

-- Enable the disabling of controls if the player is blacked out
Config.DisableControlsOnBlackout = true
Config.TimeLeftToEnableControls = 6

-- Multiplier of screen shaking strength
Config.ScreenShakeMultiplier = 0.4