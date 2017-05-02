-- place this file in autorun or execute it somehow

-- the palette wouldn't initialise after mapchange without a delayed restart

timer(1200, "dofile", "badapple/badapple.lua")
timer(1000, "dofile", "badapple/bitmap-gamedev.lua")