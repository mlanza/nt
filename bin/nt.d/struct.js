#!/usr/bin/env deno

import { TextLineStream } from "https://deno.land/std@0.224.0/streams/text_line_stream.ts";

const linesStream = Deno.stdin.readable
  .pipeThrough(new TextDecoderStream())
  .pipeThrough(new TextLineStream());

const list = [];

function countLeadingSpaces(str) {
  return str.match(/^\s*/)[0].length;
}

const clamp = (num, min, max) => Math.min(Math.max(num, min), max)

function getIn(address, obj) {
  if (!address.length) return obj;
  if (obj == null) return undefined;

  const [first, ...rest] = address;
  const next = obj[first];

  if (rest.length === 0) return next;

  return getIn(rest, next);
}

for await (const line of linesStream) {
  const content = line.replaceAll("\t", "  ");
  const indent = countLeadingSpaces(content) / 2;
  const block = content.trim().startsWith("- ");
  const level = clamp(block ? indent : indent - 1, 0, Infinity);
  list.push({level, content, block});
}

const out = [];
let cursor = null;
let lastLineBlank = false;

function handle(line){
  const ctx = getIn(cursor, out);
  const leftward = line.level < ctx.level;
  const rightward = line.level > ctx.level;

  if (line.block || lastLineBlank) {
    if (leftward){
      cursor.pop();
      cursor.pop();
      handle(line);
    } else if (rightward) {
      ctx.children = [line];
      cursor.push("children", 0);
    } else {
      const was = cursor.pop();
      const ctx2 = getIn(cursor, out);
      ctx2.push(line);
      cursor.push(was + 1);
    }
  } else {
    ctx.content += "\n" + line.content;
  }
  lastLineBlank = line.content.trim().length === 0;
}

for(const line of list){
  if (out.length === 0) {
    out.push(line);
    cursor = [0];
  } else {
    handle(line)
  }
}

console.log(JSON.stringify(out, null, 2));
