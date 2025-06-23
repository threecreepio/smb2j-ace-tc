
const fs = require('fs');
const loader_bin = fs.readFileSync('./payload_loader.nes');
const payload_ram = fs.readFileSync('./payload_ram.bin');
const payload_prg = fs.readFileSync('./payload_prg.bin');
const payload_ppu = fs.readFileSync('./payload_ppu.bin');

// convert two bytes into TAS file inputs
function toInputs(ctls) {
    let keys = '';
    if (ctls[0] & 0x80) keys += 'A';
    if (ctls[0] & 0x40) keys += 'B';
    if (ctls[0] & 0x20) keys += 'S';
    if (ctls[0] & 0x10) keys += 'T';
    if (ctls[0] & 0x08) keys += 'U';
    if (ctls[0] & 0x04) keys += 'D';
    if (ctls[0] & 0x02) keys += 'L';
    if (ctls[0] & 0x01) keys += 'R';
    keys += '|';
    if (ctls[1] & 0x80) keys += 'A';
    if (ctls[1] & 0x40) keys += 'B';
    if (ctls[1] & 0x20) keys += 'S';
    if (ctls[1] & 0x10) keys += 'T';
    if (ctls[1] & 0x08) keys += 'U';
    if (ctls[1] & 0x04) keys += 'D';
    if (ctls[1] & 0x02) keys += 'L';
    if (ctls[1] & 0x01) keys += 'R';
    return keys;
}

// set up initial 32 byte 
const code = Array.from(loader_bin.slice(0x50, 0x70));
let inputs = [];
let target = 0x50;

// these bytes need to be force cleared to make room
for (let n=0x58; n<0x60; ++n) {
    inputs.push([0x86, n]);
    inputs.push([0x46, n]);
    inputs.push([0x46, n]);
    inputs.push([0x00, 0x00]);
}

let prev = 0;
for (let n=0; n<code.length; ++n) {
    let c = code[n];
    if (!c) continue;
    let tgt = target + n;
    let v = [];
    for (let b=0; c; ++b) {
        if (b) v.unshift([0x06, tgt]);
        if (c & 0x1) {
            v.unshift([0xE6, tgt]);
        }
        // if we're switching inputs, we need a blank between to reset if they both have select or start in them
        if ((tgt & 0x30) && (prev & 0x30) && (tgt !== prev)) {
            v.unshift([0, 0]);
        }
        c >>= 1;
    }
    inputs.push(...v);
    prev = tgt;
}
inputs.push([0x0, 0x0]);
inputs.push([0x20, target]);

// convert trampoline into tas inputs
let result = [];
for (let i=0; i<inputs.length; i+=4) {
    if (i) result.push([0, 0]);
    result.push([0x6C, 0x8D]);
    result.push([0x6C, 0x8D]);
    result.push([0, 0]);
    for (let n=i; n<i+4; ++n) {
        if (inputs[n]) {
            result.push(inputs[n]);
        } else {
            result.push([0, 0]);
        }
    }
}

// now add bytes for the second stage, which the trampoline will load
for (let n=0; n<0x80; ++n) {
    result.push([loader_bin[0x200 + n], 0]);
}

// then add our actual payloads..

//// RAM 300-7FF
for (let n=0x300; n<0x800; n += 2) {
    result.push([payload_ram[n + 0], payload_ram[n + 1]]);
}

// PRG
for (let n=0; n<payload_prg.byteLength; n += 2) {
    result.push([payload_prg[n + 0], payload_prg[n + 1]]);
}

// PPU
for (let n=0; n<payload_ppu.byteLength; n += 2) {
    result.push([payload_ppu[n + 0], payload_ppu[n + 1]]);
}

// and convert the entire thing into a tas
console.log(`TAS ${result.length}`);
for (let n of result) console.log(toInputs(n));
