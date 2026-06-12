#import "template.typ": *
#import "@preview/lovelace:0.3.0": *

#let cover_comments = {
  v(2em)
  tablex(
    columns: (0.7fr, 1fr, 1.68fr, 0.7fr),
    align: center + horizon,
    stroke: 0pt,
    inset: 0.5pt,
    "",
    _underlined_cell("Name:", color: white),
    _underlined_cell("Zhang Xiangyijie"),
    "",
    "",
    _underlined_cell("Student ID:", color: white),
    _underlined_cell("3230103969"),
    "",
    "",
    _underlined_cell("Advisor:", color: white),
    _underlined_cell("Chen Ninghua"),
    "",
    "",
    _underlined_cell("Date:", color: white),
    _underlined_cell("2026.6.1"),
    "",
  )
}

#show: project.with(
  theme: "journal",
  course: "",
  title: "Sentinel-2 Unsupervised Clustering for Lithological Mapping in Porphyry Copper Districts:
  Autoencoder Baseline Comparison and Geo-DEC Spatial Enhancement",
  date: "",
  author: "Zhang Xiangyijie",
  college: "School of Earth Sciences",
  major: "Zhejiang University",
  semester: "2025-2026 Spring-Summer",
  language: "en",
  font_serif: ("Times New Roman", "New Computer Modern", "Georgia", "Nimbus Roman No9 L"),
  font_sans_serif: ("Arial", "Helvetica", "Nimbus Sans L", "Noto Sans"),
)

#let en-single-fig-width = 8.3cm
#let en-wide-fig-width = 17cm
#let en-map-fig-width = 16.5cm
#let en-workflow-fig-width = 13.8cm

#let enfigure(img, caption) = {
  show figure.caption: it => {
    block(above: 0.2em, below: 0.55em, width: 100%)[
      #set align(center)
      #set text(size: 8.5pt, fill: luma(40), weight: 400)
      #it
    ]
  }
  figure(
    kind: image,
    img,
    caption: [
      #set text(size: 8.5pt, weight: 400)
      #caption
    ],
  )
}

#let enfigurewide(img, caption) = {
  show figure.caption: it => {
    block(above: 0.2em, below: 0.6em, width: 100%)[
      #set align(center)
      #set text(size: 8.5pt, fill: luma(40), weight: 400)
      #it
    ]
  }
  block(width: 100%, above: 0.45em, below: 0.45em)[
    #figure(
      kind: image,
      block(width: 100%, img),
      caption: [
        #set text(size: 8.5pt, weight: 400)
        #caption
      ],
    )
  ]
}

#set text(font: ("Times New Roman", "New Computer Modern", "Georgia"), lang: "en", size: 12pt)
#set par(first-line-indent: 2em, spacing: 0.65em, leading: 0.5em, justify: true)
#set figure(supplement: "Fig.")
#set figure.caption(separator: "  ")
#set heading(numbering: (..args) => {
  let nums = args.pos()
  if nums.len() == 1 {
    numbering("1 ", ..nums)
  } else if nums.len() == 2 {
    numbering("1.1 ", ..nums)
  } else if nums.len() == 3 {
    numbering("1.1.1 ", ..nums)
  } else {
    numbering("(1) ", nums.at(3))
  }
})

#show heading: it => block(above: 0.9em, below: 0.35em, it)
#show heading.where(level: 1): it => block(width: 100%, above: 1.1em, below: 0.5em)[
  #set align(center)
  #set par(first-line-indent: 0em)
  #set text(size: 12pt, weight: 700)
  #it
]
#show heading.where(level: 2): it => block(width: 100%, above: 0.85em, below: 0.35em)[
  #set align(left)
  #set par(first-line-indent: 0em)
  #set text(size: 11pt, weight: 700)
  #it
]
#show heading.where(level: 3): it => block(width: 100%, above: 0.7em, below: 0.3em)[
  #set align(left)
  #set par(first-line-indent: 0em)
  #set text(size: 10.5pt, weight: 600, style: "italic")
  #it
]
#show heading.where(level: 4): it => block(width: 100%, above: 0.55em, below: 0.25em)[
  #set align(left)
  #set par(first-line-indent: 0em)
  #set text(size: 10.5pt, weight: 600)
  #it
]

#abstract(name: strong[Abstract])[
Unsupervised clustering methods enable lithological mapping in remote, sparsely vegetated areas where field labels are scarce. However, existing deep-learning-based clustering frameworks have been validated primarily in semi-arid sedimentary terrains, and their applicability to hyper-arid porphyry copper districts---as well as the relative benefit of deep versus shallow autoencoders---remains unclear. This study uses a two-stage design for the Tuwu-Yandong porphyry copper district in Hami, Xinjiang, China. Using a Sentinel-2A L2A image (2024-08-13, Tile T46TFM) with 10 spectral bands (B02--B12) resampled to 20 m, we construct a dataset of 2,772,025 valid pixels after cloud, shadow, and water masking. First, we migrate the SAE+K-means framework of Naagar et al. (2024) and compare a baseline chain of Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means to test whether nonlinear dimensionality reduction, network depth, and bottleneck dimension matter. Results show that PCA yields only marginal improvement over Raw K-means (CHI +2.7%), and the shallow Canonical AE matches or slightly exceeds the deep SAE in cluster separability (CHI 147,239 vs. 144,423), suggesting that shallow nonlinear transformations suffice for the main clustering structure of Sentinel-2 10-band data. SAE retains advantages in reconstruction fidelity (MSE 0.00285 vs. 0.00466) and cluster compactness (DBI 0.6981 vs. 0.7338). The ablation experiment reveals that $z=3$ causes severe class collapse (largest class 48.9%), while $z=5$ is used as the main compromise configuration. Second, we introduce Geo-DEC as a spatial-context enhancement beyond the pixel-independent AE+K-means pipeline. Geo-DEC achieves the highest local agreement (0.9348) and the lowest isolated pixel ratio (0.0057), although its CHI and DBI do not outperform AE/SAE, indicating that its main benefit is improved spatial continuity rather than stronger global cluster separation. Quantitative spectral analysis finds an anomalous ratio combination in C1 (B11/B12=0.992, B12/B8A=1.282); however, $"B11/B12" < 1$ means B11 is lower than B12 and does not prove B12 absorption, so this class is retained only as a candidate clue requiring geological-map or field validation. A fully scripted Python mapping pipeline replaces traditional GIS workflows for reproducible geological interpretation. This study validates the cross-regional applicability of the SAE+K-means framework in a hyper-arid porphyry copper setting and extends it with Geo-DEC for spatially coherent unsupervised lithological mapping.
]

#keywords(name: "Keywords")[Sentinel-2; lithological mapping; stacked autoencoder; canonical autoencoder; Geo-DEC; PCA; K-means clustering; spatial continuity; porphyry copper deposit; Tuwu-Yandong]

= Introduction

Remote sensing has become an indispensable tool in regional geological surveys and mineral exploration due to its large-area coverage, multi-temporal capability, and low cost #super[1]. Traditional remote sensing geological interpretation largely relies on expert visual interpretation or supervised classification. However, in remote, sparsely vegetated regions where ground-truth labels are scarce, unsupervised clustering offers a unique advantage---it can automatically discover grouping structures in spectral features without prior labels, providing an objective initial classification reference for geological mapping #super[2].

The Sentinel-2 satellite, one of the core missions of the European Space Agency (ESA) Copernicus programme, carries the Multi-Spectral Instrument (MSI) covering visible to shortwave infrared (443--2190 nm) across 13 spectral bands, with a maximum spatial resolution of 10 m #super[3]. Among these, the SWIR bands (B11: 1610 nm, B12: 2190 nm) exhibit characteristic absorption features for hydroxyl (OH#super[−]) and carbonate (CO₃#super[2−]) bearing hydrothermal alteration minerals (e.g., sericite, chlorite, calcite), making them particularly suitable for alteration zoning studies of porphyry copper deposits #super[4].

The Tuwu-Yandong area in Hami, Xinjiang, is an important porphyry copper metallogenic belt in northwestern China. The region hosts extensive Paleozoic volcanic-sedimentary sequences and intermediate-acid intrusive rocks, with sparse vegetation and high bedrock exposure, providing ideal conditions for multispectral remote sensing lithological identification #super[5]. However, when conventional K-means clustering is applied directly to 10-dimensional spectral features, noise and redundancy in high-dimensional spectral vectors often produce pronounced "salt-and-pepper" noise---spatially fragmented clusters with many isolated pixels, hindering the delineation of continuous geological units #super[6].

Regarding dimensionality reduction, Principal Component Analysis (PCA) is the most classical spectral dimensionality reduction technique and has been widely applied in remote sensing geology #super[4]. However, PCA can only capture linear variance structure and struggles to model nonlinear interactions among spectral bands. Autoencoders, as a classical unsupervised deep learning model, can learn compact low-dimensional representations through an encoder-decoder architecture. Naagar et al. (2024), in a study published in _Advances in Space Research_, systematically compared PCA, canonical autoencoder, and stacked autoencoder combined with K-means clustering for lithological mapping, validated across Landsat 8, ASTER, and Sentinel-2 data sources #super[7]. They demonstrated that Stacked Autoencoders (SAE), through multi-layer nonlinear transformations, can capture higher-order interactions among spectral bands, map high-dimensional spectra to a low-dimensional latent space while filtering noise and preserving the main spectral structure, outperforming both traditional linear dimensionality reduction and shallow autoencoders.

However, five aspects of that study warrant further investigation. First, it was validated only at a single study area (Mutawintji, Australia); the cross-regional transferability of the framework across different climate zones and tectonic units has not been examined. Second, the conclusion that "SAE comprehensively outperforms Canonical AE" was drawn without further inquiry: is the depth gain scene-dependent? When the data's nonlinear structure is limited, are deep networks still necessary? Third, the impact of bottleneck dimension on clustering quality was not systematically analyzed---a fixed latent space dimension was used without ablation experiments to reveal the risk of class collapse from an overly narrow bottleneck. Fourth, the quantitative evaluation of clustering primarily focused on separability metrics such as CHI and DBI, with geological interpretation relying mainly on qualitative description, lacking quantitative spectral evidence based on band ratios. Fifth, pixels were treated primarily as independent spectral vectors, with spatial information largely dependent on visual inspection or post-processing of the final maps, lacking experimental validation of incorporating spatial context into representation learning and clustering objectives.

