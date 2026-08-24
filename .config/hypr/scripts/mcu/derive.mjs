#!/usr/bin/env node
// Runs Google's own material-color-utilities (SchemeTonalSpot, the default
// Material You style) on a pixel dump, and prints BOTH the dark and light
// 36-role schemes as JSON -- one seed, one set of tonal palettes, two tone
// tables applied to it. Called by m3-from-wallpaper.py.
//
// Usage: node derive.mjs <pixels.json> [contrastLevel]
//   pixels.json: a JSON array of ARGB ints (0xFFRRGGBB), one per sampled pixel
//   contrastLevel: -1..1, passed straight to SchemeTonalSpot (default 0)
import { readFileSync } from 'fs';
import {
  QuantizerCelebi, Score, Hct, SchemeTonalSpot, MaterialDynamicColors,
} from '@material/material-color-utilities';

const [, , pixelsPath, contrastArg] = process.argv;
if (!pixelsPath) {
  console.error('usage: derive.mjs <pixels.json> [contrastLevel]');
  process.exit(2);
}

const pixels = JSON.parse(readFileSync(pixelsPath, 'utf8'));
const contrastLevel = contrastArg ? parseFloat(contrastArg) : 0.0;

// The official pipeline, unmodified: quantize down to 128 clusters, then rank
// by Google's own Score (population-weighted, with a bonus for chroma above
// 48 and a hue-neighbour smoothing window) and take the top result.
const quantized = QuantizerCelebi.quantize(pixels, 128);
const ranked = Score.score(quantized);
const sourceArgb = ranked[0];

const hex = (argb) => '#' + ((argb >>> 0) & 0xffffff).toString(16).padStart(6, '0');

const sourceHct = Hct.fromInt(sourceArgb);

// Same 36 role names m3-from-wallpaper.py has always used, so the QML/Lua/
// hyprlang output format needs no changes -- only where the colours come
// from changed.
const roles = [
  'primary', 'onPrimary', 'primaryContainer', 'onPrimaryContainer', 'inversePrimary',
  'secondary', 'onSecondary', 'secondaryContainer', 'onSecondaryContainer',
  'tertiary', 'onTertiary', 'tertiaryContainer', 'onTertiaryContainer',
  'error', 'onError', 'errorContainer', 'onErrorContainer',
  'background', 'onBackground', 'surface', 'onSurface', 'surfaceDim', 'surfaceBright',
  'surfaceContainerLowest', 'surfaceContainerLow', 'surfaceContainer',
  'surfaceContainerHigh', 'surfaceContainerHighest',
  'inverseSurface', 'inverseOnSurface', 'shadow', 'scrim',
  'surfaceVariant', 'onSurfaceVariant', 'outline', 'outlineVariant',
];

function schemeFor(isDark) {
  const scheme = new SchemeTonalSpot(sourceHct, isDark, contrastLevel);
  const roleMap = {};
  for (const r of roles) roleMap[r] = hex(MaterialDynamicColors[r].getArgb(scheme));
  return roleMap;
}

const out = {
  seed: hex(sourceArgb), hue: sourceHct.hue, chroma: sourceHct.chroma, tone: sourceHct.tone,
  dark: schemeFor(true),
  light: schemeFor(false),
};

process.stdout.write(JSON.stringify(out));
