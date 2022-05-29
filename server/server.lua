-- Based on Malik's and Blue's animal shelters and vorp animal shelter --

local VorpCore = {}


TriggerEvent("getCore",function(core)
    VorpCore = core
end)
VORP = exports.vorp_core:vorpAPI()