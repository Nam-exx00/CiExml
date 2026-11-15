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

import std.stdio;
import std.string;
import std.file : writeFile = write, read, FileException;

import build;
import packer;
import interp;

int main(string[] args) {
    try {
        for (auto p = 0; p < args.length; p++)
            while (args[p][0] == '-')
                args[p] = args[p][1..$];
        if (args.length == 0)
            args[0] = "cie";
        if (args.length < 2) {
            writeln("Usage:");
            writefln("\t'%s' -> Get Help", args[0]);
            writefln("\t'%s' <code> -> Run with <code>.", args[0]);
            writefln("\t'%s' <file.exml> -> Run with <file.exml>.", args[0]);
            writefln("\t'%s' <file.crp> -> Run with <file.crp>.", args[0]);
            writefln("\t'%s' <file.exml> <prog.crp> -> Build & Package <file.exml> To <prog.crp>.", args[0]);
            /*version (Windows) {
                writefln("\t'%s' <prog.exe> <file.exml> -> Build & Package <file.exml> To <prog.exe>.", args[0]);
            }*/
            writefln("\t'%s' version -> Display version.", args[0]);
        } else if (args[1] == "version") {
            writeln("The CiExml Programming Language Interpreter Snapshot 20261115-00");
            writeln("Copyright Nam_exx00");
        } else if (args.length == 2) {
            const name = args[1];
            void[] file;
            try file = read(name);
            catch (FileException) file = cast(void[])name;
            if (name.endsWith(".crp")) return exec(cast(ubyte[])file);
            else return exec(gen(cast(string)file));
        } else if (args.length == 3) {
            const src = args[1];
            const dst = args[2];
            void[] file;
            try file = read(src);
            catch (FileException) file = cast(void[])src;
            writeFile(dst, gen(cast(string)file));
        } else throw new Exception("Too Many Arguments");

        return 0;
    } catch (Throwable e) {
        writefln("Fatal error: \x1b[31m%s.\x1b[0m", e.msg);
        debug throw e;
        return 1;
    }
}