Addressing these gaps, this study adopts a two-stage experimental design. Stage 1 migrates and evaluates the PCA / Canonical AE / SAE + K-means framework from Naagar et al. (2024), organized around three main questions: (1) Does nonlinear autoencoder representation outperform linear PCA dimensionality reduction? (2) How large is the gain of deep SAE over shallow Canonical AE? (3) How does bottleneck dimension affect clustering quality and class collapse? Stage 2, motivated by the pixel-independent processing and insufficient spatial continuity of AE + K-means, introduces Geo-DEC as a spatial-context enhancement extension, specifically testing whether geological indices, 3×3 neighborhood statistics, and DEC joint optimization can improve mapping continuity. In other words, Geo-DEC is not positioned as a peer "best-model contestant" alongside the first four methods, but rather as a supplementary experiment after the baseline chain to answer whether spatial enhancement is effective. The correspondence between the main contributions and the gaps in the original paper is as follows:

(1) *Baseline migration and comparison* (addressing gap 1): Transfer the SAE+K-means framework from the semi-arid sedimentary-metamorphic terrain of Australia to the hyper-arid porphyry copper district of northwestern China (Tuwu-Yandong, Xinjiang), and establish a progressive baseline chain of Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means;

(2) *Scene-dependence analysis of depth gain* (addressing gap 2): For the first time on Sentinel-2 10-band data, systematically compare the clustering performance of shallow Canonical AE and deep SAE, finding that the two are surprisingly close in cluster separability (CHI 147,239 vs 144,423), and propose that "depth gain is scene-dependent"---when data are dominated by linear correlation (PC1 explains 91.95% of variance) and surface types are limited (4--6 classes), shallow nonlinear transformations already capture the main discriminative structure;

(3) *Bottleneck dimension ablation* (addressing gap 3): Systematically test three bottleneck settings $z=3, 4, 5$, finding that $z=3$ causes severe class collapse (largest class 48.9%, CHI plummeting to 93,656), while $z=5$ is adopted as the main compromise dimension in this study because it balances reconstruction fidelity, CHI, and class distribution, even though $z=4$ is better on Silhouette and DBI;

(4) *Multi-metric evaluation and quantitative spectral interpretation* (addressing gap 4): Introduce the Silhouette coefficient as a third clustering metric, and perform quantitative spectral analysis of each cluster using five geologically meaningful band ratios (B11/B12, B12/B8A, etc.), while correcting the physical interpretation of B11/B12 and treating C1 as a spectral-spatial candidate clue rather than confirmed alteration evidence;

(5) *Geo-DEC spatial enhancement*: Following the original AE + K-means two-stage framework, further propose Geo-DEC (Geological-index and spatial-context enhanced deep embedded clustering), which incorporates alteration-related band ratios, 3×3 spatial context, and DEC clustering loss into a unified deep representation learning pipeline, to test whether spatial context can improve the continuity of geological map units;

(6) *Full-pipeline reproducibility*: Construct a complete Python preprocessing and mapping pipeline from Sentinel-2 SAFE extraction to final geological interpretation maps, ensuring full experimental reproducibility.

= Study Area and Data

== Study Area Overview

The study area is located in the Tuwu-Yandong region, approximately 120 km southwest of Hami City, Xinjiang, with geographic coordinates 94.30°E--94.70°E, 42.02°N--42.32°N. Situated in the East Tianshan tectonic belt at an elevation of about 800--1200 m, the area has a typical temperate continental arid climate with annual precipitation below 50 mm and extremely low vegetation cover (\<5%).

The main geological units exposed in the area include: Carboniferous volcanic-sedimentary sequences (andesite, dacite, tuff), Variscan intermediate-acid intrusive rocks (granodiorite, quartz diorite porphyry), and Cenozoic unconsolidated sediments. The Tuwu-Yandong porphyry copper deposit is hosted in quartz diorite porphyry bodies and their wall-rock contact zones, with typical sericitization and propylitization alteration zoning #super[5]. The spectral characteristic differences among these alteration minerals provide a physical basis for multispectral remote sensing lithological clustering.

== Data Source

This study uses a Sentinel-2A L2A (Bottom-of-Atmosphere reflectance) product acquired on 2024-08-13, Tile T46TFM. L2A-level data have undergone radiometric calibration and atmospheric correction and can be directly used for surface reflectance analysis.

The band configuration of Sentinel-2 MSI is shown in Table 1.

#v(0.5em)
#tablecaption[Table 1 Sentinel-2 MSI band characteristics]

#table3(
  columns: (auto, auto, auto, auto),
  [Band], [Central Wavelength (nm)], [Spatial Resolution (m)], [Primary Use],
  [B02 (Blue)], [490], [10], [Aerosol, true-color composite],
  [B03 (Green)], [560], [10], [Vegetation, true-color composite],
  [B04 (Red)], [665], [10], [Iron oxides, true-color composite],
  [B05 (Red Edge 1)], [705], [20], [Vegetation red edge, geology],
  [B06 (Red Edge 2)], [740], [20], [Vegetation red edge, geology],
  [B07 (Red Edge 3)], [783], [20], [Vegetation red edge],
  [B08 (NIR)], [842], [10], [Vegetation, water bodies],
  [B8A (NIR Narrow)], [865], [20], [Vegetation monitoring],
  [B11 (SWIR 1)], [1610], [20], [Alteration minerals (OH⁻ absorption)],
  [B12 (SWIR 2)], [2190], [20], [Alteration minerals (CO₃²⁻/OH⁻ absorption)],
)

This study uses 10 bands spanning the visible--near-infrared--shortwave infrared range (B02, B03, B04, B05, B06, B07, B08, B8A, B11, B12), together with the SCL (Scene Classification Layer) band for cloud/shadow/water masking.

#enfigure(image("../data/processed/preview_true_color_B04_B03_B02.png", width: en-single-fig-width), [True-color composite of the study area (B04/B03/B02)])

#enfigure(image("../data/processed/preview_geology_B12_B8A_B02.png", width: en-single-fig-width), [Geological false-color composite of the study area (B12/B8A/B02).\
Assigning B12 to the red channel highlights relative SWIR brightness and lithology/alteration-related contrast.])

From Figure 1, the study area surface exhibits grayish-yellow to grayish-brown tones, with minimal vegetation cover and high bedrock exposure. In the false-color composite of Figure 2, brownish-red areas mainly indicate relatively strong B12 response or higher SWIR brightness/contrast; they should be treated as preliminary visual clues for lithological or alteration-related anomalies rather than direct evidence of SWIR absorption.

= Methods

The methodological framework of this study is illustrated in Figure 3 and comprises four stages: (1) data preprocessing and spectral standardization; (2) baseline chain construction, i.e., progressive comparison of Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means; (3) Geo-DEC spatial enhancement extension, adding geological indices, neighborhood statistics, and DEC joint clustering objectives on top of the AE representation learning paradigm; (4) multi-metric evaluation and geological interpretation, including traditional cluster separability metrics, spatial continuity metrics, spectral response analysis, and automated mapping.

#enfigurewide(image("assets/image_en.png", width: en-workflow-fig-width), [Overall technical workflow])

== Data Preprocessing

=== Band Extraction and Resampling

Ten spectral bands (B02--B12) and the SCL band were extracted from the Sentinel-2A L2A SAFE product, with original JPEG2000 format converted to an internal processing format. Since Sentinel-2 bands have different native resolutions (see Table 1), all bands were unified to 20 m spatial resolution to ensure spatial consistency: 20 m bands (B05, B06, B07, B8A, B11, B12) were used directly on their original grid; B08 (10 m) was resampled to the 20 m reference grid via bilinear interpolation; the 10 m versions of B02, B03, and B04 were not used in this study---their 20 m resampled versions were used directly.

=== AOI Cropping

Based on the study area's geographic extent (94.30°E--94.70°E, 42.02°N--42.32°N), rasterio was used to transform the WGS84 coordinates to the image's native CRS (UTM Zone 46, EPSG:32646), and a cropping window was then created. The cropped image size is 1681 × 1695 pixels.

=== SCL Masking

The Sentinel-2 L2A product includes an SCL (Scene Classification Layer) band that classifies each pixel into 11 scene types. This study excludes pixels of the following categories: 0 (No Data), 1 (Saturated/Defective), 2 (Dark Area), 3 (Cloud Shadow), 6 (Water), 8 (Medium-Probability Cloud), 9 (High-Probability Cloud), 10 (Cirrus), 11 (Snow/Ice). Categories 4 (Vegetation), 5 (Bare Soil), and 7 (Low-Probability Cloud) are retained as valid pixels.

After masking, the number of valid pixels is 2,772,025, accounting for 97.29% of the total, indicating that the study area is dominated by bare land and sparse vegetation, satisfying the basic requirements for remote sensing geological analysis. Pixels with spectral reflectance ≤ 0 in any band were also filtered out.

== Spectral Standardization

The 10 bands were unfolded into an $(N, 10)$ matrix by pixel, where $N=2,772,025$. Z-score standardization (StandardScaler) was applied, centering each band to mean 0 and scaling to standard deviation 1, eliminating numerical scale differences among bands due to sensor gain variations and ensuring equal contribution of each band to clustering.

== Experimental Design: Baseline Chain and Spatial Enhancement Extension

To avoid conflating methods with different objectives, this study divides the experimental design into a "baseline chain" and a "spatial enhancement extension." Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means constitute the progressive baseline chain: Raw K-means provides a no-reduction reference, PCA tests whether linear reduction suffices, Canonical AE tests the necessity of shallow nonlinear representation, and SAE tests whether increasing network depth brings additional benefit. Geo-DEC, positioned after this baseline chain, uses geological band ratios, 3×3 spatial context, and DEC clustering loss to specifically test whether incorporating spatial context beyond spectral representation learning can improve geological mapping continuity.

