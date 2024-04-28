/*

MIT License

Copyright (c) 2023 PCSX-Redux authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

#include "psyqo/trigonometry.hh"

// This is a table generator for cos(n * 2pi / 2048) * 2^24
// The table is 512 entries long, from cos(0) to cos(pi/2).
// The table is generated by the following recurrence relation:
// f(n) = cos(n * 2pi / 2048)
// f(n) = 2 * f(1) * f(n - 1) - f(n - 2)
void psyqo::TrigInternals::generateTable(eastl::array<int32_t, 512>& table, unsigned precisionBits) {
    // 2^24 * cos(0 * 2pi / 2048)
    table[0] = 16777216;
    // 2^24 * cos(1 * 2pi / 2048) = C = f(1)
    constexpr int64_t C = 16777137;
    table[1] = C;

    for (int i = 2; i < 511; i++) {
        table[i] = ((C * table[i - 1]) >> 23) - table[i - 2];
    }

    // The approximation is a bit too steep, so this value would otherwise
    // get slightly negative
    table[511] = 0;

    // Adjusts the precision of the table
    if (precisionBits > 24) {
        for (int i = 0; i < 512; i++) {
            table[i] <<= (precisionBits - 24);
        }
    } else if (precisionBits < 24) {
        for (int i = 0; i < 512; i++) {
            table[i] >>= (24 - precisionBits);
        }
    }
}
