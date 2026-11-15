/*
    Copyright 2026 Nam-exx00

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

module interp;

import core.stdc.stdio;
import packer;

// Information
enum ramSize = 1024;
enum regCount = 32;
enum vdr = 1; // (0 = Unknown; 1 = NamuhIma Technology)
enum ver = 0;
enum mdl = 1; // (0 = Unknown; 1 = CiExml Interpreter)
enum mdlv = 0;

version (Windows) {
    extern(C) int _getch();
}

uint exec(ubyte[] pkg) {
    // Unpackage
    auto sections = unpack(pkg);
    const format = sections["Program Format"];
    const data = sections["Constant Data"];
    const prog = sections["Program Bytecode"];

    // Check
    if (format == "The CiExml Programming Language Standard Executable") {

        // Global Storages
        ubyte[ramSize] ram;
        uint[regCount] regs;

        // System Storages
        uint pc;
        
        // Alloc
        for (auto p = 0; p < data.length; p++)
            ram[p] = data[p];

        // Main
        while (pc < prog.length) {
            switch (prog[pc]) {
                case 0: // nxt
                    pc++;
                    break;
                case 1: // li
                    regs[0] = prog[pc+1];
                    pc += 2;
                    break;
                case 2: // li16
                    regs[0] = prog[pc+1] | (prog[pc+2] << 8);
                    pc += 3;
                    break;
                case 3: // li24
                    regs[0] = prog[pc+1] | (prog[pc+2] << 8) | (prog[pc+3] << 16);
                    pc += 4;
                    break;
                case 4: // li32
                    regs[0] = prog[pc+1] | (prog[pc+2] << 8) | (prog[pc+3] << 16) | (prog[pc+4] << 24);
                    pc += 5;
                    break;
                case 5: // eq
                    regs[prog[pc+1]] = regs[prog[pc+2]];
                    pc += 3;
                    break;
                case 6: // ld
                    regs[0] = ram[regs[0]];
                    pc++;
                    break;
                case 7: // ld16
                    regs[0] = ram[regs[0]] | (ram[regs[0]+1] << 8);
                    pc++;
                    break;
                case 8: // ld24
                    regs[0] = ram[regs[0]] | (ram[regs[0]+1] << 8) | (ram[regs[0]+2] << 16);
                    pc++;
                    break;
                case 9: // ld32
                    regs[0] = ram[regs[0]] | (ram[regs[0]+1] << 8) | (ram[regs[0]+2] << 16) | (ram[regs[0]+3] << 24);
                    pc++;
                    break;
                case 10: // str
                    ram[regs[0]] = cast(ubyte)regs[1];
                    pc++;
                    break;
                case 11: // str16
                    ram[regs[0]] = cast(ubyte)regs[1];
                    ram[regs[0]+1] = cast(ubyte)(regs[1] >> 8);
                    pc++;
                    break;
                case 12: // str24
                    ram[regs[0]] = cast(ubyte)regs[1];
                    ram[regs[0]+1] = cast(ubyte)(regs[1] >> 8);
                    ram[regs[0]+2] = cast(ubyte)(regs[1] >> 16);
                    pc++;
                    break;
                case 13: // str32
                    ram[regs[0]] = cast(ubyte)regs[1];
                    ram[regs[0]+1] = cast(ubyte)(regs[1] >> 8);
                    ram[regs[0]+2] = cast(ubyte)(regs[1] >> 16);
                    ram[regs[0]+3] = cast(ubyte)(regs[1] >> 24);
                    pc++;
                    break;
                case 14: // add
                    regs[0] += regs[1];
                    pc++;
                    break;
                case 15: // sub
                    regs[0] -= regs[1];
                    pc++;
                    break;
                case 16: // and
                    regs[0] &= regs[1];
                    pc++;
                    break;
                case 17: // or
                    regs[0] |= regs[1];
                    pc++;
                    break;
                case 18: // xor
                    regs[0] ^= regs[1];
                    pc++;
                    break;
                case 19: // ls
                    regs[0] <<= regs[1];
                    pc++;
                    break;
                case 20: // rs
                    regs[0] >>= regs[1];
                    pc++;
                    break;
                case 21: // ars
                    regs[0] = cast(int)regs[0] >> cast(int)regs[1];
                    pc++;
                    break;
                case 22: // neq
                    regs[0] = (regs[0] != regs[1]) ? 1 : 0;
                    pc++;
                    break;
                case 23: // lt
                    regs[0] = (regs[0] < regs[1]) ? 1 : 0;
                    pc++;
                    break;
                case 24: // go
                    pc = regs[0];
                    break;
                case 25: // gn
                    pc = !regs[0] ? regs[1] : pc + 1;
                    break;
                case 26: // vdr
                    regs[0] = vdr;
                    pc++;
                    break;
                case 27: // ver
                    regs[0] = ver;
                    pc++;
                    break;
                case 28: // mdl
                    regs[0] = mdl;
                    pc++;
                    break;
                case 29: // mdlv
                    regs[0] = mdlv;
                    pc++;
                    break;
                case 30: // sys
                    /* System instruction options are not be standard cinset instruction sets */
                    switch (regs[0]) {
                        case 0: return regs[1]; // qit
                        case 1: // in
                            version (Windows) {
                                regs[0] = _getch();
                            } else version (Posix) {
                                import core.sys.posix.termios;
                                import core.sys.posix.unistd;
                                termios oldt, newt;
                                tcgetattr(STDIN_FILENO, &oldt);
                                newt = oldt;
                                newt.c_lflag &= ~(ICANON | ECHO);
                                tcsetattr(STDIN_FILENO, TCSANOW, &newt);
                                read(STDIN_FILENO, &regs[0], 1);
                                tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
                            } else return 3; // StandardInputNotFoundException
                            break;
                        case 2: // out
                            putchar(regs[1]);
                            break;
                        default: return 2; // InvalidSystemIDException
                    }
                    pc++;
                    break;
                default: return 1; // InvalidOpcodeException
            }
        }

        return regs[0];
    } else return 4; // UnsupportedProgramFormatException
}