Regarding the choice of cluster number $k$: the Elbow analysis on standardized 10-dimensional raw spectral features automatically identified $k=5$ as optimal. However, subsequent methods perform clustering in reduced low-dimensional latent spaces, where the optimal $k$ may not coincide with that in the original space; furthermore, the study area is known to contain at least 4--6 major surface cover/lithological types (intermediate-acid intrusive rocks, andesite, tuff, Quaternary sediments, alteration zones, etc.), making $k=6$ geologically justified. Therefore, PCA $z=5$, SAE $z=4$/$z=5$, Canonical AE $z=5$, and Geo-DEC uniformly adopt $k=6$ as the main experimental configuration, while SAE $z=3$ tests only 5 classes to verify the extreme case of class collapse caused by an overly narrow bottleneck. The results under the two $k$ values reflect the coarse ($k=5$) versus fine ($k=6$) clustering capabilities of the algorithms respectively. Table 2 lists the role differences between the four baseline methods and the Geo-DEC extension.

#v(0.5em)
#tablecaption[Table 2 Characteristics of the baseline chain and Geo-DEC spatial enhancement methods]

#table3(
  columns: (auto, auto, auto, auto, auto),
  [Method], [Reduction Type], [Network/Transform Structure], [Feature Dim.], [Parameters],
  [Raw K-means], [None], [——], [10], [——],
  [PCA + K-means], [Linear], [Covariance eigendecomposition], [$z=3$, $5$], [——],
  [Canonical AE + K-means], [Nonlinear (shallow)], [$10→16→z→16→10$], [$z=5$], [527],
  [SAE + K-means], [Nonlinear (deep)], [$10→32→16→z→16→32→10$], [$z=3$, $4$, $5$], [1,935],
  [Geo-DEC], [Geological prior + spatial context + joint clustering], [$28→64→32→z→32→64→28$ + DEC], [$z=5$], [8,231],
)

This design directly corresponds to the two-stage logic of this study: the first four methods are used to judge whether spectral representation learning itself is effective and whether depth is necessary, while Geo-DEC is used to judge whether adding geological priors and spatial context beyond the existing AE + K-means pipeline can further improve mapping continuity and interpretability.

=== Raw K-means (Baseline)

Standardized 10-dimensional spectral features are directly input to K-means clustering. The Elbow method is used to compute the inertia curve for $k=2"–"12$ on a training set of 200,000 samples, with the elbow point automatically selected via the "maximum distance to the line connecting endpoints" method.

=== PCA + K-means

Principal Component Analysis (PCA) projects the original 10-dimensional spectral data onto the orthogonal directions of maximum variance through eigendecomposition of the covariance matrix. This study experiments with PCA reduction to $z=3$ and $z=5$, followed by K-means clustering in the PCA feature space ($k=5$ for $z=3$, $k=6$ for $z=5$). The PCA baseline tests whether simple linear variance preservation can achieve clustering performance comparable to nonlinear dimensionality reduction.

=== Canonical AE + K-means (Shallow Autoencoder)

The Canonical AE adopts a single-hidden-layer structure 10 → 16 → z → 16 → 10 (527 parameters), forming a depth contrast with the SAE's two-hidden-layer structure 10 → 32 → 16 → z → 16 → 32 → 10 (1,935 parameters). The training objective is identical to that of the SAE, minimizing the mean squared error reconstruction loss:

$
cal(L)_"MSE" = 1/N sum_(i=1)^N |x_i - hat(x)_i|^2
$

where $hat(x)_i = "Decoder"("Encoder"(x_i))$ is the reconstructed vector. Both models use ReLU activation and the same training configuration (Adam optimizer, lr=1e-3, batch_size=4096, 30 training epochs, 300,000 training samples) #super[9]. Comparing the clustering performance of the Canonical AE and the SAE allows separation of the respective contributions of "nonlinear transformation" and "deep hierarchical representation."

=== Stacked AE + K-means (Stacked Autoencoder)

The SAE encoder structure is 10 → 32 → 16 → z, with a symmetric decoder structure z → 16 → 32 → 10. This architecture follows the idea of stacked autoencoders that progressively compress and learn low-dimensional representations #super[8], with training aimed at minimizing the mean squared error (MSE) reconstruction loss:

$
cal(L)_"MSE" = 1/N sum_(i=1)^N |x_i - hat(x)_i|^2
$

where $x_i$ is the standardized 10-dimensional spectral vector and $hat(x)_i = "Decoder"("Encoder"(x_i))$ is the reconstructed vector. After training, all $N=2,772,025$ valid pixels are encoded through the encoder into $z$-dimensional feature vectors, and K-means clustering is performed in the latent space. To investigate the effect of bottleneck dimension, this study compares three settings: $z=3, 4, 5$.

=== Geo-DEC: Spatial-Context Enhancement Beyond the AE+K-means Pipeline

Geo-DEC (Geological-index and spatial-context enhanced deep embedded clustering) is a spatial-context enhancement experiment proposed after the AE + K-means pipeline. It does not alter the baseline task of the first four methods---which is to answer "whether spectral representation learning is effective"---but instead targets the pixel-independent processing problem common to all baseline methods: each pixel's class is typically determined solely by its own spectrum, and neighborhood continuity is only passively observed on the result map. To address this, Geo-DEC introduces two types of prior-enhanced features at the input: the first type consists of band ratios related to porphyry copper alteration and surface material differences, including B11/B12, B12/B8A, B11/B8A, B04/B02, B08/B04, and NDVI; the second type consists of spatial context features, computing 3×3 local means and standard deviations for B11, B12, and key ratio maps, with invalid pixels explicitly excluded during computation. The model input is thus expanded from the original 10-dimensional spectra to 28-dimensional "spectral--geological index--spatial context" features.

The model architecture uses a $28→64→32→z→32→64→28$ autoencoder, with the main experiment fixing $z=5$, $k=6$, keeping comparability with the main SAE and Canonical AE experiments. Training proceeds in two stages: first, 30 epochs of pretraining using reconstruction MSE to obtain a stable low-dimensional representation; then, K-means initialization of latent-space cluster centers, followed by 20 epochs of fine-tuning with the DEC soft assignment objective. The total loss function is:

$
cal(L) = cal(L)_"recon" + 0.1 cal(L)_"DEC"
$

where $cal(L)_"recon"$ is the reconstruction MSE of the enhanced input features. $cal(L)_"DEC"$ takes the following specific form: let the soft assignment (Student-t distribution) of sample $i$ to cluster center $mu_j$ in the latent space be

$
q_(i j) = ((1 + |z_i - mu_j|^2 / alpha)^(-(alpha+1)/2)) / (sum_(j')(1 + |z_i - mu_(j')|^2 / alpha)^(-(alpha+1)/2))
$

where $alpha=1$ is the degrees-of-freedom parameter. The target distribution $P$ is obtained by enhancing the weights of high-confidence samples:

$
p_(i j) = (q_(i j)^2 / f_j) / (sum_(j') q_(i j')^2 / f_(j'))
$

where $f_j = sum_i q_(i j)$ is the soft cluster frequency. $cal(L)_"DEC"$ is defined as the KL divergence between the target distribution $P$ and the soft assignment $Q$: $cal(L)_"DEC" = sum_i sum_j p_(i j) thin space log(p_(i j) / q_(i j))$. This design makes the latent space serve not only spectral reconstruction but also inter-cluster separation, thereby addressing the objective misalignment of "reconstruct first, then cluster" in traditional AE + K-means. Since Geo-DEC's primary motivation is to ameliorate the spatial fragmentation caused by pixel-independent processing, its evaluation emphasizes the local agreement ratio and the isolated pixel ratio; Silhouette, DBI, and CHI still serve as reference metrics for traditional cluster separability rather than the sole criteria.

== Clustering Evaluation Metrics

To quantitatively evaluate clustering quality, this study introduces three commonly used unsupervised clustering evaluation metrics:

*Silhouette Coefficient* measures the similarity of each sample to its own cluster relative to the nearest neighboring cluster, ranging in $[-1, 1]$; higher values indicate compact intra-cluster structure and good inter-cluster separation #super[12].

*Davies-Bouldin Index (DBI)* measures the average similarity among clusters; lower values indicate better inter-cluster separation #super[13].

*Calinski-Harabasz Index (CHI)* is defined as the ratio of between-cluster dispersion to within-cluster dispersion; higher values indicate larger between-cluster variance and smaller within-cluster variance, reflecting a better clustering structure #super[14].

Since computing the Silhouette coefficient on all 2,772,025 pixels has $O(N^2)$ complexity, all three metrics are computed on 100,000 randomly sampled valid pixels to ensure reproducibility (random seed fixed to 42).

Additionally, to evaluate the spatial continuity of the clustering maps, two spatial quality metrics are introduced. The local agreement ratio represents the proportion of valid pixels whose label agrees with the majority label in their 3×3 neighborhood; higher values indicate more continuous map units. The isolated pixel ratio represents the proportion of isolated pixels with no same-class neighbors in the 3×3 neighborhood; lower values indicate less salt-and-pepper noise. These metrics are particularly used to test whether Geo-DEC's incorporation of spatial context improves the continuity of geological map units.

== Alignment and Extension Relative to the Original Paper's Framework

The methodological framework of this study references the open-source implementation of Naagar et al. (2024) (https://github.com/sydney-machine-learning/autoencoders_remotesensing). The original framework includes PCA, canonical autoencoders, stacked autoencoders combined with K-means, to generate clustered maps and interpret them as lithological maps. This study first reproduces and migrates this pipeline in the Tuwu-Yandong study area, then adds the Geo-DEC spatial enhancement experiment on top of its pixel-independent processing. Table 3 shows the correspondence between our implementation and the original framework, where PCA / Canonical AE / SAE correspond to the original pipeline and Geo-DEC is our extension.

#v(0.5em)
#tablecaption[Table 3 Correspondence between this study and the original framework (Naagar et al., 2024)]

#table3(
  columns: (auto, auto, auto),
  [Component], [Original Paper / Open-Source Code], [This Study],
  [Data source], [Sentinel-2 (and Landsat 8, ASTER)], [Sentinel-2A L2A T46TFM],
  [Preprocessing], [Dataset-specific (user implementation required)], [Custom SAFE extraction, band extraction, SCL masking, AOI cropping],
  [Representation learning method], [PCA / Canonical AE / Stacked AE], [PCA / Canonical AE / Stacked AE + Geo-DEC extension],
  [Clustering method], [K-means], [K-means ($k=5$, $6$) + DEC soft assignment],
  [Output], [Clustered maps], [GeoTIFF + PNG clustering maps],
  [Validation], [Clustering metrics + geological knowledge/samples], [Silhouette / DBI / CHI + spatial quality metrics + false-color comparison],
)

The original paper's GitHub repository provides Autoencoder_Landsat8.ipynb, Autoencoder_ASTER.ipynb, and Autoencoder_Sentinel2.ipynb, but notes that specific dataloader, preprocessing, and post-processing must be implemented by the user according to the dataset. On this basis, this study has completed a full preprocessing pipeline for Sentinel-2 L2A products (SCL masking, AOI cropping, band resampling and stacking), and performed full-pipeline reproduction, baseline comparison, and spatial enhancement extension in the context of study area transfer (Australia Mutawintji → China Xinjiang Tuwu-Yandong).

= Experiments and Results

This section organizes the experimental results according to the two-stage logic. §4.2--§4.4 first report the baseline results of Raw K-means, PCA + K-means, SAE, and Canonical AE to address questions of spectral representation learning, network depth, and bottleneck dimension; §4.5--§4.6 introduce Geo-DEC in the same metrics table and result figures, but with interpretation emphasis shifted toward spatial continuity and map readability; §4.7--§4.8 conduct spectral response analysis and geological interpretation mapping based on the main clustering results.

== Experimental Environment

The experimental environment is configured as follows: CPU on an Intel platform (no GPU acceleration), Python 3.x, with key dependency libraries including rasterio 1.5.0 (raster data I/O), PyTorch (autoencoder training) #super[11], scikit-learn 1.7.2 (K-means, PCA, and preprocessing) #super[10], NumPy 2.3.3, Matplotlib 3.10.7.

== Baseline: Raw K-means and Elbow Analysis

=== Elbow Analysis

The K-means inertia curve was computed for $k=2"–"12$ on a training set of 200,000 samples, with the elbow point automatically selected via the "maximum distance to the line connecting endpoints" method.

#v(0.5em)
#tablecaption[Table 4 Elbow curve data (partial)]

#table3(
  columns: (auto, auto, auto),
  [$k$], [Inertia], [Distance to Line],
  [2], [973,286], [0.000],
  [3], [587,473], [0.272],
  [4], [422,524], [0.348],
  [*5*], [*335,423*], [*0.355*],
  [6], [283,901], [0.330],
  [7], [250,001], [0.289],
  [8], [227,916], [0.238],
  [...], [...], [...],
  [12], [177,646], [0.000],
)

The automatic selection yields $k=5$, where the rate of inertia decrease shows a clear inflection; further increasing $k$ yields diminishing improvements.

#enfigure(image("../results/cluster_baseline/elbow_curve.png", width: en-single-fig-width), [Baseline K-means Elbow curve ($k=2"–"12$).\
$k=5$ has the maximum distance to the line connecting the endpoints, automatically selected as the optimal cluster number.])

