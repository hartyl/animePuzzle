local music = love.audio.newQueueableSource(10000,8,4, 10)--(love.sound.newSoundData('BeepBox-Song.mid'))
music:play()
music:queue(love.sound.newSoundData('BeepBox-Song.mid'))
