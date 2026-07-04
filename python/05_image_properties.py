#!/usr/bin/env python3
"""
05_image_properties.py — low-level stimulus feature descriptives (Reviewer 2.2).
Computes per-image luminance (Rec.709), RMS contrast, Hasler-Susstrunk
colorfulness, and gradient/edge density (complexity), then summarizes by emoji
type and runs a one-way ANOVA across types. Also reports the image-only /
primary AOI area ratio from the eye-tracking export.

Usage:  python3 python/05_image_properties.py
Edit STIM / ET below (or match R/00_config.R paths).
"""
import numpy as np, glob, os, unicodedata
from PIL import Image
import pandas as pd

STIM = "data/stimuli"                     # emoji/face stimulus PNGs
ET   = "data/eyetracking_metrics.tsv"     # Tobii AOI metrics export
OUT  = "results"; os.makedirs(OUT, exist_ok=True)

def nfc(s): return unicodedata.normalize("NFC", s)
KR_EMO = {"공포":"Fear","기쁨":"Joy","분노":"Anger","슬픔":"Sadness","혐오":"Disgust"}

def features(path):
    a = np.asarray(Image.open(path).convert("RGB")).astype(float)
    L = 0.2126*a[:,:,0] + 0.7152*a[:,:,1] + 0.0722*a[:,:,2]
    R,G,B = a[:,:,0], a[:,:,1], a[:,:,2]; rg = R-G; yb = 0.5*(R+G)-B
    colorful = np.sqrt(rg.std()**2 + yb.std()**2) + 0.3*np.sqrt(rg.mean()**2 + yb.mean()**2)
    gy,gx = np.gradient(L)
    return L.mean(), L.std(), colorful, np.sqrt(gx**2+gy**2).mean()

def emoji_type(name):
    b = nfc(name)
    if   nfc("실사콘") in b: return "Real-con"
    elif nfc("실사")   in b: return "Realistic"
    elif nfc("애니콘") in b: return "Ani-con"
    elif nfc("그래픽콘") in b: return "Graphic-con"
    return "?"

def one_way_anova(groups):
    k = len(groups); N = sum(len(g) for g in groups); gm = np.concatenate(groups).mean()
    ssb = sum(len(g)*(g.mean()-gm)**2 for g in groups)
    ssw = sum(((g-g.mean())**2).sum() for g in groups)
    return (ssb/(k-1))/(ssw/(N-k)), k-1, N-k

rows = []
for f in sorted(glob.glob(os.path.join(STIM, "*.png"))):
    b = nfc(os.path.basename(f))
    lum, con, col, edge = features(f)
    rows.append(dict(Type=emoji_type(b),
                     Emotion=next((v for k,v in KR_EMO.items() if nfc(k) in b), "?"),
                     Luminance=lum, RMS_contrast=con, Colorfulness=col, Edge_density=edge))
df = pd.DataFrame(rows)
df.to_csv(os.path.join(OUT, "image_properties.csv"), index=False)
order = ["Realistic","Real-con","Ani-con","Graphic-con"]
print("By type (mean ± SD):")
for t in order:
    s = df[df.Type == t]
    if len(s):
        print(f"  {t:12s} Lum {s.Luminance.mean():5.0f}±{s.Luminance.std():3.0f}  "
              f"Contrast {s.RMS_contrast.mean():4.0f}±{s.RMS_contrast.std():3.0f}  "
              f"Colorful {s.Colorfulness.mean():4.0f}±{s.Colorfulness.std():3.0f}  "
              f"Edge {s.Edge_density.mean():4.2f}±{s.Edge_density.std():4.2f}")
print("\nOne-way ANOVA across emoji types:")
for c in ["Luminance","RMS_contrast","Colorfulness","Edge_density"]:
    g = [df[df.Type == t][c].values for t in order if len(df[df.Type == t])]
    F, d1, d2 = one_way_anova(g); print(f"  {c:14s} F({d1},{d2}) = {F:6.2f}")

# image-only / primary AOI area ratio
if os.path.exists(ET):
    et = pd.read_csv(ET, sep="\t"); et["s"] = pd.to_numeric(et["AOI_size"], errors="coerce")
    sz = et.dropna(subset=["s"]).groupby("AOI")["s"].median()
    if "AOI_BIG" in sz and "AOI_SAMLL" in sz:
        r = sz["AOI_SAMLL"]/sz["AOI_BIG"]
        print(f"\nImage-only AOI = {100*r:.1f}% of primary AOI (label+margin ≈ {100*(1-r):.1f}%)")