=== Baseline Clustering Results

The class distribution for baseline $k=5$ is shown in Table 5.

#v(0.5em)
#tablecaption[Table 5 Baseline K-means class distribution ($k=5$)]

#table3(
  columns: (auto, auto, auto),
  [Cluster ID], [Pixel Count], [Percentage],
  [0], [1,041,958], [37.6%],
  [1], [674,396], [24.3%],
  [2], [635,695], [22.9%],
  [3], [251,487], [9.1%],
  [4], [168,489], [6.1%],
)

The largest class accounts for 37.6% and the smallest for 6.1%, indicating a relatively balanced class distribution. The three clustering metrics are: Silhouette=0.3709, DBI=0.8039, CHI=123,898.

== PCA + K-means Baseline

=== Variance Explanation Analysis

PCA decomposition of the standardized 10-dimensional spectral data yields the variance explanation ratios shown in Figure 5. The first principal component (PC1) explains 91.95% of the total variance; the first three components cumulatively explain 99.53%; the first five cumulatively explain 99.84%.

#enfigurewide(image("../results/cluster_pca/pca_explained_variance.png", width: en-wide-fig-width), [PCA variance explanation analysis.\
(a) Individual variance explanation ratio per principal component; (b) Cumulative variance explanation curve.\
PC1 explains 91.95% of the variance, indicating extremely strong colinearity among the 10 Sentinel-2 bands---surface reflectance varies highly synchronously across bands, dominated by overall brightness/albedo.])

=== PCA + K-means Clustering Results

K-means clustering was performed on features reduced to $z=3$ and $z=5$, with results shown in Table 6.

#v(0.5em)
#tablecaption[Table 6 PCA + K-means clustering results]

#table3(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  [Configuration], [$k$], [Max%], [Min%], [Silhouette ↑], [DBI ↓], [CHI ↑],
  [PCA $z=3$], [5], [38.0%], [5.9%], [0.3796], [0.7866], [127,301],
  [PCA $z=5$], [6], [30.3%], [3.6%], [0.3485], [0.8385], [122,034],
)

PCA $z=3$, $k=5$ has class balance almost identical to Baseline (Max 37.6%, Min 6.1%), with CHI increasing only from 123,898 to 127,301 (+2.7%), a limited improvement. PCA $z=5$, $k=6$, while reducing the largest class to 30.3%, produces an extremely small class (3.6%), and all three clustering metrics are inferior to the $z=3$ configuration. These results indicate that although linear PCA effectively compresses data dimensionality (the first 3 dimensions retain 99.53% variance), the preserved variance structure contributes little to optimizing K-means cluster boundaries, because PCA's optimization objective (maximum variance projection) is not aligned with K-means' optimization objective (minimum within-cluster sum of squares).

== Autoencoder Training Results

=== SAE Training Convergence

The SAE converges well within 30 epochs of training.

#v(0.5em)
#tablecaption[Table 7 SAE training reconstruction error (Reconstruction MSE)]

#table3(
  columns: (auto, auto, auto, auto),
  [Epoch], [$z=3$ (loss)], [$z=4$ (loss)], [$z=5$ (loss)],
  [1], [0.6605], [0.7220], [0.7654],
  [5], [0.0145], [0.0631], [0.0180],
  [10], [0.0047], [0.0058], [0.0050],
  [15], [0.0044], [0.0050], [0.0044],
  [20], [0.0042], [0.0047], [0.0039],
  [25], [0.0041], [0.0045], [0.0030],
  [30], [0.0040], [0.0045], [*0.00285*],
)

Note: $z=3$ was trained for 60 epochs (extended schedule) because the extremely narrow bottleneck caused premature plateauing during training; only the first 30 epochs are listed in the table for comparability with $z=4$ and $z=5$. The loss values of $z=3$ are not directly comparable in absolute terms with those of $z=4$ and $z=5$ (both 30 epochs).

$z=4$ converges quickly in the first 10 epochs but subsequently plateaus around 0.0045; $z=5$, despite a higher initial loss (0.765), continues to decrease after epoch 20, ultimately converging to 0.00285. This trend indicates that a slightly larger bottleneck, though slightly harder to train initially, can ultimately capture more spectral detail for reconstruction.

#enfigure(image("../results/cluster_sae/sae_training_loss_z4.png", width: en-single-fig-width), [SAE $z=4$ training loss curve (30 epochs)])

#enfigure(image("../results/cluster_sae/sae_training_loss_z5.png", width: en-single-fig-width), [SAE $z=5$ training loss curve (30 epochs).\
$z=5$ achieves the lowest final reconstruction error (0.00285) among the three configurations.])

=== Canonical AE vs. SAE Training Comparison

The convergence processes of the Canonical AE (10→16→5→16→10) and SAE (10→32→16→5→16→32→10) under the same training configuration are compared in Table 8.

#v(0.5em)
#tablecaption[Table 8 Canonical AE vs. SAE training reconstruction error comparison ($z=5$)]

#table3(
  columns: (auto, auto, auto),
  [Epoch], [Canonical AE (loss)], [SAE (loss)],
  [1], [0.7065], [0.7654],
  [5], [0.0694], [0.0180],
  [10], [0.0319], [0.0050],
  [15], [0.0072], [0.0044],
  [20], [0.0053], [0.0039],
  [25], [0.0049], [0.0030],
  [30], [*0.00466*], [*0.00285*],
)

In terms of reconstruction error, SAE achieves lower loss from the early training stage (epoch 5: 0.0180 vs. Canonical AE 0.0694) and retains its advantage at final convergence (MSE=0.00285 vs. 0.00466). The Canonical AE, as a strong shallow nonlinear baseline with fewer parameters, still learns effective clustering-discriminative representations; SAE, with its deeper hierarchical structure and higher parameter count (1,935 vs. 527), further improves spectral reconstruction fidelity.

#enfigure(image("../results/cluster_ae/ae_training_loss_z5.png", width: en-single-fig-width), [Canonical AE $z=5$ training loss curve (30 epochs).\
Final reconstruction error 0.00466, higher than SAE's 0.00285.])

//#pagebreak(weak: true)

== Dual-Dimension Evaluation of Baseline Methods and Geo-DEC

Table 9 summarizes the traditional cluster separability metrics, class distributions, and spatial quality metrics for all experimental configurations. Interpreting this table requires distinguishing two types of objectives: Raw/PCA/Canonical AE/SAE primarily compare the effect of spectral representation learning on cluster separability; Geo-DEC, as a spatial enhancement extension, focuses on whether local agreement and isolated pixel ratio are improved.

