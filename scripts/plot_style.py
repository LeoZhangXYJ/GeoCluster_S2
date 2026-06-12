"""Shared plotting defaults for report figures."""

import matplotlib.pyplot as plt

DPI_LINE = 600
DPI_RASTER = 600

COLORBLIND_PALETTE = [
    "#0072B2",  # blue
    "#E69F00",  # orange
    "#56B4E9",  # sky blue
    "#CC79A7",  # purple-pink
    "#999999",  # gray
    "#000000",  # black
]


def apply_report_style():
    plt.rcParams.update({
        "font.family": "sans-serif",
        "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans"],
        "axes.titlesize": 9,
        "axes.labelsize": 9,
        "xtick.labelsize": 8,
        "ytick.labelsize": 8,
        "legend.fontsize": 8,
        "legend.title_fontsize": 9,
        "lines.linewidth": 1.5,
        "lines.markersize": 4,
        "axes.linewidth": 0.8,
        "grid.linewidth": 0.4,
        "savefig.dpi": DPI_LINE,
        "figure.dpi": DPI_LINE,
    })
