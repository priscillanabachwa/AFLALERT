"""One-off script to generate docs/assets/architecture_diagram.png.

A simple 3-layer box diagram (presentation / services / platform) reflecting
the actual lib/ folder structure, for report section 2.1 Product Design.
Each tier sits inside a dashed outline, and the down-arrows between tiers
start/end exactly on those dashed boundaries. Not part of the app build --
run manually with `python scripts/generate_architecture_diagram.py`.
"""

import math

from PIL import Image, ImageDraw, ImageFont

W, H = 1700, 860
MARGIN = 40
BG = (255, 255, 255)
PRIMARY = (0, 70, 45)  # AppColors.primary
PRIMARY_FILL = (223, 236, 229)  # light tint of primary
TIER_BORDER = (140, 146, 142)
TEXT_DARK = (30, 34, 32)
ARROW = (90, 96, 92)

img = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(img)


def font(size, bold=False):
    names = ["arialbd.ttf", "Arial Bold.ttf"] if bold else ["arial.ttf", "Arial.ttf"]
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


title_font = font(34, bold=True)
layer_font = font(20, bold=True)
box_font = font(17, bold=True)
sub_font = font(14)
caption_font = font(15)


def centered_text(xy, text, fnt, fill):
    bbox = d.textbbox((0, 0), text, font=fnt)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((xy[0] - tw / 2, xy[1] - th / 2 - bbox[1]), text, font=fnt, fill=fill)