#v(0.5em)
#tablewide([Table 9 Clustering metric comparison across all experimental configurations])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [Method], [Feature Dim.], [$k$], [Silhouette ↑], [DBI ↓], [CHI ↑], [Max%], [Min%], [Agreement ↑], [Isolated ↓],
  [Raw K-means], [10], [5], [0.3709], [0.8039], [123,898], [37.6%], [6.1%], [0.9029], [0.0074],
  [PCA + K-means], [3], [5], [0.3796], [0.7866], [127,301], [38.0%], [5.9%], [0.9036], [0.0073],
  [PCA + K-means], [5], [6], [0.3485], [0.8385], [122,034], [30.3%], [3.6%], [0.8859], [0.0094],
  [SAE + K-means], [3], [5], [0.3735], [0.8046], [93,656], [*48.9%*], [5.0%], [0.9204], [0.0058],
  [SAE + K-means], [4], [6], [*0.4577*], [*0.6706*], [135,377], [42.0%], [4.7%], [0.8928], [0.0093],
  [SAE + K-means], [5], [6], [0.4165], [0.6981], [144,423], [37.2%], [2.6%], [0.8891], [0.0095],
  [*Canonical AE + K-means*], [*5*], [*6*], [*0.4166*], [0.7338], [*147,239*], [*36.0%*], [5.0%], [0.8834], [0.0099],
  [Geo-DEC], [28→5], [6], [0.4157], [0.8877], [68,821], [35.0%], [*9.5%*], [*0.9348*], [*0.0057*],
)
]
#set text(size: 12pt)

#v(-0.3em)
#set text(size: 8pt)
*Note:* (1) SAE $z=3$ uses $k=5$, while all other AE/SAE and Geo-DEC configurations use $k=6$; different $k$ values affect the absolute values of clustering metrics, so the SAE $z=3$ row is not fully comparable with the other rows. (2) Silhouette, DBI, and CHI are computed in each method's respective feature space (Raw K-means in 10-dimensional standardized spectral space, PCA in PCA-reduced space, AE/SAE/Geo-DEC in latent space). This follows standard practice in the autoencoder clustering literature, but implies that each metric reflects the within-representation cluster separation quality rather than a unified absolute benchmark. (3) Spatial metrics (Agreement, Isolated) can be spuriously inflated when class collapse occurs---fewer classes and larger patches lead to higher neighborhood consistency and fewer isolated pixels. Therefore, spatial metrics should be interpreted together with class distribution (Max%, Min%).
#set text(size: 12pt)

Two sets of findings emerge from Table 9. First, the baseline chain reveals the role of spectral representation learning itself:

(1) *Linear dimensionality reduction yields limited gain.* PCA $z=3$ only raises CHI from 123,898 to 127,301 (+2.7%), with the improvement in Silhouette also being non-significant (0.3709 → 0.3796). This indicates that although the first 3 PCA dimensions retain 99.53% of total variance, this variance is dominated by overall brightness and is not aligned with the optimization objective of clustering boundaries (maximizing inter-cluster separability).

(2) *Nonlinear autoencoders consistently outperform linear and no-reduction baselines.* All configurations of Canonical AE and SAE (except the $z=3$ class collapse case) achieve CHI ≥ 135,377, significantly higher than Raw K-means (123,898) and PCA (127,301), validating the benefit of nonlinear feature learning for clustering quality.

(3) *Shallow Canonical AE and deep SAE have similar clustering quality.* The two are nearly identical in Silhouette (0.4166 vs. 0.4165), and the Canonical AE is even slightly better in CHI (147,239 vs. 144,423). However, SAE has a clear advantage in DBI (0.6981 vs. 0.7338) and reconstruction accuracy (MSE 0.00285 vs. 0.00466), indicating that the deeper structure helps learn more compact spectral representations.

(4) *SAE $z=3$ exhibits severe class collapse.* CHI drops sharply to 93,656 (the lowest of all methods), with the largest class reaching 48.9%, confirming that an overly narrow bottleneck forces different spectral types to be mapped to similar latent-space positions.

Second, the Geo-DEC extension experiment reveals the role of spatial context enhancement:

(5) *Geo-DEC primarily improves spatial continuity rather than global cluster separability.* Geo-DEC's Silhouette=0.4157 is close to that of the SAE $z=5$ and Canonical AE main configurations, but DBI=0.8877 and CHI=68,821 do not surpass the AE/SAE family, indicating that geological indices, 3×3 spatial context, and DEC joint optimization did not further enhance traditional latent-space cluster separation. Conversely, Geo-DEC achieves the highest local agreement (0.9348) and lowest isolated pixel ratio (0.0057), with a more balanced class distribution (Max=35.0%, Min=9.5%) than SAE $z=5$ and Canonical AE, without small-class collapse. This indicates that its primary value lies in enhancing geological map-unit continuity, reducing salt-and-pepper noise, and improving mapping readability.

== Clustering Result Visualization

=== SAE Ablation Experiment Comparison

#enfigurewide(image("../results/cluster_sae/sae_kmeans_k5_z3.png", width: en-map-fig-width), [Ablation experiment: SAE $z=3$, $k=5$ clustering result.\
The green class expands massively (48.9%), with clear class collapse.])

The $z=3$ clustering result exposes severe class collapse. As shown in Figure 9, the green class (Cluster 2) occupies nearly half of the study area (48.9%), while geologically distinct units with inherent spectral differences are forcibly merged. Spatially, block structures that are distinguishable under $z=5$ are subsumed here into large homogeneous patches. This phenomenon validates the destructive effect of an overly narrow bottleneck: a 3-dimensional latent space cannot encode the spectral differences among 4--6 surface types, different classes overlap heavily in the latent space, and K-means cannot effectively delineate decision boundaries.

#enfigurewide(image("../results/cluster_sae/sae_kmeans_k6_z4.png", width: en-map-fig-width), [Ablation experiment: SAE $z=4$, $k=6$ clustering result.\
Largest class 42.0%, improved over $z=3$ but still high; two ~4.7% small classes appear.])

The clustering quality of $z=4$ lies between $z=3$ and $z=5$. The largest class proportion drops from 48.9% to 42.0%, showing improved class balance, but the improvement is limited---CHI only recovers to 135,377, still markedly lower than $z=5$'s 144,423. In Figure 10, the spatial extent of the green class visibly contracts, and new class patches appear in the northwest and southeast, but the overall spatial continuity is not significantly improved compared to $z=3$. Meanwhile, $z=4$ produces two very small classes of ~4.7% each; these excessively small classes may correspond to spectral outliers or mixed pixels rather than real geological units. This configuration suggests that a 4-dimensional latent space has begun to accommodate more class information, but is still insufficient to fully decouple the spectral differences among the main surface materials in the study area.

#enfigurewide(image("../results/cluster_sae/sae_kmeans_k6_z5.png", width: en-map-fig-width), [Ablation experiment: SAE $z=5$, $k=6$ clustering result.\
Largest class 37.2%, with a usable balance between class distribution, CHI, and spectral detail.])

#pagebreak(weak: true)

=== From Spectral Clustering to Spatial Enhancement: Result Comparison

#enfigurewide(image("../results/final_figures/method_comparison_5methods.png", width: en-wide-fig-width), [Comparison of baseline methods and Geo-DEC spatial enhancement results.\
(a) Raw K-means $k=5$; (b) PCA + K-means $z=5$, $k=6$;\
(c) Canonical AE + K-means $z=5$, $k=6$; (d) SAE + K-means $z=5$, $k=6$; (e) Geo-DEC $z=5$, $k=6$.])

Comparing Figure 12(a)--(e), the first four methods primarily reflect differences in spectral feature representation capability, while Geo-DEC reflects the mapping effect changes after introducing spatial context on top of existing spectral clustering:

- *Raw K-means* (Fig. 12a) has the heaviest salt-and-pepper noise, with spatially fragmented, numerous isolated pixels, hindering the continuous delineation of geological units.
- *PCA + K-means* (Fig. 12b) is visually close to Raw K-means; linear dimensionality reduction fails to significantly improve spatial continuity, consistent with the quantitative metrics.
- *Canonical AE + K-means* (Fig. 12c) shows markedly better spatial continuity than PCA, with clear large-scale block structures, but slightly less fine-grained textural detail than SAE. Its class distribution is the most balanced (Max=36.0%), with the best CHI (147,239).
- *SAE + K-means* (Fig. 12d) preserves more fine-grained spectral differences while maintaining good spatial continuity. Although CHI and Silhouette are similar to the Canonical AE, reconstruction accuracy (MSE=0.00285) and cluster compactness (DBI=0.6981) are superior.
- *Geo-DEC* (Fig. 12e) is not a simple replacement for the AE/SAE pipeline, but rather adds geological indices, spatial context, and joint clustering-objective optimization to the "low-dimensional representation learning + clustering" paradigm. Its traditional cluster separability metrics do not surpass AE/SAE (Silhouette=0.4157, DBI=0.8877, CHI=68,821), but local agreement improves to 0.9348 and isolated pixel ratio drops to 0.0057, indicating that this method primarily improves geological map-unit continuity and reduces salt-and-pepper noise rather than enhancing global cluster separability.

#enfigurewide(image("../results/final_figures/method_comparison_2x3_geo_dec.png", width: en-wide-fig-width), [Comprehensive comparison of baseline chain, Geo-DEC, and geological false-color image (2×3).\
(a) Raw K-means $k=5$; (b) PCA + K-means $z=5$, $k=6$;\
(c) Canonical AE + K-means $z=5$, $k=6$; (d) SAE + K-means $z=5$, $k=6$;\
(e) Geo-DEC $z=5$, $k=6$; (f) Geological false-color composite B12/B8A/B02.])

//#pagebreak(weak: true)

== Spectral Response Analysis of Clusters

To further reveal the geological meaning of each cluster, this study performs spectral response analysis on the 6 clusters from SAE $z=5$, $k=6$. Spectral analysis uses the original Sentinel-2 L2A surface reflectance values (unstandardized) to ensure the physical interpretability of band ratios. For each cluster's pixels, the mean and standard deviation are computed for the 10 bands, and five geologically indicative band ratios (B11/B12, B12/B8A, B11/B8A, B04/B02, B08/B04) are extracted. Results are shown in Figure 14 and Table 10.

