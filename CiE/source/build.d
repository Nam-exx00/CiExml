/*
    Copyright 2026 Nam_exx00

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

module build;

import packer;

import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.range;
import core.exception;

// Generate
ubyte[] gen(string code) {
    // Storages
    string[string] result;
    ubyte[] prog;
    ubyte[] data;

    // Temps
    string[string] consts = new string[string];
    uint[][uint] delVars;

    // Build Exceptions
    void epath(string path) {
        throw new Exception("Cannot find '" ~ path ~ "' in all syntaxes");
    }    

    auto lines = code.split('\n');
    for (auto p = 0; p < lines.length; p++) {
        auto line = lines[p].strip;
        auto argv = line.split(" with ");
        auto com = argv.length ? argv[0].strip : null;
        if (!line.startsWith("note") && line.length) {
            try {
                consts["bytes of the bytecode"] = "unsigned " ~ prog.length.to!string;
                consts["bytes of the constant data"] = "unsigned " ~ prog.length.to!string;
                consts["bytes of the format"] = "unsigned " ~ prog.length.to!string;

                auto path = com.split(" in ").retro.array;
                
                switch (path[0].strip) {
                    case "create a new constant":
                        auto v = argv[2].strip;
                        if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith('\'') && v.endsWith('\''))) {
                            bool escaping = false;
                            auto s = consts.get(v[1..v.length-1], v[1..v.length-1]);
                            string converted;
                            for (auto ptr = 0; ptr < s.length; ptr++)
                                if (escaping) {
                                    switch (s[ptr]) {
                                        // Ordinary
                                        case 'a':
                                            converted ~= '\a';
                                            break;
                                        case 'b':
                                            converted ~= '\b';
                                            break;
                                        case 'f':
                                            converted ~= '\f';
                                            break;
                                        case 'n':
                                            converted ~= '\n';
                                            break;
                                        case 'r':
                                            converted ~= '\r';
                                            break;
                                        case 't':
                                            converted ~= '\t';
                                            break;
                                        case 'v':
                                            converted ~= '\v';
                                            break;
                                        // Special
                                        case 'x':
                                            converted ~= s[ptr+1..ptr+3].to!ubyte(16);
                                            ptr += 2;
                                            break;
                                        default: converted ~= s[ptr];
                                    }
                                    escaping = false;
                                } else if (s[ptr] == '\\') escaping = true;
                                else converted ~= s[ptr];
                            consts[argv[1].strip] = converted;
                        } else consts[argv[1].strip] = consts.get(v, v);
                        break;
                    case "application":
                        switch (path[1].strip) {
                            case "inject a new constant data":
                                auto s = consts.get(argv[1].strip, argv[1].strip);
                                if (s.startsWith("byte")) data ~= s[4..$].strip.to!byte;
                                else if (s.startsWith("unsigned byte")) data ~= s[13..$].strip.to!ubyte;
                                else if (s.startsWith("short")) {
                                    auto temp = s[5..$].strip.to!short;
                                    data ~= cast(ubyte)temp;
                                    data ~= cast(ubyte)(temp >> 8);
                                } else if (s.startsWith("unsigned short")) {
                                    auto temp = s[14..$].strip.to!ushort;
                                    data ~= cast(ubyte)temp;
                                    data ~= cast(ubyte)(temp >> 8);
                                } else if (s.startsWith("number")) {
                                    auto temp = s[6..$].strip.to!int;
                                    data ~= cast(ubyte)temp;
                                    data ~= cast(ubyte)(temp >> 8);
                                    data ~= cast(ubyte)(temp >> 16);
                                    data ~= cast(ubyte)(temp >> 24);
                                } else if (s.startsWith("unsigned")) {
                                    auto temp = s[9..$].strip.to!uint;
                                    data ~= cast(ubyte)temp;
                                    data ~= cast(ubyte)(temp >> 8);
                                    data ~= cast(ubyte)(temp >> 16);
                                    data ~= cast(ubyte)(temp >> 24);
                                } else foreach (c; s) data ~= c;
                                break;
                            case "inject a new bytecode":
                                auto s = consts.get(argv[1].strip, argv[1].strip);
                                if (s.startsWith("byte")) prog ~= s[4..$].strip.to!byte;
                                else if (s.startsWith("unsigned byte")) prog ~= s[13..$].strip.to!ubyte;
                                else if (s.startsWith("short")) {
                                    auto temp = s[5..$].strip.to!short;
                                    prog ~= cast(ubyte)temp;
                                    prog ~= cast(ubyte)(temp >> 8);
                                } else if (s.startsWith("unsigned short")) {
                                    auto temp = s[14..$].strip.to!ushort;
                                    prog ~= cast(ubyte)temp;
                                    prog ~= cast(ubyte)(temp >> 8);
                                } else if (s.startsWith("number")) {
                                    auto temp = s[6..$].strip.to!int;
                                    prog ~= cast(ubyte)temp;
                                    prog ~= cast(ubyte)(temp >> 8);
                                    prog ~= cast(ubyte)(temp >> 16);
                                    prog ~= cast(ubyte)(temp >> 24);
                                } else if (s.startsWith("unsigned")) {
                                    auto temp = s[9..$].strip.to!uint;
                                    prog ~= cast(ubyte)temp;
                                    prog ~= cast(ubyte)(temp >> 8);
                                    prog ~= cast(ubyte)(temp >> 16);
                                    prog ~= cast(ubyte)(temp >> 24);
                                } else foreach (c; s) prog ~= c;
                                break;
                            default: epath(path[1]);
                        }
                        break;
                    case "create a new variable":
                        auto name = consts.get(argv[1].strip, argv[1].strip);
                        auto value = consts.get(argv[2].strip, argv[2].strip);
                        consts["location of " ~ name] = "unsigned " ~ data.length.to!string;
                        if (value.startsWith("byte")) {
                            try {
                                auto addr = delVars[1][$-1];
                                delVars[1] = delVars[1][0..$-1];
                                data[addr] = value[4..$].strip.to!byte;
                                consts["location of " ~ name] = "unsigned " ~ addr.to!string;
                            } catch (RangeError) data ~= value[4..$].strip.to!byte;
                            consts["size of " ~ name] = "unsigned 1";
                        } else if (value.startsWith("unsigned byte")) {
                            try {
                                auto addr = delVars[1][$-1];
                                delVars[1] = delVars[1][0..$-1];
                                data[addr] = value[13..$].strip.to!ubyte;
                                consts["location of " ~ name] = "unsigned " ~ addr.to!string;
                            } catch (RangeError) data ~= value[13..$].strip.to!ubyte;
                            consts["size of " ~ name] = "unsigned 1";
                        } else if (value.startsWith("short")) {
                            auto number = value[5..$].strip.to!short;
                            try {
                                auto addr = delVars[2][$-1];
                                delVars[2] = delVars[2][0..$-1];
                                data[addr] = cast(ubyte)number;
                                data[addr+1] = cast(ubyte)(number >> 8);
                                consts["location of " ~ name] = "unsigned " ~ addr.to!string;
                                consts["size of " ~ name] = "unsigned 2";
                            } catch (RangeError) {
                                data ~= cast(ubyte)number;
                                data ~= cast(ubyte)(number >> 8);
                                consts["size of " ~ name] = "unsigned 2";
                            }
                        } else if (value.startsWith("unsigned short")) {
                            auto number = value[14..$].strip.to!ushort;
                            try {
                                auto addr = delVars[2][$-1];
                                delVars[2] = delVars[2][0..$-1];
                                data[addr] = cast(ubyte)number;
                                data[addr+1] = cast(ubyte)(number >> 8);
                                consts["location of " ~ name] = "unsigned " ~ addr.to!string;
                                consts["size of " ~ name] = "unsigned 2";
                            } catch (RangeError) {
                                data ~= cast(ubyte)number;
                                data ~= cast(ubyte)(number >> 8);
                                consts["size of " ~ name] = "unsigned 2";
                            }
                        } else if (value.startsWith("number")) {
                            auto number = value[6..$].strip.to!int;
                            try {
                                auto addr = delVars[4][$-1];
                                delVars[4] = delVars[4][0..$-1];
                                data[addr] = cast(ubyte)number;
                                data[addr+1] = cast(ubyte)(number >> 8);
                                data[addr+2] = cast(ubyte)(number >> 16);
                                data[addr+3] = cast(ubyte)(number >> 24);
                                consts["location of " ~ name] = "unsigned " ~ addr.to!string;
                                consts["size of " ~ name] = "unsigned 4";
                            } catch (RangeError) {
                                data ~= cast(ubyte)number;
                                data ~= cast(ubyte)(number >> 8);
                                data ~= cast(ubyte)(number >> 16);
                                data ~= cast(ubyte)(number >> 24);
                                consts["size of " ~ name] = "unsigned 4";
                            }
                        } else if (value.startsWith("unsigned")) {
                            auto number = value[8..$].strip.to!int;
                            try {
                                auto addr = delVars[4][$-1];
                                delVars[4] = delVars[4][0..$-1];
                                data[addr] = cast(ubyte)number;
                                data[addr+1] = cast(ubyte)(number >> 8);
                                data[addr+2] = cast(ubyte)(number >> 16);
                                data[addr+3] = cast(ubyte)(number >> 24);
                                consts["location of " ~ name] = "unsigned " ~ addr.to!string;
                                consts["size of " ~ name] = "unsigned 4";
                            } catch (RangeError) {
                                data ~= cast(ubyte)number;
                                data ~= cast(ubyte)(number >> 8);
                                data ~= cast(ubyte)(number >> 16);
                                data ~= cast(ubyte)(number >> 24);
                                consts["size of " ~ name] = "unsigned 4";
                            }
                        } else throw new Exception("Unsupported Type");
                        break;
                    case "remove a variable":
                        auto name = consts.get(argv[1].strip, argv[1].strip);
                        // Get Address & Length String
                        auto saddr = consts["location of " ~ name];
                        auto slen = consts["size of " ~ name];
                        // Check Are They Unsigned
                        if (saddr.startsWith("unsigned") && slen.startsWith("unsigned")) {
                            // Remove Address & Length Constants
                            consts.remove("location of " ~ name);
                            consts.remove("size of " ~ name);
                            // Throw to deleted variables
                            auto addr = saddr[8..$].strip.to!uint;
                            auto len = slen[8..$].strip.to!uint;
                            delVars[len] = delVars.get(len, []) ~ addr;
                        } else throw new Exception("Unsupported Type");
                        break;
                    default: epath(path[0]);
                }
            } catch (Throwable e) {
                writefln("Fatal error: \x1b[31m%s.\x1b[0m", e.msg);
                debug throw e;
            }
        }
    }
    
    // Package
    result["Program Format"] = "The CiExml Programming Language Standard Executable";
    result["Constant Data"] = cast(string)data;
    result["Program Bytecode"] = cast(string)prog;

    return pack(result);
}