Config = {}

Config.lang = 'en'

Config.blips = {
    { coords = vector3(-1201.59,-1569.73,4.6), sprite = 311, color = 3, scale = 0.6, label = 'Gym' }
}

Config.stopExerciseKey = 'F'

Config.Exercises = {
    ['pushups'] = {
        startDict = 'amb@world_human_push_ups@male@enter',
        startClip = 'enter',
        starttime = 3050,
        actionDict = 'amb@world_human_push_ups@male@base',
        actionClip = 'base',
        actionTime = 2000,
        exitDict = 'amb@world_human_push_ups@male@exit',
        exitClip = 'exit',
        exitTime = 3400,
    },
    ['situps'] = {
        startDict = 'amb@world_human_sit_ups@male@enter',
        startClip = 'enter',
        starttime = 4200,
        actionDict = 'amb@world_human_sit_ups@male@base',
        actionClip = 'base',
        actionTime = 2000,
        exitDict = 'amb@world_human_sit_ups@male@exit',
        exitClip = 'exit',
        exitTime = 3700,
    },
    ['chinups'] = {
        startDict = 'amb@prop_human_muscle_chin_ups@male@idle_a',
        startClip = 'idle_a',
        starttime = 1600,
        actionDict = 'amb@prop_human_muscle_chin_ups@male@base',
        actionClip = 'base',
        actionTime = 2000,
        exitDict = 'amb@prop_human_muscle_chin_ups@male@exit',
        exitClip = 'exit',
        exitTime = 1200,
    },
    ['bicep'] = {
        actionDict = 'amb@world_human_muscle_free_weights@male@barbell@base',
        actionClip = 'base',
        actionTime = 2000,

        prop = { model = `prop_curl_bar_01`, bone = 28422, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    },
    ['treadmill'] = {
        actionDict = 'move_characters@franklin@fire',
        actionClip = 'run',
        actionTime = 2000,
    }
}

Config.locationsAction = 'E'
Config.locations = {
    { coords = vector4(-1199.69, -1563.66, 4.62, 303.31), distance = 2, exercise = 'pushups' },
    { coords = vector4(-1207.3, -1565.86, 4.6, 124.73),   distance = 2, exercise = 'pushups' },
}

Config.entities = {
    { entity = `prop_muscle_bench_05`, distance = 2, exercise = 'chinups', offset = vector4(0.0, 0.8, -0.7, 180.0) },
    { entity = `prop_muscle_bench_01`, distance = 2, exercise = 'situps',  offset = vector4(0.0, -0.3, 0.5, 0.0) },
    { entity = `prop_weight_squat`, distance = 2, exercise = 'bicep',  offset = vector4(0.0, -0.5, -0.7, 0.0) },
    { entity = `apa_p_apdlc_treadmill_s`, distance = 2, exercise = 'treadmill',  offset = vector4(0.0, 0.0, 0.0, 180.0) },
}