#enfigurewide(image("../results/cluster_spectra/cluster_spectral_profiles.png", width: en-wide-fig-width), [Mean spectral reflectance curves of each cluster across the 10 bands (SAE $z=5$, $k=6$).\
Shaded bands indicate ±1 standard deviation. The gray region marks the SWIR bands (B11: 1610 nm, B12: 2190 nm), which exhibit characteristic absorption for OH⁻/CO₃²⁻-bearing alteration minerals.\
Cluster 1 shows a B11--B12 contrast, but its B11/B12 value below 1 does not by itself demonstrate B12 absorption.])

#v(0.5em)
#tablewide([Table 10 Key band ratios (mean) for each cluster])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  [Cluster], [%], [B11/B12], [B12/B8A], [B11/B8A], [B04/B02], [B08/B04], [Spectral Interpretation],
  [0], [24.2%], [1.045], [1.170], [1.222], [1.375], [1.045], [Moderately high B11/B12; moderate overall reflectance],
  [1], [18.0%], [*0.992*], [*1.282*], [1.265], [1.254], [1.021], [B11/B12 below 1 and high B12/B8A; spectral-spatial anomaly, not proof of B12 absorption],
  [2], [37.2%], [1.022], [1.231], [1.255], [1.330], [1.041], [All ratios intermediate, no extreme features; largest background class],
  [3], [2.6%], [*1.061*], [*1.080*], [1.144], [*1.447*], [1.039], [Highest B11/B12 but very small and spatially discontinuous; likely mixed pixels],
  [4], [6.9%], [1.008], [1.175], [1.178], [1.197], [1.009], [B11/B12 near 1.0, lowest B04/B02; low overall reflectance],
  [5], [11.1%], [*1.057*], [1.131], [1.194], [1.412], [1.046], [High B11/B12 but sediment-like context; low-confidence spectral clue],
)
]
#set text(size: 12pt)

The following spectral interpretation can be drawn from Table 10 and Figure 14:

*(1) Cluster 1 --- Spectral-spatial anomaly candidate (18.0%).* This class has the lowest B11/B12 ratio (0.992) among the six classes and the highest B12/B8A ratio (1.282). However, by definition, $"B11/B12" < 1$ means that B11 is lower than B12, not that B12 is lower than B11. Therefore, this ratio cannot be used as direct evidence of B12 absorption. C1 is retained here as a candidate clue because its ratio combination and spatial distribution differ from the background classes, but its geological meaning requires calibration against geological maps or field observations.

*(2) Cluster 0 --- Moderate-reflectance intrusive-rock candidate (24.2%).* B11/B12=1.045, which is higher than C1 but lower than C3 and C5. This value does not by itself rule in or rule out alteration; combined with its moderately high overall reflectance and blocky spatial distribution, the class may correspond to unaltered or weakly altered intermediate-acid intrusive rocks.

*(3) Cluster 2 --- Spectral background class (37.2%).* All ratios occupy intermediate positions among the 6 classes, with no extreme highs or lows. As the class with the largest area and the most moderate spectral characteristics, it likely represents the widely distributed volcanic-sedimentary rock matrix in the study area.

*(4) Cluster 4 --- Low-reflectance class (6.9%).* B04/B02 (1.197) and B08/B04 (1.009) are both the lowest among all 6 classes, indicating low reflectance across the visible and NIR bands, possibly corresponding to mafic volcanic rocks (e.g., andesite) or topographic shadow/low-relief areas.

*(5) Cluster 3 --- Very small anomalous class (2.6%).* B12/B8A=1.080 (lowest) and B04/B02=1.447 (highest). With a very small proportion (only 2.6%) and spectral characteristics markedly different from the other classes, it may represent mixed pixels (e.g., transition zones between alteration margins and sediments) or isolated outcrops of special lithology.

*(6) Cluster 5 --- Moderate-reflectance transitional class (11.1%).* B11/B12=1.057 is one of the higher ratios in Table 10, but the class is mainly distributed along margins, valleys, and gully flanks. Together with B04/B02=1.412, this pattern is more consistent with Quaternary sediments or alluvial fan deposits with minor iron-oxide staining than with a robust alteration target.

#enfigurewide(image("../results/cluster_spectra/cluster_spectral_profiles_per_class.png", width: en-wide-fig-width), [Individual spectral response curves per cluster (with ±1σ error bands)])

In summary, the spectral response analysis provides a quantitative basis for geological interpretation while also clarifying its limits. Cluster 1 is a spectral-spatial anomaly that merits follow-up, but the present B11/B12 evidence does not demonstrate B12 absorption. Cluster 4's low-reflectance signature suggests mafic rocks or shadow areas, and the remaining classes reflect varying degrees of intrusive-rock, volcanic-sedimentary, and sedimentary backgrounds.

== Remote Sensing Geological Interpretation Map Generation

To avoid the non-reproducibility introduced by manual mapping in interactive GIS software, this study constructs a fully automated Python mapping workflow using rasterio and matplotlib to generate the final remote sensing geological interpretation map (Figure 16). The specific workflow is: first read the cropped 10-band Sentinel-2 raster data, extract B12 (2190 nm), B8A (865 nm), and B02 (490 nm) to construct the geological false-color base map; then read the SAE $z=5$, $k=6$ clustering GeoTIFF, and overlay the 6 cluster classes with a fixed color scheme semi-transparently (alpha=0.45) on the base map; apply binary morphological processing to the C1 candidate mask to remove isolated noise, then highlight its spatial extent with an orange outline; finally add a cluster legend, scale bar, and north arrow.

#enfigurewide(image("../results/final_figures/python_final_interpretation_map.png", width: en-map-fig-width), [Automatically generated Python remote sensing geological interpretation map.\
Base map: Sentinel-2 B12/B8A/B02 geological false-color image; colored semi-transparent overlay: SAE $z=5$, $k=6$ clustering result (alpha=0.45).\
Class C1 is highlighted with an orange outline and arrow as a spectral-spatial candidate clue; the embedded map annotation should be read as a candidate label rather than absorption proof.\
The map includes a 6-class geological interpretation legend, scale bar, north arrow, and reproducibility footnote; the entire generation workflow is fully scripted.])

The advantages of this automated mapping workflow are: (1) the map generation process is fully reproducible by simply re-running the script; (2) after changing the study area or clustering results, maps can be regenerated with a single command; (3) it avoids inconsistencies in map styles caused by manual parameter tuning in GIS software.

= Discussion

== Why PCA Yields Limited Improvement

The experimental results show that PCA dimensionality reduction yields negligible improvement in clustering quality (CHI +2.7%). The fundamental reason is the mismatch between the optimization objectives of PCA and K-means: PCA maximizes projection variance, whereas K-means minimizes within-cluster sum of squares. In the Sentinel-2 10-band data, PC1 explains 91.95% of the variance, primarily capturing the overall intensity variation across bands (brightness/albedo). However, the determination of clustering boundaries often depends on higher-order spectral features such as band ratios and absorption depths---information that is scattered across lower-variance principal components. When PCA retains only the first few high-variance components, it may discard these discriminative features that are critical for clustering.

In contrast, the autoencoder's MSE reconstruction objective forces the bottleneck to preserve all information useful for distinguishing different spectral vectors---including band-to-band differences with small variance contributions that are important for clustering discrimination (e.g., SWIR absorption features). This explains why nonlinear AEs significantly outperform PCA in clustering.

== Effect of Depth: Are Deep Autoencoders Always Necessary?

The most striking finding of this experiment is that the clustering quality of the shallow Canonical AE (CHI=147,239) is nearly on par with that of the deep SAE (CHI=144,423), and is even slightly better in class balance (Max 36.0% vs. 37.2%). This finding provides an important scene-specific qualification to the original paper's (Naagar et al., 2024) conclusion that "stacked autoencoders are better than canonical autoencoders"---in the original paper's semi-arid sedimentary-metamorphic terrain, the SAE advantage was clear; but in this study's hyper-arid porphyry copper district, the two are nearly indistinguishable in cluster separability. This suggests that the gain of autoencoder depth on clustering quality may be "scene-dependent": the stronger the data nonlinearity and the more complex the class structure, the greater the gain from deep networks; conversely, when data are dominated by linear correlation, shallow networks already suffice.

Possible explanations are: (1) The 10 Sentinel-2 spectral bands are dominated by linear correlation (PC1 explains 91.95% of variance), so nonlinear structure is relatively limited, and a shallow AE can already capture most nonlinear relationships; (2) The surface types in the Tuwu-Yandong study area are relatively simple (4--6 classes), not requiring excessively deep hierarchical representations to separate complex categories; (3) The additional parameters of SAE (1,935 vs. 527) could not be fully leveraged with limited training samples (300,000).

Nevertheless, SAE's advantages in DBI (0.6981 vs. 0.7338) and reconstruction accuracy (MSE 0.00285 vs. 0.00466) indicate that the deeper network does learn a more compact and more accurate spectral representation. In practical applications where downstream tasks demand high reconstruction fidelity (e.g., anomaly detection, spectral unmixing), SAE remains the better choice.

== Bottleneck Dimension Selection

The bottleneck dimension $z$ is a critical hyperparameter in the autoencoder pipeline. In this experiment, $z=3$ causes severe class collapse (SAE $z=3$ CHI=93,656, largest class 48.9%). The $z=4$ setting performs better on Silhouette and DBI, but still has an imbalanced largest class (42.0%) and a lower CHI than $z=5$. The $z=5$ setting is therefore used as the main compromise configuration in this study because it balances reconstruction fidelity, CHI, and class distribution. The study area contains 4--6 major surface cover/lithological types (quartz diorite porphyry, andesite, granodiorite, Quaternary sediments, alteration zones), and a 5-dimensional latent space provides sufficient degrees of freedom for the main experimental comparison.

It is worth noting that this experiment only tested settings with $z ≤ 5$. Whether $z=6$ or larger bottlenecks can further improve clustering quality without introducing excessive noise deserves exploration in future work.

== Geo-DEC and AE+K-means: Substitute or Supplement?

Geo-DEC is not an entirely separate route from the aforementioned AE + K-means methods. It inherits the basic idea of autoencoder low-dimensional representation learning, but expands the input from 10-dimensional raw spectra to 28-dimensional "spectral--geological index--spatial context" features, allowing the latent space to simultaneously contain spectral reflectance, alteration-related band ratios, and local neighborhood statistics. Thus, Geo-DEC can be viewed as a geological-prior and spatial-context enhancement built on the AE representation learning framework.

