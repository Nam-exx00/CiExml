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

module packer;

import std.typecons;

/*
    CiExml Package Format:
        [Magic]
        [
            [Item Name]
            [Item Data]
        ]
*/

ubyte[] pack(string[string] data) {
    // Prepare Result
    ubyte[] result;
    // Add Items
    foreach (name, dat; data) {
        // Add Name
        foreach (c; name) 
            if (c == '\n' || c == '\\') {
                result ~= '\\';
                result ~= c;
            } else result ~= c;
        result ~= '\n'; // Add EOF
        // Add Data
        foreach (c; dat) 
            if (c == '\n' || c == '\\') {
                result ~= '\\';
                result ~= c;
            } else result ~= c;
        result ~= '\n'; // Add EOF
    }
    // Add EOP
    result ~= '\n';
    result ~= '\n';
    return result;
}

string[string] unpack(ubyte[] data) {
    // Prepare Result
    string[string] result;
    // Get Item Names & Datas
    while (true) {
        // Prepare Information
        string name;
        string dat;
        // Prepare State
        bool stat;
        // Get Item Name
        while (true) {
            if (stat) {
                name ~= data[0];
                stat = false;
            } else if (data[0] == '\\') stat = true;
            else if (data[0] == '\n') {
                data = data[1..$];
                break;
            } else name ~= data[0]; 
            data = data[1..$];
        }
        // Get Item Data
        while (true) {
            if (stat) {
                dat ~= data[0];
                stat = false;
            } else if (data[0] == '\\') stat = true;
            else if (data[0] == '\n') {
                data = data[1..$];
                break;
            } else dat ~= data[0];
            data = data[1..$];
        }
        result[name] = dat;
        if (data[0] == '\n') break;
    }
    return result;
}