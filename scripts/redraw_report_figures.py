"""Redraw lightweight report figures from existing CSV outputs.

This script does not retrain models or recompute clustering labels. It only
refreshes figure styling for publication-format output.
"""

from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from plot_style import COLORBLIND_PALETTE, DPI_LINE, apply_report_style

ROOT = Path(__file__).parent.parent.resolve()


def draw_elbow():
    path = ROOT / "results" / "cluster_baseline" / "elbow_curve.csv"
    df = pd.read_csv(path)
    best = df.loc[df["distance_to_line"].idxmax()]

    fig, ax = plt.subplots(figsize=(7, 5))
    ax.plot(df["k"], df["inertia"], marker="o", color="#0072B2", linewidth=1.5)
    ax.axvline(best["k"], linestyle="--", linewidth=1.2, color="0.35", label=f"auto k = {int(best['k'])}")
    ax.set_xlabel("Number of clusters, k / count")
    ax.set_ylabel("Inertia / 1")
    ax.set_title("Elbow curve for K-means")
    ax.grid(axis="y", alpha=0.15)
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(ROOT / "results" / "cluster_baseline" / "elbow_curve.png", dpi=DPI_LINE)
    plt.close(fig)


def draw_pca_variance():
    path = ROOT / "results" / "cluster_pca" / "pca_explained_variance.csv"
    df = pd.read_csv(path)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.bar(
        df["component"],
        df["explained_variance_ratio"],
        color="#0072B2",
        edgecolor="0.25",
        linewidth=0.4,
    )
    ax1.set_xlabel("Principal component / index")
    ax1.set_ylabel("Explained variance ratio / 1")
    ax1.set_title("PCA explained variance per component")
    ax1.set_xticks(df["component"])

    ax2.plot(df["component"], df["cumulative_variance_ratio"], marker="o", color="#E69F00", linewidth=1.5)
    ax2.axhline(0.95, color="0.45", linestyle="--", linewidth=1.2, label="95% threshold")
    ax2.axhline(0.99, color="0.45", linestyle=":", linewidth=1.2, label="99% threshold")
    ax2.set_xlabel("Number of components / count")
    ax2.set_ylabel("Cumulative explained variance / 1")
    ax2.set_title("PCA cumulative explained variance")
    ax2.set_xticks(df["component"])
    ax2.legend(frameon=False)

    fig.tight_layout()
    fig.savefig(ROOT / "results" / "cluster_pca" / "pca_explained_variance.png", dpi=DPI_LINE)
    plt.close(fig)


def draw_training_loss(csv_path, out_path, title):
    df = pd.read_csv(csv_path)
    loss_col = [c for c in df.columns if "loss" in c or "mse" in c.lower()][-1]
    epoch_col = df.columns[0]

    fig, ax = plt.subplots(figsize=(7, 5))
    ax.plot(df[epoch_col], df[loss_col], marker="o", color="#0072B2", linewidth=1.5)
    ax.set_xlabel("Epoch / count")
    ax.set_ylabel("Reconstruction MSE / 1")
    ax.set_title(title)
    ax.grid(axis="y", alpha=0.15)
    fig.tight_layout()
    fig.savefig(out_path, dpi=DPI_LINE)
    plt.close(fig)


def draw_spectral_profiles():
    stats_path = ROOT / "results" / "cluster_spectra" / "cluster_spectral_statistics.csv"
    stats = pd.read_csv(stats_path)
    bands = list(dict.fromkeys(stats["band"]))
    x = np.arange(len(bands))

    fig, ax = plt.subplots(figsize=(10, 6))
    for idx, cid in enumerate(sorted(stats["cluster_id"].unique())):
        sub = stats[stats["cluster_id"] == cid].set_index("band").loc[bands]
        mean = sub["mean"].to_numpy()
        std = sub["std"].to_numpy()
        n_pix = int(sub["pixel_count"].iloc[0])
        n_total = stats.drop_duplicates("cluster_id")["pixel_count"].sum()
        color = COLORBLIND_PALETTE[idx % len(COLORBLIND_PALETTE)]
        ax.fill_between(x, mean - std, mean + std, alpha=0.12, color=color)
        ax.plot(x, mean, marker="o", color=color, linewidth=1.5, label=f"Cluster {cid} ({n_pix / n_total:.1%})")

    ax.set_xticks(x)
    ax.set_xticklabels(bands)
    ax.set_xlabel("Band / Sentinel-2 MSI")
    ax.set_ylabel("Surface reflectance / 1")
    ax.set_title("Mean spectral profiles by cluster (SAE z=5, k=6)")
    ax.legend(ncol=2, loc="upper left", frameon=False)
    ax.grid(axis="y", alpha=0.15)
    ax.axvspan(7.5, 9.5, color="0.5", alpha=0.08)
    ax.text(8.5, ax.get_ylim()[1] * 0.98, "SWIR\n(OH-/CO3-bearing)", fontsize=8, ha="center", va="top", color="0.35")
    fig.tight_layout()
    out_dir = ROOT / "results" / "cluster_spectra"
    fig.savefig(out_dir / "cluster_spectral_profiles.png", dpi=DPI_LINE)
    fig.savefig(out_dir / "cluster_spectral_profiles.pdf", dpi=DPI_LINE)
    plt.close(fig)

    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    for idx, cid in enumerate(sorted(stats["cluster_id"].unique())):
        ax_i = axes.ravel()[idx]
        sub = stats[stats["cluster_id"] == cid].set_index("band").loc[bands]
        mean = sub["mean"].to_numpy()
        std = sub["std"].to_numpy()
        n_pix = int(sub["pixel_count"].iloc[0])
        n_total = stats.drop_duplicates("cluster_id")["pixel_count"].sum()
        color = COLORBLIND_PALETTE[idx % len(COLORBLIND_PALETTE)]
        ax_i.fill_between(x, mean - std, mean + std, alpha=0.15, color=color)
        ax_i.plot(x, mean, marker="o", color=color, linewidth=1.5)
        ax_i.set_xticks(x)
        ax_i.set_xticklabels(bands, fontsize=7, rotation=45)
        ax_i.set_title(f"Cluster {cid} ({n_pix / n_total:.1%})")
        ax_i.grid(axis="y", alpha=0.15)
        ax_i.axvspan(7.5, 9.5, color="0.5", alpha=0.08)
    fig.suptitle("Spectral profiles per cluster (SAE z=5, k=6)", fontsize=9, y=1.01)
    fig.tight_layout()
    fig.savefig(out_dir / "cluster_spectral_profiles_per_class.png", dpi=DPI_LINE)
    plt.close(fig)


def main():
    apply_report_style()
    draw_elbow()
    draw_pca_variance()
    draw_training_loss(
        ROOT / "results" / "cluster_sae" / "sae_training_loss_z4.csv",
        ROOT / "results" / "cluster_sae" / "sae_training_loss_z4.png",
        "SAE training loss (z=4)",
    )
    draw_training_loss(
        ROOT / "results" / "cluster_sae" / "sae_training_loss_z5.csv",
        ROOT / "results" / "cluster_sae" / "sae_training_loss_z5.png",
        "SAE training loss (z=5)",
    )
    draw_training_loss(
        ROOT / "results" / "cluster_ae" / "ae_training_loss_z5.csv",
        ROOT / "results" / "cluster_ae" / "ae_training_loss_z5.png",
        "Canonical AE training loss (z=5)",
    )
    draw_spectral_profiles()


if __name__ == "__main__":
    main()
