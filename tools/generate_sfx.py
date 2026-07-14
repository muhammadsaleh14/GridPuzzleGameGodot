#!/usr/bin/env python3
"""Generate short UI sound effects as 16-bit mono WAV files."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SR = 44100
OUT = Path("audio")


def clamp(x: float) -> float:
	return max(-1.0, min(1.0, x))


def write_wav(name: str, samples: list[float]) -> None:
	path = OUT / name
	with wave.open(str(path), "w") as wf:
		wf.setnchannels(1)
		wf.setsampwidth(2)
		wf.setframerate(SR)
		frames = b"".join(struct.pack("<h", int(clamp(s) * 32767)) for s in samples)
		wf.writeframes(frames)
	print(f"wrote {path} ({len(samples) / SR:.3f}s)")


def env_adsr(i: int, n: int, a=0.01, d=0.08, s=0.55, r=0.2) -> float:
	t = i / n
	if t < a:
		return t / a
	if t < a + d:
		return 1.0 - (1.0 - s) * ((t - a) / d)
	if t < 1.0 - r:
		return s
	return s * max(0.0, (1.0 - t) / r)


def tone(freq: float, duration: float, vol=0.35, shape="sine") -> list[float]:
	n = int(SR * duration)
	out: list[float] = []
	for i in range(n):
		t = i / SR
		phase = 2 * math.pi * freq * t
		if shape == "square":
			v = 1.0 if math.sin(phase) >= 0 else -1.0
			v *= 0.35
		elif shape == "triangle":
			v = 2 * abs(2 * ((freq * t) % 1) - 1) - 1
			v *= 0.55
		else:
			v = math.sin(phase)
			# soft harmonic
			v += 0.25 * math.sin(2 * phase)
			v *= 0.7
		out.append(v * vol * env_adsr(i, n))
	return out


def mix(*clips: list[float]) -> list[float]:
	length = max(len(c) for c in clips)
	out = [0.0] * length
	for clip in clips:
		for i, s in enumerate(clip):
			out[i] += s
	peak = max(abs(s) for s in out) or 1.0
	if peak > 0.95:
		out = [s * (0.95 / peak) for s in out]
	return out


def silence(duration: float) -> list[float]:
	return [0.0] * int(SR * duration)


def concat(*clips: list[float]) -> list[float]:
	out: list[float] = []
	for c in clips:
		out.extend(c)
	return out


def main() -> None:
	OUT.mkdir(exist_ok=True)

	# Soft UI button press
	write_wav(
		"sfx_ui_tap.wav",
		mix(tone(420, 0.05, 0.28, "triangle"), tone(680, 0.04, 0.12, "sine")),
	)

	# Tile toggle — crisp short blip
	write_wav(
		"sfx_tile_toggle.wav",
		mix(tone(760, 0.045, 0.32, "triangle"), tone(1140, 0.03, 0.14, "sine")),
	)

	# Success — bright rising triad
	write_wav(
		"sfx_success.wav",
		concat(
			mix(tone(523.25, 0.12, 0.28), tone(659.25, 0.12, 0.18)),
			silence(0.02),
			mix(tone(659.25, 0.12, 0.28), tone(783.99, 0.12, 0.18)),
			silence(0.02),
			mix(tone(783.99, 0.18, 0.32), tone(1046.5, 0.18, 0.2)),
		),
	)

	# Fail — soft descending minor
	write_wav(
		"sfx_fail.wav",
		concat(
			mix(tone(392, 0.14, 0.3, "triangle"), tone(466.16, 0.14, 0.12)),
			silence(0.03),
			mix(tone(311.13, 0.22, 0.28, "triangle"), tone(233.08, 0.22, 0.16)),
		),
	)

	# Slider tick — tiny
	write_wav("sfx_slider.wav", tone(980, 0.025, 0.18, "sine"))

	# Clock tick — muted wood-like pulse
	write_wav(
		"sfx_tick.wav",
		mix(tone(880, 0.035, 0.16, "triangle"), tone(220, 0.04, 0.1, "sine")),
	)

	# Phase start / memorize cue
	write_wav(
		"sfx_phase.wav",
		mix(tone(349.23, 0.1, 0.22), tone(523.25, 0.12, 0.18)),
	)


if __name__ == "__main__":
	main()
