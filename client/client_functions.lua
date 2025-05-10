
function startExerciseSuccess(exercise, coord)
    LocalPlayer.state.blockAnim = true
end

function stepExerciseSuccess(exercise, coord)
    TriggerServerEvent('player:downgradeStress',1)
end

function finishExerciseSuccess(exercise, coord)
    LocalPlayer.state.blockAnim = false
end

function notify(text)
    TriggerEvent("pth_notify", 'important', text, 5000)
    --lib.notify({title = 'Gym',description = text,type = 'inform'})    
end