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
    All CiExml Package Elements Are Little-Endian.

    CiExml Package Format:
        [Magic 3-Bytes]
        [Version 1-Byte]
        [Item Count 4-Bytes]
        [
            [Item Name Length 4-Bytes]
            [Item Name n-Byte(s)]
            [Item Data Length 4-Bytes]
            [Item Data n-Byte(s)]
        ]
*/

ubyte[] pack(string[string] data) {
    // Prepare Result
    ubyte[] result;
    // Add Magic
    result ~= 'C';
    result ~= 'e';
    result ~= 'p';
    // Add Version
    result ~= 1;
    // Add Item Count
    result ~= cast(ubyte)data.length;
    result ~= cast(ubyte)(data.length >> 8);
    result ~= cast(ubyte)(data.length >> 16);
    result ~= cast(ubyte)(data.length >> 24);
    // Add Items
    foreach (name, dat; data) {
        // Add Name
        result ~= cast(ubyte)name.length;
        result ~= cast(ubyte)(name.length >> 8);
        result ~= cast(ubyte)(name.length >> 16);
        result ~= cast(ubyte)(name.length >> 24);
        foreach (c; name)
            result ~= c;
        // Add Data
        result ~= cast(ubyte)dat.length;
        result ~= cast(ubyte)(dat.length >> 8);
        result ~= cast(ubyte)(dat.length >> 16);
        result ~= cast(ubyte)(dat.length >> 24);
        foreach (c; dat)
            result ~= c;
    }
    return result;
}

string[string] unpack(ubyte[] data) {
    // Prepare Result
    string[string] result;
    // Check Magic
    if (data[0] == 'C' && data[1] == 'e' && data[2] == 'p') {
        data = data[3..$];
        // Check Version
        if (data[0] == 1) {
            data = data[1..$];
            // Get Item Count
            const count = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
            data = data[4..$];
            // Get Item Names & Datas
            for (auto p = 0; p < count; p++) {
                // Prepare Information
                string name;
                string dat;
                // Get Item Name
                auto len = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
                data = data[4..$];
                for (auto t = 0; t < len; t++) {
                    name ~= data[0];
                    data = data[1..$];
                }
                // Get Item Data
                len = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
                data = data[4..$];
                for (auto t = 0; t < len; t++) {
                    dat ~= data[0];
                    data = data[1..$];
                }
                result[name] = dat;
            }
            return result;
        } else throw new Exception("Unsupported Version");
    } else throw new Exception("Magic is not found");
}