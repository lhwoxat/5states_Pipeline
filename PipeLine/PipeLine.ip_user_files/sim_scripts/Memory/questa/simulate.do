onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib Memory_opt

do {wave.do}

view wave
view structure
view signals

do {Memory.udo}

run -all

quit -force
