"""One-off script to generate docs/assets/architecture_diagram.png.

A simple 3-layer box diagram (presentation / services / platform) reflecting
the actual lib/ folder structure, for report section 2.1 Product Design.
Not part of the app build -- run manually with
`python scripts/generate_architecture_diagram.py`.
"""

from PIL import Image, ImageDraw, ImageFont

W, H = 1700, 830
BG = (255, 255, 255)
PRIMARY = (0, 70, 45)  # AppColors.primary
PRIMARY_FILL = (223, 236, 229)  # light tint of primary
GREY_FILL = (240, 240, 238)
GREY_BORDER = (150, 155, 152)
TEXT_DARK = (30, 34, 32)
ARROW = (110, 116, 112)

img = Image.new("RGB", (W, H), BG)
d = ImageDraw.Draw(img)


def font(size, bold=False):
    names = (
        ["arialbd.ttf", "Arial Bold.ttf"] if bold else ["arial.ttf", "Arial.ttf"]
    )
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


def box(x0, y0, x1, y1, title, sub_lines, fill=PRIMARY_FILL, border=PRIMARY):
    d.rounded_rectangle([x0, y0, x1, y1], radius=14, fill=fill, outline=border, width=2)
    cx = (x0 + x1) / 2
    title_lines = wrapped_lines(title, box_font, (x1 - x0) - 20)
    n_title = len(title_lines)
    n_sub = len(sub_lines)
    line_h_title = 22
    line_h_sub = 18
    total_h = n_title * line_h_title + (6 if sub_lines else 0) + n_sub * line_h_sub
    y = (y0 + y1) / 2 - total_h / 2 + line_h_title / 2
    for line in title_lines:
        centered_text((cx, y), line, box_font, PRIMARY if fill != PRIMARY else (255, 255, 255))
        y += line_h_title
    y += 4
    for line in sub_lines:
        centered_text((cx, y), line, sub_font, (70, 75, 72))
        y += line_h_sub


def row_of_boxes(items, y0, y1, margin=40, gap=18):
    n = len(items)
    total_w = W - 2 * margin
    box_w = (total_w - gap * (n - 1)) / n
    x = margin
    boxes = []
    for title, subs in items:
        box(x, y0, x + box_w, y1, title, subs)
        boxes.append((x, y0, x + box_w, y1))
        x += box_w + gap
    return boxes


def arrow(x, y0, y1):
    d.line([(x, y0), (x, y1)], fill=ARROW, width=3)
    d.polygon([(x - 8, y1 - 10), (x + 8, y1 - 10), (x, y1)], fill=ARROW)


# ---- Title ----------------------------------------------------------------
centered_text((W / 2, 40), "AflAlert — System Architecture", title_font, PRIMARY)

# ---- Layer 1: Presentation --------------------------------------------------
centered_text((W / 2, 100), "Presentation Layer  —  Flutter UI (lib/screens)", layer_font, TEXT_DARK)
l1_y0, l1_y1 = 125, 245
l1_items = [
    ("Onboarding & Auth", ["welcome, login,", "registration, OTP"]),
    ("Home", ["scan launcher,", "weather, alerts"]),
    ("Kernel / Strip Scan", ["camera capture", "+ results"]),
    ("History & Reports", ["scan list,", "PDF export"]),
    ("Notifications", ["alerts &", "updates"]),
    ("Settings, Profile", ["& Voice", "Assistant"]),
]
row_of_boxes(l1_items, l1_y0, l1_y1)

for gx in [W * (i + 0.5) / 6 for i in range(6)]:
    arrow(gx, l1_y1 + 4, l1_y1 + 40)

# ---- Layer 2: Services -------------------------------------------------------
centered_text((W / 2, 290), "Services Layer  —  Business Logic (lib/services)", layer_font, TEXT_DARK)
l2_y0, l2_y1 = 315, 460
l2_items = [
    ("Kernel Classification", ["tflite_service", "(TFLite)"]),
    ("Strip Analysis", ["line detection,", "OD → ppb"]),
    ("Weather / Rain / Heat\nAlerts", ["morning_alert,", "rain_alert,", "temp_humidity_alert"]),
    ("Voice Assistant", ["speech-to-text,", "TTS"]),
    ("PDF & Report Storage", ["pdf_service,", "report_storage"]),
    ("Firebase Access", ["auth, firestore,", "storage"]),
]
row_of_boxes(l2_items, l2_y0, l2_y1, gap=16)

for gx in [W * (i + 0.5) / 6 for i in range(6)]:
    arrow(gx, l2_y1 + 4, l2_y1 + 40)

# ---- Layer 3: Platform / External -------------------------------------------
centered_text((W / 2, 505), "Platform & External Services", layer_font, TEXT_DARK)
l3_y0, l3_y1 = 530, 660
l3_items = [
    ("TensorFlow Lite", ["on-device", "ML model"]),
    ("Firebase", ["Auth · Firestore · Storage", "Cloud Functions · App Check"]),
    ("Android WorkManager", ["background", "alert scheduling"]),
    ("Weather API", ["forecast", "data"]),
    ("Device Camera", ["kernel & strip", "photo capture"]),
]
row_of_boxes(l3_items, l3_y0, l3_y1, gap=20)

# ---- Legend / note -----------------------------------------------------------
note = (
    "Screens call into services; services own all business logic and talk to Firebase, the "
    "bundled TFLite model, the device camera, and platform schedulers. This keeps each "
    "detection tier (kernel vs. strip) and supporting feature independently testable."
)
note_lines = wrapped_lines(note, caption_font, W - 200)
ny = 720
for line in note_lines:
    centered_text((W / 2, ny), line, caption_font, (70, 75, 72))
    ny += 22

img.save("docs/assets/architecture_diagram.png")
print("Saved docs/assets/architecture_diagram.png")
