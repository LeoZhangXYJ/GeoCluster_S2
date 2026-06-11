from pathlib import Path
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

ROOT = Path(__file__).parent.parent.resolve()

processed = ROOT / "data" / "processed"
baseline_dir = ROOT / "results" / "cluster_baseline"
pca_dir = ROOT / "results" / "cluster_pca"
ae_dir = ROOT / "results" / "cluster_ae"
sae_dir = ROOT / "results" / "cluster_sae"
geo_dec_dir = ROOT / "results" / "cluster_geo_dec"
out_dir = ROOT / "results" / "final_figures"
out_dir.mkdir(exist_ok=True)


def existing_items(items):
    existing = []
    missing = []
    for title, path in items:
        if path.exists():
            existing.append((title, path))
        else:
            missing.append(path)
    if missing:
        print("Skipping missing figure inputs:")
        for path in missing:
            print(" ", path)
    return existing


def save_grid(items, nrows, ncols, figsize, out_stem, title_size=12):
    items = existing_items(items)
    fig, axes = plt.subplots(nrows, ncols, figsize=figsize)
    axes_flat = axes.ravel() if hasattr(axes, "ravel") else [axes]

    for ax in axes_flat:
        ax.axis("off")

    for ax, (title, path) in zip(axes_flat, items):
        img = mpimg.imread(path)
        ax.imshow(img)
        ax.set_title(title, fontsize=title_size)
        ax.axis("off")

    plt.tight_layout()
    plt.savefig(out_dir / f"{out_stem}.png", dpi=300, bbox_inches="tight")
    plt.savefig(out_dir / f"{out_stem}.pdf", dpi=300, bbox_inches="tight")
    plt.close()

# === 2×3 综合对比图 ===
items_2x3 = [
    ("(a) True color: B04/B03/B02", processed / "preview_true_color_B04_B03_B02.png"),
    ("(b) Geology false color: B12/B8A/B02", processed / "preview_geology_B12_B8A_B02.png"),
    ("(c) Raw K-means, k=5", baseline_dir / "kmeans_baseline_k5.png"),
    ("(d) PCA + K-means, z=5, k=6", pca_dir / "pca_kmeans_z5_k6.png"),
    ("(e) Canonical AE + K-means, z=5, k=6", ae_dir / "ae_kmeans_k6_z5.png"),
    ("(f) SAE + K-means, z=5, k=6", sae_dir / "sae_kmeans_k6_z5.png"),
]

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

for ax, (title, path) in zip(axes.ravel(), items_2x3):
    img = mpimg.imread(path)
    ax.imshow(img)
    ax.set_title(title, fontsize=11)
    ax.axis("off")

plt.tight_layout()
plt.savefig(out_dir / "final_comparison_2x3.png", dpi=300, bbox_inches="tight")
plt.savefig(out_dir / "final_comparison_2x3.pdf", dpi=300, bbox_inches="tight")
plt.close()

# === 2x3 comparison with the proposed Geo-DEC method ===
items_geo_dec = [
    ("(a) Raw K-means, k=5", baseline_dir / "kmeans_baseline_k5.png"),
    ("(b) PCA + K-means, z=5, k=6", pca_dir / "pca_kmeans_z5_k6.png"),
    ("(c) Canonical AE + K-means, z=5, k=6", ae_dir / "ae_kmeans_k6_z5.png"),
    ("(d) SAE + K-means, z=5, k=6", sae_dir / "sae_kmeans_k6_z5.png"),
    ("(e) Geo-DEC, z=5, k=6", geo_dec_dir / "geo_dec_k6_z5.png"),
    ("(f) Geology false color: B12/B8A/B02", processed / "preview_geology_B12_B8A_B02.png"),
]

save_grid(
    items_geo_dec,
    nrows=2,
    ncols=3,
    figsize=(18, 10),
    out_stem="method_comparison_2x3_geo_dec",
    title_size=11,
)

# === 2×2 四合一对比图（保持兼容旧版） ===
items_2x2 = [
    ("(a) True color: B04/B03/B02", processed / "preview_true_color_B04_B03_B02.png"),
    ("(b) Geology false color: B12/B8A/B02", processed / "preview_geology_B12_B8A_B02.png"),
    ("(c) Baseline K-means, k=5", baseline_dir / "kmeans_baseline_k5.png"),
    ("(d) SAE + K-means, z=5, k=6", sae_dir / "sae_kmeans_k6_z5.png"),
]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

for ax, (title, path) in zip(axes.ravel(), items_2x2):
    img = mpimg.imread(path)
    ax.imshow(img)
    ax.set_title(title, fontsize=12)
    ax.axis("off")

plt.tight_layout()
plt.savefig(out_dir / "final_comparison_2x2.png", dpi=300, bbox_inches="tight")
plt.savefig(out_dir / "final_comparison_2x2.pdf", dpi=300, bbox_inches="tight")
plt.close()

# === 三方法聚类对比图（Raw / PCA / AE / SAE） ===
items_4methods = [
    ("(a) Raw K-means, k=5", baseline_dir / "kmeans_baseline_k5.png"),
    ("(b) PCA + K-means, z=5, k=6", pca_dir / "pca_kmeans_z5_k6.png"),
    ("(c) Canonical AE + K-means, z=5, k=6", ae_dir / "ae_kmeans_k6_z5.png"),
    ("(d) SAE + K-means, z=5, k=6", sae_dir / "sae_kmeans_k6_z5.png"),
]

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

for ax, (title, path) in zip(axes.ravel(), items_4methods):
    img = mpimg.imread(path)
    ax.imshow(img)
    ax.set_title(title, fontsize=12)
    ax.axis("off")

plt.tight_layout()
plt.savefig(out_dir / "method_comparison_2x2.png", dpi=300, bbox_inches="tight")
plt.savefig(out_dir / "method_comparison_2x2.pdf", dpi=300, bbox_inches="tight")
plt.close()

# === Five-method comparison for the updated report ===
items_5methods = [
    ("(a) Raw K-means, k=5", baseline_dir / "kmeans_baseline_k5.png"),
    ("(b) PCA + K-means, z=5, k=6", pca_dir / "pca_kmeans_z5_k6.png"),
    ("(c) Canonical AE + K-means, z=5, k=6", ae_dir / "ae_kmeans_k6_z5.png"),
    ("(d) SAE + K-means, z=5, k=6", sae_dir / "sae_kmeans_k6_z5.png"),
    ("(e) Geo-DEC, z=5, k=6", geo_dec_dir / "geo_dec_k6_z5.png"),
]

save_grid(
    items_5methods,
    nrows=2,
    ncols=3,
    figsize=(18, 10),
    out_stem="method_comparison_5methods",
    title_size=11,
)

print("Saved to:", out_dir)
print("  final_comparison_2x3.png/pdf")
print("  final_comparison_2x2.png/pdf")
print("  method_comparison_2x2.png/pdf")
print("  method_comparison_2x3_geo_dec.png/pdf")
print("  method_comparison_5methods.png/pdf")