def wrapped_lines(text, fnt, max_width):
    words = text.split()
    lines, cur = [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if d.textlength(trial, font=fnt) <= max_width:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def box(x0, y0, x1, y1, title, sub_lines):
    d.rounded_rectangle([x0, y0, x1, y1], radius=14, fill=PRIMARY_FILL, outline=PRIMARY, width=2)
    cx = (x0 + x1) / 2
    title_lines = wrapped_lines(title, box_font, (x1 - x0) - 20)
    line_h_title, line_h_sub = 22, 18
    total_h = len(title_lines) * line_h_title + (6 if sub_lines else 0) + len(sub_lines) * line_h_sub
    y = (y0 + y1) / 2 - total_h / 2 + line_h_title / 2
    for line in title_lines:
        centered_text((cx, y), line, box_font, PRIMARY)
        y += line_h_title
    y += 4
    for line in sub_lines:
        centered_text((cx, y), line, sub_font, (70, 75, 72))
        y += line_h_sub


def row_of_boxes(items, y0, y1, margin=MARGIN, gap=18):
    n = len(items)
    box_w = (W - 2 * margin - gap * (n - 1)) / n
    x = margin
    centers = []
    for title, subs in items:
        box(x, y0, x + box_w, y1, title, subs)
        centers.append(x + box_w / 2)
        x += box_w + gap
    return centers


def dashed_line(p0, p1, dash=10, gap=7, fill=TIER_BORDER, width=2):
    x0, y0 = p0
    x1, y1 = p1
    length = math.hypot(x1 - x0, y1 - y0)
    if length == 0:
        return
    ux, uy = (x1 - x0) / length, (y1 - y0) / length
    pos, draw_seg = 0.0, True
    while pos < length:
        seg_end = min(pos + (dash if draw_seg else gap), length)
        if draw_seg:
            d.line([(x0 + ux * pos, y0 + uy * pos), (x0 + ux * seg_end, y0 + uy * seg_end)], fill=fill, width=width)
        pos, draw_seg = seg_end, not draw_seg


def dashed_rect(box_xy, dash=10, gap=7, fill=TIER_BORDER, width=2):
    x0, y0, x1, y1 = box_xy
    dashed_line((x0, y0), (x1, y0), dash, gap, fill, width)
    dashed_line((x0, y1), (x1, y1), dash, gap, fill, width)
    dashed_line((x0, y0), (x0, y1), dash, gap, fill, width)
    dashed_line((x1, y0), (x1, y1), dash, gap, fill, width)


def arrow(x, y0, y1):
    d.line([(x, y0), (x, y1)], fill=ARROW, width=3)
    d.polygon([(x - 8, y1 - 10), (x + 8, y1 - 10), (x, y1)], fill=ARROW)


# ---- Title ------------------------------------------------------------------
centered_text((W / 2, 32), "AflAlert — System Architecture", title_font, PRIMARY)

# ---- Tier boundaries (computed up front so arrows can land exactly on them) --
tier1_top, tier1_bottom = 70, 260
tier2_top, tier2_bottom = 305, 495
tier3_top, tier3_bottom = 540, 730

dashed_rect((MARGIN - 15, tier1_top, W - MARGIN + 15, tier1_bottom))
dashed_rect((MARGIN - 15, tier2_top, W - MARGIN + 15, tier2_bottom))
dashed_rect((MARGIN - 15, tier3_top, W - MARGIN + 15, tier3_bottom))

# ---- Layer 1: Presentation ---------------------------------------------------
centered_text((W / 2, tier1_top + 30), "Presentation Layer  —  Flutter UI (lib/screens)", layer_font, TEXT_DARK)
l1_y0, l1_y1 = tier1_top + 60, tier1_bottom - 15
l1_items = [
    ("Onboarding & Auth", ["welcome, login,", "registration, OTP"]),
    ("Home", ["scan launcher,", "weather, alerts"]),
    ("Kernel / Strip Scan", ["camera capture", "+ results"]),
    ("History & Reports", ["scan list,", "PDF export"]),
    ("Notifications", ["alerts &", "updates"]),
    ("Settings, Profile", ["& Voice", "Assistant"]),
]
l1_centers = row_of_boxes(l1_items, l1_y0, l1_y1)

for cx in l1_centers:
    arrow(cx, tier1_bottom, tier2_top)

# ---- Layer 2: Services -------------------------------------------------------
centered_text((W / 2, tier2_top + 30), "Services Layer  —  Business Logic (lib/services)", layer_font, TEXT_DARK)
l2_y0, l2_y1 = tier2_top + 60, tier2_bottom - 15
l2_items = [
    ("Kernel Classification", ["tflite_service", "(TFLite)"]),
    ("Strip Analysis", ["line detection,", "OD → ppb"]),
    ("Weather / Rain / Heat Alerts", ["morning_alert,", "rain_alert,", "temp_humidity_alert"]),
    ("Voice Assistant", ["speech-to-text,", "TTS"]),
    ("PDF & Report Storage", ["pdf_service,", "report_storage"]),
    ("Firebase Access", ["auth, firestore,", "storage"]),
]
row_of_boxes(l2_items, l2_y0, l2_y1, gap=16)

n_connectors = 5
for i in range(n_connectors):
    x = MARGIN + (W - 2 * MARGIN) * (i + 1) / (n_connectors + 1)
    arrow(x, tier2_bottom, tier3_top)

# ---- Layer 3: Platform / External --------------------------------------------
centered_text((W / 2, tier3_top + 30), "Platform & External Services", layer_font, TEXT_DARK)
l3_y0, l3_y1 = tier3_top + 60, tier3_bottom - 15
l3_items = [
    ("TensorFlow Lite", ["on-device", "ML model"]),
    ("Firebase", ["Auth · Firestore · Storage", "Cloud Functions · App Check"]),
    ("Android WorkManager", ["background", "alert scheduling"]),
    ("Weather API", ["forecast", "data"]),
    ("Device Camera", ["kernel & strip", "photo capture"]),
]
row_of_boxes(l3_items, l3_y0, l3_y1, gap=20)

# ---- Legend / note ------------------------------------------------------------
note = (
    "Screens call into services; services own all business logic and talk to Firebase, the "
    "bundled TFLite model, the device camera, and platform schedulers. This keeps each "
    "detection tier (kernel vs. strip) and supporting feature independently testable."
)
note_lines = wrapped_lines(note, caption_font, W - 200)
ny = tier3_bottom + 30
for line in note_lines:
    centered_text((W / 2, ny), line, caption_font, (70, 75, 72))
    ny += 22

img.save("docs/assets/architecture_diagram.png")
print("Saved docs/assets/architecture_diagram.png")
