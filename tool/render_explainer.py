"""Renders Education's film on structured notes to assets/videos/.

A silent motion-graphics explainer in Keel's colours: what a structured
note is, then a protected floor, a cap, a buffer and an autocall, each
played out as a market path against what the note pays.

    python3 -I tool/render_explainer.py

Needs Pillow, numpy and ffmpeg (libx264). Frames are drawn at twice the
output size and scaled down, for smooth edges.
"""

import math
import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "videos", "structured_notes.mp4")
POSTER = os.path.join(ROOT, "assets", "videos", "structured_notes.jpg")

W, H = 1280, 720
S = 2  # supersampling
FPS = 30

TIDE = (11, 61, 145)
TIDE_DEEP = (8, 44, 107)
NIGHT = (5, 20, 52)
AZURE = (30, 111, 224)
FOAM = (191, 214, 250)
NOTE = (140, 196, 255)
WHITE = (255, 255, 255)
LOSS = (224, 122, 138)
GOLD = (242, 196, 92)
GOLD_DEEP = (196, 146, 46)


def font(name, size):
    return ImageFont.truetype(name, int(size * S))


SF_BOLD = "/Library/Fonts/SF-Pro-Display-Bold.otf"
SF_MED = "/Library/Fonts/SF-Pro-Display-Medium.otf"
if not os.path.exists(SF_BOLD):
    SF_BOLD = SF_MED = os.path.join(ROOT, "assets", "fonts", "SourceSans3-Semibold.ttf")


# ---------------------------------------------------------------- easing

def clamp(x, a=0.0, b=1.0):
    return max(a, min(b, x))


def ease(x):
    x = clamp(x)
    return 4 * x * x * x if x < 0.5 else 1 - (-2 * x + 2) ** 3 / 2


def ease_out(x):
    x = clamp(x)
    return 1 - (1 - x) ** 3


def span(t, a, b):
    """0 before a, 1 after b, linear between."""
    return clamp((t - a) / (b - a)) if b > a else float(t >= a)


def mix(c1, c2, k):
    return tuple(int(round(c1[i] + (c2[i] - c1[i]) * k)) for i in range(3))


def alpha(c, a):
    return (*c, int(round(255 * clamp(a))))


# ---------------------------------------------------------------- canvas

def background():
    """The tide gradient, with a soft glow, drawn once."""
    y = np.linspace(0, 1, H * S)[:, None]
    x = np.linspace(0, 1, W * S)[None, :]
    k = clamp_arr(0.55 * y + 0.45 * (1 - x))
    base = np.zeros((H * S, W * S, 3))
    for i in range(3):
        base[..., i] = NIGHT[i] + (TIDE[i] - NIGHT[i]) * k
    glow = np.exp(-(((x - 0.72) / 0.35) ** 2 + ((y - 0.25) / 0.45) ** 2))
    for i in range(3):
        base[..., i] += glow * (AZURE[i] - base[..., i]) * 0.22
    return Image.fromarray(base.clip(0, 255).astype(np.uint8), "RGB")


def clamp_arr(a):
    return np.clip(a, 0, 1)