At the same time, Geo-DEC advances the post-hoc K-means clustering to DEC-style joint optimization: K-means first initializes the latent-space cluster centers, then the encoder and cluster centers are fine-tuned through KL divergence between the soft assignment and target distribution. This design attempts to alleviate the objective misalignment of "reconstruct first, then cluster" in traditional AE + K-means. However, the results show that Geo-DEC does not surpass Canonical AE or SAE on traditional separability metrics such as CHI and DBI; its CHI (68,821) is also lower than that of the Raw K-means baseline (123,898). Because these metrics are computed in each method's own feature space, the difference should be interpreted cautiously as method-specific cluster separation rather than as a strict absolute degradation. Possible reasons include: (1) among the 28-dimensional input features, the 3×3 local mean and standard deviation spatial context features essentially constitute local smoothing; while this improves spatial continuity, it may dilute subtle discriminative spectral differences, causing the spectral discriminative information of different classes to be smoothed away in the latent space; (2) hyperparameters such as the DEC loss weight (0.1) and the 3×3 neighborhood window have not yet undergone systematic ablation, and the current configuration may not achieve the optimal balance. This reveals a trade-off between spatial continuity and spectral separability: incorporating spatial context can reduce salt-and-pepper noise, but excessive smoothing may sacrifice spectral discriminative power.

Furthermore, Geo-DEC employs a deeper network structure (28→64→32→z→32→64→28, 8,231 parameters) and a larger input dimension, yet its cluster separability declines rather than improves. This strongly resonates with the core finding of Stage 1---that increasing network depth yields no significant gain in cluster separability for this Sentinel-2 data scenario. In other words, whether superimposing the depth gain of SAE on 10-dimensional raw spectra (Stage 1) or superimposing Geo-DEC's deep joint optimization on 28-dimensional enhanced features (Stage 2), additional network depth did not bring substantial improvement in cluster separability. This cross-stage consistency further supports the central thesis of this paper: the clustering-discriminative structure in this data scenario is primarily captured by shallow nonlinear transformations; deeper networks may still offer improvements on "peripheral" metrics such as reconstruction fidelity and spatial continuity, but should not be expected to be the primary means of improving cluster separability.

Therefore, Geo-DEC should be positioned in this study as a mapping-enhancement supplement to the AE + K-means pipeline, not a replacement for AE/SAE as the optimal model on traditional clustering metrics. Its value primarily lies in improved local agreement and reduced isolated pixel ratio---i.e., more continuous geological map units and fewer isolated pixels. This result also suggests that unsupervised remote sensing geological mapping cannot rely solely on a single cluster separability metric for evaluation; spatial continuity and geological interpretability must also be explicitly incorporated into the evaluation framework.

== Comparison with the Original Paper's Framework and Improvements

Table 11 systematically compares this study with the original paper across dimensions of study area, data source, methods, and validation. On this basis, Table 12 further summarizes the specific improvements made in this study to address the gaps in the original paper.

#v(0.5em)
#tablecaption[Table 11 Comparison between this study and the original paper (Naagar et al., 2024)]

#table3(
  columns: (auto, auto, auto),
  [Item], [Original Paper], [This Study],
  [Study area], [Mutawintji, NSW, Australia], [Tuwu-Yandong, Hami, Xinjiang],
  [Climate/Surface], [Semi-arid exposed terrain], [Hyper-arid exposed terrain (annual precipitation \<50 mm)],
  [Geological setting], [Sedimentary-metamorphic terrain], [Porphyry copper district (volcanic-intrusive)],
  [Data source], [Landsat 8 / ASTER / Sentinel-2], [Sentinel-2A L2A (10 bands)],
  [Main representation methods], [PCA / Canonical AE / Stacked AE], [PCA / Canonical AE / Stacked AE],
  [Extended method], [No explicit spatial context modeling], [Geo-DEC: geological indices + 3×3 spatial context + DEC],
  [Clustering method], [K-means], [K-means ($k=5$, $6$) + DEC soft assignment],
  [Clustering metrics], [Calinski-Harabasz, Davies-Bouldin, etc.], [Silhouette / DBI / CHI + spatial metrics],
  [Validation approach], [Clustering metrics + geological samples/knowledge], [Clustering metrics + false-color image comparison],
  [Objective], [Geological units mapping], [Lithological/alteration clustering in porphyry copper district],
)

#v(0.5em)
#tablewide([Table 12 Improvements addressing gaps in the original paper])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto),
  [Gap in Original Paper], [Improvement in This Study], [Effect of Improvement],
  [Validated at only one study area (Mutawintji, Australia)], [Transferred to hyper-arid porphyry copper district in NW China (Tuwu-Yandong)], [Validated cross-climate-zone and cross-tectonic-unit applicability],
  [Did not analyze scene-dependence of depth gain], [Systematically compared Canonical AE and SAE clustering on the same dataset], [Found shallow AE and deep SAE nearly equal in cluster separability; proposed "depth gain is scene-dependent"],
  [Did not systematically analyze bottleneck dimension effect], [Ablation experiment testing $z=3, 4, 5$], [Revealed $z=3$ causes class collapse; used $z=5$ as the main compromise configuration],
  [Only two clustering metrics (CHI, DBI)], [Introduced Silhouette coefficient as third metric], [Three-dimensional evaluation strengthens conclusion robustness],
  [Pixel-independent processing; spatial information mainly post-hoc], [Proposed Geo-DEC with geological band ratios, 3×3 spatial context, and DEC joint clustering loss], [Local agreement improved to 0.9348, isolated pixel ratio reduced to 0.0057; traditional separability metrics did not surpass AE/SAE, indicating its role as spatial mapping enhancement],
  [Geological interpretation mainly qualitative], [Quantitative analysis of 5 band ratios + fully automated mapping], [Corrected B11/B12 interpretation and retained C1 as a candidate clue requiring validation],
)
]
#set text(size: 12pt)

== Geological Interpretation

Integrating the spectral response analysis results from §4.7, the spatial correspondence with the false-color composite (Figure 2), and existing geological research on the Tuwu-Yandong area #super[5], Table 13 presents a comprehensive geological interpretation of the 6 clusters from SAE $z=5$, $k=6$.

#v(0.5em)
#tablewide([Table 13 Comprehensive geological interpretation of clusters (based on spectral response + spatial distribution + regional geological knowledge)])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto),
  [Cluster], [%], [Key Spectral Evidence], [Spatial Distribution], [Geological Interpretation], [Confidence],
  [C1], [18.0%], [B11/B12=0.992, B12/B8A=1.282; B11/B12 below 1 does not prove B12 absorption], [Banded-blocky in the north, partly coincident with false-color brownish-red areas], [Spectral-spatial candidate clue requiring geological-map or field validation], [Low to moderate],
  [C0], [24.2%], [B11/B12=1.045; moderate overall reflectance], [Large blocks in the south and central-east], [Unaltered or weakly altered intermediate-acid intrusive rocks (granodiorite/quartz diorite porphyry)], [Moderate],
  [C2], [37.2%], [All ratios intermediate, no extreme features], [Widely distributed across the area], [Volcanic-sedimentary rock matrix (andesite/tuff/clastic rocks)], [Moderate (largest area, most moderate spectra)],
  [C4], [6.9%], [B04/B02=1.197 (lowest), low reflectance across all bands], [Scattered blocks, partly along drainage/low-relief areas], [Mafic volcanic rocks (andesite) or topographic shadow areas], [Low],
  [C5], [11.1%], [B11/B12=1.057, B04/B02=1.412 (high)], [Study area margins, valleys, gully flanks], [Quaternary unconsolidated sediments/alluvial fans (with minor iron-oxide staining)], [Low; sediment context dominates],
  [C3], [2.6%], [B11/B12=1.061, B12/B8A=1.080 (lowest), B04/B02=1.447 (highest)], [Sporadic, spatially discontinuous], [Mixed pixels (alteration margin transitions / isolated special lithologies)], [Low; small and discontinuous],
)
]
#set text(size: 12pt)

*Interpretation basis and discussion:*

(1) *Cluster 1 should be treated as a candidate clue rather than a confirmed alteration zone.* The corrected physical interpretation is important: B11/B12=0.992 is the lowest among the six classes, but $"B11/B12" < 1$ means B11 is lower than B12 and therefore cannot prove B12 absorption. Its relatively high B12/B8A value and banded-blocky northern distribution still make it worth follow-up, especially because the regional wall-rock alteration of the Tuwu-Yandong porphyry copper deposit is dominated by sericitization and propylitization #super[5]. Nevertheless, this interpretation remains provisional until checked against geological maps or field observations.

(2) *Unaltered or weakly altered intrusive rocks (Cluster 0)* have B11/B12=1.045 and occur as large blocks, consistent with the occurrence of intermediate-acid intrusive bodies. Because C3 and C5 have even higher B11/B12 values, this class should not be described as the maximum-ratio class. Its exact lithological assignment (granodiorite vs. quartz diorite porphyry) requires further constraint from petrographic identification or published geological maps.

(3) *Volcanic-sedimentary rock matrix (Cluster 2)* is the largest class (37.2%), with moderate spectral characteristics and wide spatial distribution; it is not excluded that it contains multiple subclasses internally. The existence of this "background class" is consistent with the regional geological characteristic of Carboniferous volcanic-sedimentary sequences being dominant.

(4) *Low-reflectance class (Cluster 4) and sediment class (Cluster 5)* have lower confidence, mainly limited by the lack of topographic correction (DEM) and prior knowledge of sediment spectral endmembers. Cluster 4's low reflectance may originate from the mineral composition of mafic rocks (high dark-mineral content) or may be partially affected by topographic shadow. Cluster 5's spatial distribution coincides with valleys, gullies, and other negative landforms, but the spectral ratio signature (B04/B02=1.412) suggests possible iron-oxide staining, consistent with the characteristics of alluvial fan deposits in arid regions.

