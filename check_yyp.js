const fs = require('fs');
const p = "C:/Projects/TheInfernoCurse/The Inferno's Curse/The Inferno's Curse.yyp";
const txt = fs.readFileSync(p, 'utf8');
const crlf = (txt.match(/\r\n/g) || []).length;
const lf = (txt.match(/(?<!\r)\n/g) || []).length;
console.log('CRLF:', crlf, 'LF only:', lf);
console.log('BOM:', fs.readFileSync(p).subarray(0,3));
