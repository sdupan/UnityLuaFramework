local PlayerModel = class("PlayerModel", require("Model.BaseModel"))

function PlayerModel:ctor()
    PlayerModel.super.ctor(self)
    self.currentBtlScene = 0
    self.playerInfo = {
        gameInBackground = false,
        musicOpen = true,
        soundEffectOpen = true,
        playerId = "",
        nickName = "",
        totalCoin = 0,
        totalDiamond = 0,
    }
end

return PlayerModel