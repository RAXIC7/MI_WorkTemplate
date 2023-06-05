Config = {}
Config.debug = true

Config.jobname = 'job1'

Config.wblip = {
    loc = vector3(354.602, -589.552, 28.796),
    sprite = 1,
    color = 3,
    scale = 0.8,
    name = 'job1 location'
}

Config.boss_ped = {
    model = 's_f_y_scrubs_01',
    loc = vector4(349.55, -587.444, 28.796, 251.272)
}

Config.vehicle_ped = {
    model = 's_m_m_paramedic_01',
    loc = vector4(336.246, -589.631, 28.796, 341.906)
}

Config.vehicle = {
    loc = vector3(332.327, -577.777, 28.529),
    head = 340.212
}

-- peds
Config.job1 = {
    [1] = {
        loc = vector4(367.744, -582.756, 28.709, 141.773),
        model = 's_f_y_scrubs_01',
        payment = math.random(200, 400)
    }
}

-- objects
Config.job2 = {
    [1] = {
        loc = vector4(369.758, -587.116, 28.731, 111.993),
        model = 'thing_here',
        payment = math.random(200, 400)
    }
}