class Frame:
    def __init__(self, bg):
        self.img = bg.copy().convert("RGBA")
        self.layer = Image.new("RGBA", self.img.size, (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.layer)

    def flush(self):
        self.img = Image.alpha_composite(self.img, self.layer)
        self.layer = Image.new("RGBA", self.img.size, (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.layer)

    def glow(self, draw_fn, radius=18):
        """Draw with a soft halo underneath."""
        halo = Image.new("RGBA", self.img.size, (0, 0, 0, 0))
        draw_fn(ImageDraw.Draw(halo))
        halo = halo.filter(ImageFilter.GaussianBlur(radius * S / 2))
        self.flush()
        self.img = Image.alpha_composite(self.img, halo)
        draw_fn(self.d)

    def text(self, xy, s, f, fill, anchor="la"):
        self.d.text((xy[0] * S, xy[1] * S), s, font=f, fill=fill, anchor=anchor)

    def done(self):
        self.flush()
        return self.img.convert("RGB").resize((W, H), Image.LANCZOS)


def P(x, y):
    return (x * S, y * S)


def poly(d, pts, fill, width):
    pts = [P(*p) for p in pts]
    if len(pts) < 2:
        return
    d.line(pts, fill=fill, width=int(width * S), joint="curve")
    r = width * S / 2
    for p in (pts[0], pts[-1]):
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=fill)


def dashed(d, pts, fill, width, on=10, off=9):
    """A polyline cut into dashes along its length."""
    acc, draw_on, seg = 0.0, True, [pts[0]]
    for a, b in zip(pts, pts[1:]):
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        pos = 0.0
        while pos < L:
            left = (on if draw_on else off) - acc
            step = min(left, L - pos)
            pos += step
            acc += step
            p = (a[0] + dx * pos / L, a[1] + dy * pos / L) if L else a
            if draw_on:
                seg.append(p)
            if acc >= (on if draw_on else off) - 1e-6:
                if draw_on and len(seg) > 1:
                    d.line([P(*q) for q in seg], fill=fill, width=int(width * S))
                draw_on = not draw_on
                acc = 0.0
                seg = [p]
    if draw_on and len(seg) > 1:
        d.line([P(*q) for q in seg], fill=fill, width=int(width * S))


def dot(d, c, r, fill):
    d.ellipse([(c[0] - r) * S, (c[1] - r) * S, (c[0] + r) * S, (c[1] + r) * S], fill=fill)


def keel_mark(d, cx, cy, size, color, a=1.0):
    """Keel's mark, as the app draws it."""
    w = h = size
    ox, oy = cx - w / 2, cy - h / 2

    def pt(x, y):
        return P(ox + w * x, oy + h * y)

    def cubic(p0, p1, p2, p3, n=24):
        out = []
        for i in range(n + 1):
            t = i / n
            mt = 1 - t
            out.append((
                mt**3 * p0[0] + 3 * mt * mt * t * p1[0] + 3 * mt * t * t * p2[0] + t**3 * p3[0],
                mt**3 * p0[1] + 3 * mt * mt * t * p1[1] + 3 * mt * t * t * p2[1] + t**3 * p3[1],
            ))
        return out

    fill = alpha(color, a)
    hull = [(0.06, 0.42), (0.94, 0.42)]
    hull += cubic((0.94, 0.42), (0.86, 0.62), (0.68, 0.66), (0.5, 0.66))[1:]
    hull += cubic((0.5, 0.66), (0.32, 0.66), (0.14, 0.62), (0.06, 0.42))[1:]
    d.polygon([pt(*p) for p in hull], fill=fill)
    fin = [(0.44, 0.6), (0.56, 0.6), (0.535, 0.9), (0.5, 0.94), (0.465, 0.9)]
    d.polygon([pt(*p) for p in fin], fill=fill)
    d.polygon([pt(0.52, 0.06), pt(0.52, 0.36), pt(0.8, 0.36)], fill=fill)
    d.polygon([pt(0.47, 0.14), pt(0.47, 0.36), pt(0.27, 0.36)], fill=alpha(color, a * 0.6))


def coin(d, cx, cy, r, a=1.0):
    """A coin seen edge-on from slightly above."""
    h = r * 0.34
    d.rectangle([(cx - r) * S, cy * S, (cx + r) * S, (cy + h) * S], fill=alpha(GOLD_DEEP, a))
    d.ellipse([(cx - r) * S, (cy + h - r * 0.38) * S, (cx + r) * S, (cy + h + r * 0.38) * S],
              fill=alpha(GOLD_DEEP, a))
    d.ellipse([(cx - r) * S, (cy - r * 0.38) * S, (cx + r) * S, (cy + r * 0.38) * S],
              fill=alpha(GOLD, a))
    d.ellipse([(cx - r * 0.62) * S, (cy - r * 0.22) * S, (cx + r * 0.62) * S, (cy + r * 0.22) * S],
              outline=alpha(GOLD_DEEP, a * 0.7), width=int(2 * S))


def padlock(d, cx, cy, size, color, a=1.0, open_k=0.0):
    """A padlock; open_k lifts the shackle."""
    bw, bh = size, size * 0.78
    top = cy - bh / 2
    lift = open_k * size * 0.28
    sw = size * 0.13
    r = size * 0.32
    d.arc([(cx - r) * S, (top - r - lift) * S, (cx + r) * S, (top + r - lift) * S],
          180, 360, fill=alpha(color, a), width=int(sw * S))
    d.line([P(cx - r + sw / 2 - sw / 2, top - lift), P(cx - r + sw / 2 - sw / 2, top + 4)],
           fill=alpha(color, a), width=int(sw * S))
    d.line([P(cx + r - sw / 2 + sw / 2, top - lift), P(cx + r - sw / 2 + sw / 2, top + 4 - lift * 0)],
           fill=alpha(color, a), width=int(sw * S))
    d.rounded_rectangle([(cx - bw / 2) * S, top * S, (cx + bw / 2) * S, (top + bh) * S],
                        radius=int(size * 0.16 * S), fill=alpha(color, a))
    kh = size * 0.12
    dot(d, (cx, top + bh * 0.42), kh * 0.55, alpha(TIDE_DEEP, a))
    d.rectangle([(cx - kh * 0.22) * S, (top + bh * 0.42) * S, (cx + kh * 0.22) * S,
                 (top + bh * 0.68) * S], fill=alpha(TIDE_DEEP, a))


# ---------------------------------------------------------------- chart

CHART = (150, 170, 1130, 560)  # x0, y0, x1, y1
Y_MIN, Y_MAX = -0.45, 0.55


def cy_of(v):
    x0, y0, x1, y1 = CHART
    return y1 - (clamp(v, Y_MIN, Y_MAX) - Y_MIN) / (Y_MAX - Y_MIN) * (y1 - y0)


def cx_of(t):
    x0, _, x1, _ = CHART
    return x0 + t * (x1 - x0)


def path_at(path, t):
    x = clamp(t) * (len(path) - 1)
    i = int(math.floor(x))
    if i >= len(path) - 1:
        return path[-1]
    return path[i] + (path[i + 1] - path[i]) * (x - i)


def smooth(points, n=240):
    """A smooth market path through control points."""
    xs = np.linspace(0, 1, len(points))
    t = np.linspace(0, 1, n)
    base = np.interp(t, xs, points)
    rng = np.random.default_rng(7)
    noise = np.convolve(rng.normal(0, 0.012, n), np.ones(9) / 9, mode="same")
    noise[0] = noise[-1] = 0
    edge = np.minimum(t, 1 - t) * 8
    return list(base + noise * np.clip(edge, 0, 1))


def chart_frame(f, a):
    x0, y0, x1, y1 = CHART
    d = f.d
    for v in (-0.4, -0.2, 0.2, 0.4):
        d.line([P(x0, cy_of(v)), P(x1, cy_of(v))], fill=alpha(FOAM, 0.07 * a), width=int(1 * S))
    d.line([P(x0, cy_of(0)), P(x1, cy_of(0))], fill=alpha(FOAM, 0.4 * a), width=int(2 * S))


def pct(v):
    """A whole-percent figure, never "-0%"."""
    n = round(v * 100)
    return "0%" if n == 0 else f"{n:+d}%"


def readouts(f, market, note, a, note_color=NOTE):
    big, small = font(SF_BOLD, 64), font(SF_MED, 26)
    f.text((1130, 70), pct(note), big, alpha(note_color, a), anchor="ra")
    label = pct(market)
    width = f.d.textlength(label, font=small) / S
    # The market's dashed swatch sits just before its figure.
    dashed(f.d, [(1130 - width - 42, 155), (1130 - width - 12, 155)],
           alpha(WHITE, 0.6 * a), 3, 6, 5)
    f.text((1130, 140), label, small, alpha(WHITE, 0.65 * a), anchor="ra")


def heading(f, s, a, y=74):
    f.text((150, y), s, font(SF_BOLD, 44), alpha(WHITE, a))


def play_scene(f, t, path, payoff, a, zones, title, draw_t=(0.6, 5.6), lock=None):
    """One payoff scene: the market drawn over the term, the note over it."""
    chart_frame(f, a)
    zones(f, a)
    heading(f, title, a * ease_out(span(t, 0.0, 0.6)))
    k = ease(span(t, *draw_t))
    n = max(2, int(len(path) * k))
    ts = np.linspace(0, k, n)
    market = [(cx_of(x), cy_of(path_at(path, x))) for x in ts]
    note = [(cx_of(x), cy_of(payoff(path_at(path, x)))) for x in ts]
    dashed(f.d, market, alpha(WHITE, 0.62 * a), 3.2, 11, 9)
    m = path_at(path, k)
    v = payoff(m)
    col = LOSS if round(v * 100) < 0 else NOTE
    # The note's line in blue while it holds, in red where it loses.
    runs, cur = [], []
    for x, pt in zip(ts, note):
        neg = round(payoff(path_at(path, x)) * 100) < 0
        if cur and cur[0] != neg:
            runs.append(cur)
            cur = [neg, cur[-1]]
        if not cur:
            cur = [neg]
        cur.append(pt)
    runs.append(cur)

    def lines(d, width, k):
        for run in runs:
            poly(d, run[1:], alpha(LOSS if run[0] else NOTE, k * a), width)

    f.glow(lambda d: lines(d, 9, 0.55), 14)
    lines(f.d, 5.5, 1.0)
    head_m, head_n = market[-1], note[-1]
    dot(f.d, head_m, 9, alpha(WHITE, 0.25 * a))
    dot(f.d, head_m, 5.5, alpha(WHITE, a))
    dot(f.d, head_n, 14, alpha(col, 0.28 * a))
    dot(f.d, head_n, 8, alpha(col, a))
    readouts(f, m, v, a * ease_out(span(t, 0.4, 1.0)), col)
    if lock:
        lock(f, a, k)


# ---------------------------------------------------------------- scenes

def scene_intro(f, t, a):
    """The mark, then principal dropping into a note that wraps it."""
    k = ease_out(span(t, 0.0, 0.9))
    keel_mark(f.d, 640, 250 - 20 * (1 - k), 150, WHITE, a * k)
    f.text((640, 372), "Structured notes", font(SF_BOLD, 64),
           alpha(WHITE, a * ease_out(span(t, 0.5, 1.3))), anchor="ma")
    # Coins: your principal, dropping into three stacks.
    for s_i, (sx, count) in enumerate(((560, 3), (640, 5), (720, 4))):
        for i in range(count):
            st = 1.7 + s_i * 0.25 + i * 0.16
            kk = ease_out(span(t, st, st + 0.45))
            y = 610 - i * 19 - (1 - kk) * 110
            coin(f.d, sx, y, 34, a * kk)


def floor_zone(f, a):
    x0, _, x1, y1 = CHART
    f.d.rectangle([x0 * S, cy_of(0) * S, x1 * S, y1 * S], fill=alpha(FOAM, 0.08 * a))


def floor_lock(f, a, k):
    kk = ease_out(span(k, 0.55, 0.8))
    padlock(f.d, CHART[0] - 62, cy_of(0) + 4, 46, FOAM, a * kk)


def cap_zone(cap):
    def draw(f, a):
        x0, _, x1, _ = CHART
        dashed(f.d, [(x0, cy_of(cap)), (x1, cy_of(cap))], alpha(FOAM, 0.55 * a), 2, 9, 8)
    return draw


def buffer_zone(buf):
    def draw(f, a):
        x0, _, x1, _ = CHART
        f.d.rectangle([x0 * S, cy_of(0) * S, x1 * S, cy_of(-buf) * S], fill=alpha(FOAM, 0.12 * a))
        dashed(f.d, [(x0, cy_of(-buf)), (x1, cy_of(-buf))], alpha(FOAM, 0.5 * a), 2, 9, 8)
    return draw


def autocall_zone(barrier, checks):
    def draw(f, a):
        x0, _, x1, _ = CHART
        dashed(f.d, [(x0, cy_of(barrier)), (x1, cy_of(barrier))], alpha(LOSS, 0.5 * a), 2, 9, 8)
        for c in checks:
            x = cx_of(c)
            f.d.line([P(x, CHART[1] + 40), P(x, CHART[3])], fill=alpha(FOAM, 0.12 * a), width=int(2 * S))
    return draw


def scene_autocall(f, t, a):
    """Checks on set dates: above the start, the note ends early with its coupon."""
    path = smooth([0, -0.08, -0.14, -0.05, 0.04, 0.09, 0.12])
    checks = [1 / 3, 2 / 3]
    autocall_zone(-0.3, checks)(f, a)
    chart_frame(f, a)
    heading(f, "Autocall", a * ease_out(span(t, 0, 0.6)))
    call_at = 2 / 3
    k = ease(span(t, 0.6, 5.0)) * call_at
    n = max(2, int(len(path) * k / call_at * call_at))
    ts = np.linspace(0, k, max(2, int(240 * k)))
    market = [(cx_of(x), cy_of(path_at(path, x))) for x in ts]
    dashed(f.d, market, alpha(WHITE, 0.62 * a), 3.2, 11, 9)
    m = path_at(path, k)
    dot(f.d, market[-1], 5.5, alpha(WHITE, a))
    for c in checks:
        if k >= c - 1e-3:
            above = path_at(path, c) >= 0
            col = NOTE if above else alpha(FOAM, 1)[:3]
            dot(f.d, (cx_of(c), cy_of(path_at(path, c))), 12, alpha(col, 0.3 * a))
            dot(f.d, (cx_of(c), cy_of(path_at(path, c))), 7, alpha(col, a))
    called = span(t, 5.0, 5.6)
    coupon = 0.08 * ease_out(called)
    readouts(f, m, coupon, a * ease_out(span(t, 0.4, 1.0)))
    if called > 0:
        # The note ends: principal and coupon come back as coins.
        cx, cy = cx_of(call_at), cy_of(path_at(path, call_at))
        for i in range(4):
            kk = ease_out(span(t, 5.0 + i * 0.12, 5.8 + i * 0.12))
            coin(f.d, cx + 60 + i * 0, cy - 40 - kk * (120 + i * 26), 24, a * kk)


def scene_end(f, t, a):
    k = ease_out(span(t, 0, 0.8))
    keel_mark(f.d, 520, 360, 130, WHITE, a * k)
    f.text((600, 360), "Keel", font(SF_BOLD, 96), alpha(WHITE, a * k), anchor="lm")


def ppn(m):
    return max(0.0, m)


def capped(m):
    return clamp(m, 0.0, 0.3)


def buffered(m):
    return min(m, 0.4) if m >= 0 else (0.0 if m > -0.2 else m + 0.2)


SCENES = [
    (5.0, scene_intro),
    (6.5, lambda f, t, a: play_scene(
        f, t, smooth([0, 0.05, -0.04, -0.12, -0.2, -0.15, -0.22]), ppn, a,
        floor_zone, "A protected floor", lock=floor_lock)),
    (6.5, lambda f, t, a: play_scene(
        f, t, smooth([0, 0.06, 0.12, 0.1, 0.24, 0.36, 0.45]), capped, a,
        cap_zone(0.3), "Upside, up to a cap")),
    (6.5, lambda f, t, a: play_scene(
        f, t, smooth([0, -0.04, -0.1, -0.08, -0.16, -0.24, -0.32]), buffered, a,
        buffer_zone(0.2), "A buffer takes the first hit")),
    (6.5, scene_autocall),
    (3.0, scene_end),
]
FADE = 0.45


def poster_frame(bg):
    """The poster: the mark above and the principal below, the middle left
    clear for the play mark the app sets over it."""
    f = Frame(bg)
    keel_mark(f.d, 640, 190, 120, WHITE)
    for sx, count in ((560, 3), (640, 5), (720, 4)):
        for i in range(count):
            coin(f.d, sx, 600 - i * 19, 34)
    return f.done()


def render():
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    bg = background()
    total = sum(d for d, _ in SCENES)
    frames = int(total * FPS)
    proc = subprocess.Popen(
        ["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
         "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
         "-c:v", "libx264", "-preset", "slow", "-crf", "24", "-pix_fmt", "yuv420p",
         "-movflags", "+faststart", OUT],
        stdin=subprocess.PIPE,
    )
    for i in range(frames):
        t = i / FPS
        start = 0.0
        f = Frame(bg)
        for dur, fn in SCENES:
            if start - FADE <= t < start + dur + FADE:
                local = t - start
                a = min(span(local, -FADE, 0) if start > 0 else 1.0,
                        1 - span(local, dur - FADE, dur) if fn is not SCENES[-1][1] else 1.0)
                if a > 0:
                    fn(f, clamp(local, 0, dur), a)
                    f.flush()
            start += dur
        out = f.done()
        proc.stdin.write(out.tobytes())
        if i % 60 == 0:
            print(f"{i}/{frames}", file=sys.stderr)
    proc.stdin.close()
    proc.wait()
    poster_frame(bg).save(POSTER, quality=86)
    print(OUT)


if __name__ == "__main__":
    render()
