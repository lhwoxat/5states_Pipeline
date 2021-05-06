import os
import sys

files = os.listdir()

file_name = ''

if 'Bin2Mem.exe' not in files:
    print('[ERROR] 请将Bin2Mem.exe文件放置在同目录下!')

def find_save():
    for i in sys.argv:
        if i == '-s' or i == '--save':
            return True

def find_file_name():
    for i in sys.argv:
        if i.endswith('.s'):
            return i

if len(sys.argv) == 1:
    if 'main.s' not in files:
        print('[ERROR] 请输入文件名!')
        sys.exit()
    else:
        file_name = 'main'
else:
    f = find_file_name()
    if f is None:
        file_name_with_ends = 'main.s'
    else:
        file_name_with_ends = f
    file_dot_index = file_name_with_ends.find('.')
    file_name = file_name_with_ends[:file_dot_index]

def mips_gcc():
    print(f"[RUNNING] 正在汇编 {file_name}.s ")
    os.system('mips-sde-elf-gcc -c ' + file_name + '.s')


def mips_objcopy():
    print(f"[RUNNING] 正在获取二进制文件")
    os.system(f'mips-sde-elf-objcopy -O binary {file_name}.o {file_name}.bin')


def bin2mem():
    print(f'[RUNNING] 正在获取内存表示')
    os.system(f'.\Bin2Mem {file_name}.bin > {file_name}.txt')


def clean():
    os.system(f'del {file_name}.o')
    os.system(f'del {file_name}.bin')

if __name__ == '__main__':
    mips_gcc()
    mips_objcopy()
    bin2mem()
    print(f'[SUCCESS] 生成内存文件{file_name}.txt')
    if not find_save():
        clean()
    input('任意键以继续...')
