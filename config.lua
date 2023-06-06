Config = {}
Config.debug = true

Config.jobname = { 'job1', 'job2' }
Config.joblabel = 'My Company'

Config.wblip = {
    loc = vector3(354.602, -589.552, 28.796),
    sprite = 1,
    color = 3,
    scale = 0.8,
    name = 'job1 location'
}

Config.jobstash_id = 'job1'
Config.jobstash_label = 'Job 1 Lockers'
Config.jobstash_slots = 20
Config.jobstash_weight = 100000
Config.jobstash = {
    loc = vector3(346.71, -588.35, 28.796),
    head = 245
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
    deposit = 150,
    loc = vector3(332.327, -577.777, 28.529),
    head = 340.212
}

-- peds
Config.job1 = {
    payment = math.random(100, 200),
    [1] = {
        loc = vector4(353.595, -584.149, 28.796, 123.693),
        model = 'mp_f_chbar_01',
    },
    [2] = {
        loc = vector4(355.691, -584.674, 28.796, 161.454),
        model = 'mp_m_famdd_01',
    }
}

-- objects
Config.job2 = {
    payment = math.random(200, 300),
    [1] = {
        loc = vector4(353.595, -584.149, 28.796, 123.693),
        object = 'v_ind_cm_electricbox',
    },
    [2] = {
        loc = vector4(355.691, -584.674, 28.796, 161.454),
        object = 'v_ind_cm_electricbox',
    }
}