(5) *Mixed-pixel class (Cluster 3)* accounts for only 2.6%, is spatially discontinuous, and is interpreted as a mixed transitional type without independent geological meaning.

It must be emphasized that the above geological interpretation is spectral inference based on unsupervised clustering results; definitive geological attribution requires field verification or calibration against published large-scale geological maps.

== Limitations and Future Work

This study has the following limitations: (1) Unsupervised clustering lacks ground-truth validation; the geological meaning of cluster classes requires subsequent calibration. (2) Geo-DEC has introduced 3×3 statistical spatial context but is still not end-to-end convolutional spatial modeling; future work can further incorporate convolutional autoencoders (CAE) or graph neural networks to jointly utilize larger-scale spectral-spatial information. (3) The current version of Geo-DEC has not undergone systematic ablation of DEC loss weight, 3×3 spatial window, and enhanced feature combinations; therefore, this study can only state that "spatial continuity improves while traditional separability metrics decline under the current configuration," and cannot precisely decompose the individual contributions of geological indices, spatial statistics, and DEC loss. (4) Both K-means and DEC favor compact cluster structures and have limited adaptability to elongated or arc-shaped cluster distributions that may exist in spectral space; GMM or spectral clustering may be more suitable alternatives. (5) Only single-season summer imagery was used; seasonal differences in solar elevation angle and surface moisture content may affect spectral characteristics. (6) Only bottleneck settings with $z ≤ 5$ were tested; exploration of larger dimensions is insufficient.

Future work can proceed in the following directions: (1) Introduce DEM and topographic factors (slope, aspect, shadow correction) to eliminate topographic effects. (2) Use ASTER thermal infrared bands to supplement lithologically sensitive emissivity information. (3) Conduct quantitative consistency assessment between clustering results and known geological maps (e.g., Adjusted Rand Index ARI, Normalized Mutual Information NMI). (4) Conduct component ablation around Geo-DEC, separately testing "geological indices only," "spatial context only," "AE + K-means on 28D features," "different DEC weights," and "different neighborhood window sizes." (5) Compare more dimensionality reduction methods (t-SNE, UMAP, Variational Autoencoder VAE) for their effect on clustering. (6) Validate the generalization capability of this framework across a broader extent of the East Tianshan region.

= Conclusions

Taking the Tuwu-Yandong porphyry copper district in Xinjiang as the study area, this paper constructs a complete remote sensing geological analysis pipeline from preprocessing to unsupervised lithological clustering based on 10 spectral bands (B02--B12) of Sentinel-2A L2A imagery. The study adopts a two-stage logic: first migrating and comparing a spectral clustering baseline chain comprising Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means; then introducing Geo-DEC as a spatial-context enhancement extension to test its effectiveness in improving geological map-unit continuity. The main conclusions are as follows:

(1) PCA dimensionality reduction yields limited gain. PCA $z=3$ only raises CHI from 123,898 to 127,301 (+2.7%), indicating that the high-variance directions dominated by overall brightness in Sentinel-2 10-band data are not equivalent to the discriminative directions most favorable for K-means cluster separation.

(2) Nonlinear autoencoder representations are effective. The main configurations of Canonical AE and SAE significantly outperform Raw K-means and PCA, demonstrating that the reconstruction objective of autoencoders can preserve low-variance information useful for clustering discrimination, such as SWIR absorption-related band differences.

(3) Depth gain is scene-dependent. The shallow Canonical AE and deep SAE are surprisingly close in cluster separability metrics---the Canonical AE has slightly better CHI (147,239 vs. 144,423). However, SAE has advantages in reconstruction accuracy (MSE=0.00285 vs. 0.00466) and cluster compactness (DBI=0.6981 vs. 0.7338), indicating that deep structures still have value for tasks requiring high-fidelity spectral representation.

(4) Bottleneck dimension significantly affects clustering quality. $z=3$ causes severe class collapse (largest class 48.9%, CHI plummeting to 93,656). Although $z=4$ performs better on Silhouette and DBI, $z=5$ provides a practical compromise among class distribution, CHI, and spectral detail preservation, making it suitable as the main experimental latent-space dimension for this study area.

(5) Spectral ratio analysis provides quantitative support for geological interpretation, but the B11/B12 ratio must be interpreted in the correct direction. Cluster 1 (18.0%) has B11/B12=0.992 and B12/B8A=1.282; however, $"B11/B12" < 1$ means B11 is lower than B12 and does not demonstrate B12 absorption. C1 is therefore retained as a spectral-spatial candidate clue that requires geological-map or field validation.

(6) Geo-DEC is a spatial enhancement extension to the AE + K-means pipeline. It incorporates geological band ratios, 3×3 spatial context, and DEC joint clustering loss into a unified workflow, raising local agreement to 0.9348 and reducing isolated pixel ratio to 0.0057, demonstrating that spatial context is effective in improving geological map-unit continuity. However, its CHI and DBI do not surpass the AE/SAE family, so it should be positioned as a complementary method oriented toward mapping continuity and interpretability rather than a replacement for AE/SAE as the optimal model on traditional clustering metrics.

Synthesizing the above findings, this paper distills four core insights: First, the SAE+K-means unsupervised clustering framework remains effective in hyper-arid porphyry copper districts and possesses cross-climate-zone and cross-tectonic-unit transferability. Second, in this data scenario---where Sentinel-2 10-band data are dominated by linear colinearity and the number of surface classes is limited (4--6)---the clustering performance of a shallow autoencoder is on par with that of a deep SAE, suggesting that the gain from autoencoder depth is scene-dependent. Third, band-ratio analysis can provide useful candidate clues for geological interpretation, but B11/B12 alone cannot be treated as confirmed alteration evidence without correct physical interpretation and external validation. Fourth, Geo-DEC demonstrates that beyond the original two-stage framework, incorporating geological priors, spatial context, and clustering-objective joint optimization is an effective extension direction for improving the spatial continuity and interpretability of unsupervised geological mapping, though it does not replace AE/SAE as strong baselines on traditional cluster separability metrics. These insights respectively address the gaps in the original paper (Naagar et al., 2024) regarding cross-regional validation, depth-gain analysis, quantitative spectral interpretation, and spatial context utilization.

= References

#set par(first-line-indent: 0em, hanging-indent: 2em)
#set text(size: 9pt)

[1] van der Meer, F. D., van der Werff, H. M. A., van Ruitenbeek, F. J. A., et al. Multi- and hyperspectral geologic remote sensing: A review. _International Journal of Applied Earth Observation and Geoinformation_, 2012, _14_(1): 112--128.

[2] Asmussen, P., Conrad, O., Guenther, A., et al. Semi-automatic mapping of geological structures using UAV-based photogrammetric data and semi-automated classification methods. _Remote Sensing_, 2020, _12_(11): 1755.

[3] Drusch, M., Del Bello, U., Carlier, S., et al. Sentinel-2: ESA's optical high-resolution mission for GMES operational services. _Remote Sensing of Environment_, 2012, _120_: 25--36.

[4] Ge, W., Cheng, Q., Jing, L., et al. Lithological classification using Sentinel-2 multispectral data and a PCA-based feature extraction approach. _Remote Sensing_, 2020, _12_(4): 625.

[5] Han, C. M., Xiao, W. J., Zhao, G. C., et al. Geochronology and tectonic setting of the Tuwu-Yandong porphyry copper deposit, East Tianshan, Xinjiang. _Acta Petrologica Sinica_, 2006, _22_(1): 199--210.

[6] Cracknell, M. J., Reading, A. M. Geological mapping using remote sensing data: A comparison of five machine learning algorithms, their response to variations in the spatial distribution of training data and the use of explicit spatial information. _Computers & Geosciences_, 2014, _63_: 22--33.

[7] Naagar, S., Chawla, S., Bhattacharya, A., et al. Remote sensing framework for geological mapping via stacked autoencoders and clustering. _Advances in Space Research_, 2024, _74_(10): 4502--4516.

[8] Vincent, P., Larochelle, H., Lajoie, I., et al. Stacked denoising autoencoders: Learning useful representations in a deep network with a local denoising criterion. _Journal of Machine Learning Research_, 2010, _11_: 3371--3408.

[9] Kingma, D. P., Ba, J. Adam: A method for stochastic optimization. _arXiv preprint_, arXiv:1412.6980, 2014.

[10] Pedregosa, F., Varoquaux, G., Gramfort, A., et al. Scikit-learn: Machine learning in Python. _Journal of Machine Learning Research_, 2011, _12_: 2825--2830.

[11] Paszke, A., Gross, S., Massa, F., et al. PyTorch: An imperative style, high-performance deep learning library. _Advances in Neural Information Processing Systems_, 2019, _32_: 8026--8037.

[12] Rousseeuw, P. J. Silhouettes: A graphical aid to the interpretation and validation of cluster analysis. _Journal of Computational and Applied Mathematics_, 1987, _20_: 53--65.

[13] Davies, D. L., Bouldin, D. W. A cluster separation measure. _IEEE Transactions on Pattern Analysis and Machine Intelligence_, 1979, _1_(2): 224--227.

[14] Caliński, T., Harabasz, J. A dendrite method for cluster analysis. _Communications in Statistics_, 1974, _3_(1): 1--27.

#v(1em)
#set text(size: 12pt)
#set par(first-line-indent: 2em)

_Appendix: Code and Reproducibility_

The complete code and data processing pipeline for this project is available at https://github.com/LeoZhangXYJ/GeoCluster_S2. preprocess_s2.py (data preprocessing), cluster_kmeans_baseline.py (Baseline K-means + Elbow), pca_kmeans_baseline.py (PCA + K-means), ae_kmeans_baseline.py (Canonical AE + K-means), sae_kmeans.py (SAE + K-means), geo_dec_clustering.py (Geo-DEC: geological-index and spatial-context enhanced deep embedded clustering), analyze_cluster_spectra.py (cluster spectral response analysis), compute_all_metrics.py (unified metric computation), make_final_figures.py (comparison figure generation), make_interpretation_map.py (Python automated geological interpretation mapping). All random seeds are fixed at 42 to ensure reproducibility. The original paper's open-source code is available at https://github.com/sydney-machine-learning/autoencoders_remotesensing.
