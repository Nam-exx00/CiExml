/*
    RECAY OPEN SOURCE PROJECT LICENSE

    Copyright 2026 Nam_exx00

    THE PROJECT IS OPEN SOURCE. SUBJECT TO THIS LICENSE, YOU MAY USE, COPY, MODIFY, UPDATE, AND REDISTRIBUTE THE PROJECT. YOU MUST RETAIN THIS LICENSE AND ALL COPYRIGHT NOTICES, AUTHOR ATTRIBUTIONS, AND ATTRIBUTION NOTICES.

    THIS LICENSE CONTAINS A LIMITED COPYLEFT REQUIREMENT. THE OBLIGATION TO PROVIDE SOURCE CODE AND TO LICENSE A MODIFIED VERSION UNDER THIS SAME LICENSE IS TRIGGERED ONLY WHEN YOU DISTRIBUTE A MODIFIED VERSION. DISTRIBUTING AN UNMODIFIED COPY DOES NOT TRIGGER THAT SOURCE CODE OBLIGATION. PRIVATE MODIFICATION WITHOUT DISTRIBUTION ALSO DOES NOT TRIGGER THAT OBLIGATION.

    YOU MAY DISTRIBUTE AN UNMODIFIED COPY IN CLOSED-SOURCE FORM. AN UNMODIFIED COPY DOES NOT HAVE TO BE LICENSED UNDER THIS LICENSE, AND YOU DO NOT HAVE TO PROVIDE ITS SOURCE CODE. HOWEVER, YOU MUST STILL RETAIN THE ORIGINAL COPYRIGHT NOTICES, AUTHOR ATTRIBUTIONS, AND ATTRIBUTION NOTICES, AND YOU MUST NOT FALSELY CLAIM THAT YOU ARE THE AUTHOR, COPYRIGHT OWNER, OR PROJECT OWNER OF THE ORIGINAL PARTS.

    IF YOU DISTRIBUTE A MODIFIED VERSION, YOU MUST LICENSE IT UNDER THIS SAME LICENSE AND YOU MAY NOT RELICENSE IT OR MAKE IT CLOSED SOURCE. YOU MUST PROVIDE THE COMPLETE SOURCE CODE OF THE MODIFIED VERSION TO THE RECIPIENT IN A MANNER THAT ALLOWS THE RECIPIENT TO OBTAIN, RUN, MODIFY, AND REDISTRIBUTE IT. YOU MUST RETAIN THIS LICENSE TEXT, ALL COPYRIGHT NOTICES, AUTHOR ATTRIBUTIONS, AND ATTRIBUTION NOTICES. YOU MUST PROMINENTLY STATE THAT THE VERSION HAS BEEN MODIFIED AND REASONABLY IDENTIFY THE MODIFICATIONS OR THE DATE OF MODIFICATION. YOU MUST NOT IMPOSE ADDITIONAL RESTRICTIONS ON THE RECIPIENT'S RIGHTS UNDER THIS LICENSE. IF THE MODIFIED VERSION INCLUDES THIRD-PARTY CODE OR MATERIALS, YOU MUST ALSO COMPLY WITH THE LICENSES APPLICABLE TO THAT THIRD-PARTY CODE OR MATERIALS.

    WITH RESPECT TO THE ORIGINAL PARTS, YOU COVENANT NOT TO BRING A COPYRIGHT INFRINGEMENT ACTION AGAINST, OR ASSERT COPYRIGHT INFRINGEMENT LIABILITY AGAINST, THE COPYRIGHT HOLDER OR ANY CONTRIBUTOR. THIS COVENANT DOES NOT APPLY TO PORTIONS OF A MODIFIED VERSION ADDED OR MODIFIED BY YOU OR A THIRD PARTY, TO CONDUCT THAT VIOLATES THIS LICENSE, TO PATENT, TRADEMARK, TRADE SECRET, MORAL, OR OTHER NON-COPYRIGHT RIGHTS, OR TO ANY RIGHT THAT CANNOT BE WAIVED, LIMITED, OR EXCLUDED UNDER APPLICABLE LAW. IF THIS COVENANT IS HELD INVALID OR UNENFORCEABLE IN A JURISDICTION, IT SHALL BE INTERPRETED AND ENFORCED TO THE MAXIMUM EXTENT PERMITTED IN THAT JURISDICTION, AND THE REMAINING PROVISIONS SHALL REMAIN IN EFFECT.

    IF YOU VIOLATE ANY TERM OF THIS LICENSE, YOUR LICENSE TERMINATES AUTOMATICALLY. IF YOU CURE THE VIOLATION WITHIN 30 DAYS AFTER RECEIVING WRITTEN NOTICE FROM THE COPYRIGHT HOLDER, THE LICENSE IS REINSTATED AS OF THE DATE OF CURE. THE COPYRIGHT HOLDER MAY ALSO REINSTATE THE LICENSE BY WRITTEN NOTICE. AFTER TERMINATION, YOU MUST STOP USING, COPYING, MODIFYING, AND DISTRIBUTING THE PROJECT AND ANY MODIFIED VERSION, EXCEPT FOR RIGHTS THAT CANNOT BE RESTRICTED UNDER APPLICABLE LAW, SUCH AS FAIR USE.

    THE PROJECT IS PROVIDED "AS IS." THE COPYRIGHT HOLDER AND CONTRIBUTORS MAKE NO EXPRESS OR IMPLIED WARRANTIES, INCLUDING WITHOUT LIMITATION ANY WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, ACCURACY, OR UNINTERRUPTED OR ERROR-FREE OPERATION. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE COPYRIGHT HOLDER AND CONTRIBUTORS SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES ARISING FROM OR RELATED TO THE USE OF OR INABILITY TO USE THE PROJECT OR ANY MODIFIED VERSION, INCLUDING WITHOUT LIMITATION LOSS OF DATA, BUSINESS INTERRUPTION, LOSS OF PROFITS, OR THIRD-PARTY CLAIMS.

    THIS LICENSE DOES NOT REPRESENT THAT IT IS APPROVED BY THE OPEN SOURCE INITIATIVE OR ANY OTHER ORGANIZATION. WHETHER IT QUALIFIES AS AN "OPEN SOURCE LICENSE" DEPENDS ON THE APPLICABLE DEFINITION AND ORGANIZATIONAL RULES. YOU MAY COPY AND DISTRIBUTE THIS LICENSE TEXT VERBATIM, BUT YOU MAY NOT MODIFY THE LICENSE TEXT AND THEN PUBLISH IT UNDER THE NAME "RECAY OPEN SOURCE PROJECT LICENSE." THIS LICENSE DOES NOT AUTOMATICALLY APPLY TO ANY LATER VERSION. IF ANY PROVISION OF THIS LICENSE IS HELD INVALID OR UNENFORCEABLE, IT SHALL BE INTERPRETED TO THE MAXIMUM EXTENT PERMITTED, AND THE REMAINING PROVISIONS SHALL REMAIN IN EFFECT. THIS LICENSE CONSTITUTES THE COMPLETE LICENSE AGREEMENT CONCERNING THE PROJECT AND SUPERSEDES ANY PRIOR ORAL OR WRITTEN LICENSE STATEMENTS ON THE SAME SUBJECT.
*/

module interp;

import core.stdc.stdio;

// Information
enum ramSize = 65536;
enum regCount = 32;
enum vdr = 1; // (0 = Unknown; 1 = NamuhIma Technology)
enum ver = 0;
enum mdl = 1; // (0 = Unknown; 1 = CiExml Interpreter)
enum mdlv = 0;

version (Windows) {
    extern(C) int _getch();
}

uint exec(ubyte[] prog) {
    // Global Storages
    ubyte[ramSize] ram;
    uint[regCount] regs;

    // System Storages
    uint pc;

    // Main
    while (pc < prog.length) {
        switch (prog[pc]) {
            case 0: break; // nxt
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
}