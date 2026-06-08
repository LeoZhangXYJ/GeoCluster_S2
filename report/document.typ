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
    _underlined_cell("姓  名：", color: white),
    _underlined_cell("张项翌杰"),
    "",
    "",
    _underlined_cell("学  号：", color: white),
    _underlined_cell("3230103969"),
    "",
    "",
    _underlined_cell("指导老师：", color: white),
    _underlined_cell("陈宁华"),
    "",
    "",
    _underlined_cell("日  期：", color: white),
    _underlined_cell("2026.6.1"),
    "",
  )
}

#show: project.with(
  theme: "journal",
  course: "",
  title: "基于自编码器与 K-means 的 
  Sentinel-2 多光谱遥感影像岩性聚类研究",
  date: "",
  author: "张项翌杰",
  college: "地球科学学院",
  major: "浙江大学",
  semester: "2025-2026 春夏",
)

#set par(first-line-indent: 2em)

#abstract[
无监督聚类方法可在缺乏地面真值标签的偏远裸露区实现岩性填图，但现有深度学习聚类框架多在半干旱沉积岩区验证，其在极端干旱斑岩铜矿区的适用性及不同深度自编码器的相对增益尚不明晰。针对上述问题，本文以新疆哈密土屋-延东斑岩型铜矿区域为研究对象，将 Naagar 等（2024）的堆叠自编码器（SAE）+K-means 岩性填图框架从澳大利亚 Mutawintji 地区迁移至中国西北极端干旱矿区。基于 Sentinel-2A L2A 影像（2024-08-13，Tile T46TFM）的 10 个光谱波段（B02--B12），在去除云、阴影、水体等无效像元后，构建了 2,772,025 个有效像元的 10 维光谱数据集。本文设计了四组递进对比实验——Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means——系统回答了三个关键问题：（1）非线性降维是否优于线性降维？（2）深层自编码器是否必要？（3）bottleneck 维度如何影响聚类质量？实验结果表明：线性 PCA 对聚类质量的提升有限（CHI 仅从 123,898 提升至 127,301，+2.7%），深层 SAE 与浅层 Canonical AE 的聚类分离性出乎意料地接近——Canonical AE 的 CHI 甚至略优（147,239 vs 144,423），表明 Sentinel-2 10 波段数据的非线性结构有限，浅层非线性变换已能捕获主要的聚类判别信息；SAE 的优势体现在重建精度（MSE=0.00285 vs 0.00466）和簇紧凑性（DBI=0.6981 vs 0.7338）上。消融实验进一步揭示了 bottleneck 维度对聚类质量的关键影响：$z=3$ 导致严重类别塌缩（最大类占比 48.9%），$z=5$ 为最优压缩维度。在聚类结果基础上，本文通过光谱响应曲线与波段比值（B11/B12）的定量分析，识别出具有明确 SWIR 吸收特征的蚀变候选区（B11/B12=0.992），并构建了全自动 Python 遥感地质解释制图流程。本研究验证了 SAE+K-means 框架在极干旱斑岩铜矿区的跨区域适用性，并揭示了在该场景下深层 SAE 相对于浅层 AE 的边际增益特征，为无标签裸露区的无监督遥感岩性填图提供了可复现、可迁移的方法参考。

]

#keywords[Sentinel-2；堆叠自编码器；浅层自编码器；PCA；K-means 聚类；岩性识别；无监督学习；聚类评价指标；土屋-延东]

#abstract(name: strong[Abstract])[
Unsupervised clustering methods enable lithological mapping in remote, sparsely vegetated areas where field labels are scarce. However, existing deep-learning-based clustering frameworks have been validated primarily in semi-arid sedimentary terrains, and their applicability to hyper-arid porphyry copper districts—as well as the relative benefit of deep versus shallow autoencoders—remains unclear. To address this gap, this study migrates the stacked autoencoder (SAE) + K-means framework of Naagar et al. (2024) from the Mutawintji region of Australia to the Tuwu-Yandong porphyry copper district in Hami, Xinjiang, China. Using a Sentinel-2A L2A image (2024-08-13, Tile T46TFM) with 10 spectral bands (B02--B12) resampled to 20 m, we construct a dataset of 2,772,025 valid pixels after cloud, shadow, and water masking. Four workflows are compared—Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means—to systematically answer three questions: (1) Does nonlinear dimensionality reduction outperform linear methods? (2) Is a deep autoencoder necessary? (3) How does the bottleneck dimension affect clustering quality? Results show that PCA yields only marginal improvement over Raw K-means (CHI +2.7%), and, most notably, the shallow Canonical AE matches or slightly exceeds the deep SAE in cluster separability (CHI 147,239 vs. 144,423), suggesting that the nonlinear structure of Sentinel-2 10-band data is limited and shallow nonlinear transformations suffice for the main clustering structure. SAE retains advantages in reconstruction fidelity (MSE 0.00285 vs. 0.00466) and cluster compactness (DBI 0.6981 vs. 0.7338). The ablation experiment reveals that z=3 causes severe class collapse (largest class 48.9%), while z=5 is optimal. Quantitative spectral analysis identifies a high-confidence alteration candidate (C1, B11/B12=0.992) with clear SWIR absorption, and a fully scripted Python mapping pipeline replaces traditional GIS workflows for reproducible geological interpretation. This study validates the cross-regional applicability of the SAE+K-means framework in a hyper-arid porphyry copper setting and reveals the marginal gain of depth in this data regime, providing a reproducible and transferable workflow for unsupervised lithological mapping in unlabeled arid mineral districts.
]

#keywords(name: "Keywords")[Sentinel-2; lithological mapping; stacked autoencoder; canonical autoencoder; PCA; K-means clustering; unsupervised learning; porphyry copper deposit; Tuwu-Yandong]

= 引言

遥感技术因其大范围、多时相、低成本的优势，已经成为区域地质调查和矿产勘查中不可或缺的技术手段#super[1]。传统的遥感地质解译多依赖专家目视判读或监督分类方法，但在地面真值标签稀缺的偏远裸露区，无监督聚类方法具有独特优势——无需先验标签即可自动发现光谱特征的群聚结构，为地质填图提供客观的初始分类参考#super[2]。

Sentinel-2 卫星是欧洲空间局（ESA）哥白尼计划的核心任务之一，搭载多光谱成像仪（MSI），覆盖可见光至短波红外（443--2190 nm）共 13 个光谱波段，空间分辨率最高为 10 m#super[3]。其中，SWIR 波段（B11: 1610 nm, B12: 2190 nm）对含羟基（OH#super[−]）和碳酸根（CO₃#super[2−]）的热液蚀变矿物（如绢云母、绿泥石、方解石等）具有特征吸收特征，非常适用于斑岩型铜矿的蚀变分带研究#super[4]。

新疆哈密土屋-延东地区是中国西北重要的斑岩型铜矿成矿带，区内出露大量古生代火山-沉积岩系和中酸性侵入岩体，地表植被稀疏、基岩裸露度高，为多光谱遥感岩性识别提供了理想条件#super[5]。然而，传统的 K-means 聚类直接作用于 10 维光谱特征时，由于高维空间中光谱向量的噪声和冗余，聚类结果往往呈现明显的"椒盐噪声"——空间上破碎、孤立像元多，不利于地质单元的连续划分#super[6]。

在降维方法的选择上，主成分分析（PCA）是最经典的光谱降维手段，已在遥感地质中得到广泛应用#super[4]。然而 PCA 仅能捕获线性方差结构，难以建模光谱波段之间的非线性交互关系。自编码器（Autoencoder）作为一种经典的无监督深度学习模型，能够通过 encoder-decoder 结构学习数据的紧凑低维表示。Naagar 等（2024）在 _Advances in Space Research_ 上发表的研究系统比较了 PCA、canonical autoencoder 和 stacked autoencoder 三种降维方法结合 K-means 聚类在岩性填图中的效果，并在 Landsat 8、ASTER 和 Sentinel-2 三种数据源上进行了验证#super[7]。该研究指出，堆叠自编码器（SAE）通过多层非线性变换，可以捕获光谱波段之间的高阶交互关系，将高维光谱映射到低维隐空间，同时滤除噪声、保留主要光谱结构，其效果优于传统线性降维和浅层自编码器。

然而，该研究存在四个可供深化的方面。第一，原论文仅在澳大利亚 Mutawintji 一个研究区进行了验证，框架在不同气候带和大地构造单元下的跨区域可迁移性尚未得到检验。第二，原论文得出"SAE 全面优于 Canonical AE"的结论，但未进一步追问：深度增益是否具有场景依赖性？当数据本身的非线性结构有限时，深层网络是否仍然必要？第三，原论文未系统分析 bottleneck 维度对聚类质量的影响——使用了固定的隐空间维度，缺乏消融实验来揭示过窄 bottleneck 引发的类别塌缩风险。第四，原论文的聚类定量评估仅使用了两项指标（CHI 和 DBI），地质解译以定性描述为主，缺乏基于波段比值的定量光谱证据。

针对以上不足，本文围绕三个核心研究问题展开探索：（1）非线性降维是否显著优于线性降维？（2）深层 SAE 相对于浅层 Canonical AE 的增益有多大？（3）bottleneck 维度如何影响聚类质量？主要贡献与原论文不足的对应关系如下：

（1）*跨区域迁移验证*（针对不足一）：将 SAE+K-means 框架从澳大利亚半干旱沉积变质岩区迁移至中国西北极干旱斑岩铜矿区（新疆土屋-延东），验证了其跨气候带和跨大地构造单元的适用性；

（2）*深度增益的场景依赖性分析*（针对不足二）：首次在 Sentinel-2 10 波段数据上系统比较了浅层 Canonical AE 与深层 SAE 的聚类效果，发现两者在聚类分离性上出人意料地接近（CHI 147,239 vs 144,423），提出"深度增益具有场景依赖性"——当数据以线性相关为主导（PC1 解释 91.95% 方差）且地表类型有限（4--6 类）时，浅层非线性变换已能捕获主要判别结构；

（3）*Bottleneck 维度消融实验*（针对不足三）：系统测试了 $z=3, 4, 5$ 三种设置，发现 $z=3$ 导致严重类别塌缩（最大类占比 48.9%, CHI 骤降至 93,656），$z=5$ 为最优压缩维度，为后续应用提供了维度选择的经验参考；

（4）*多指标评估与定量光谱解译*（针对不足四）：引入 Silhouette 系数作为第三项聚类指标，并通过 5 个具有地质意义的波段比值（B11/B12、B12/B8A 等）对各聚类类别进行定量光谱分析，以 B11/B12=0.992 识别出高置信度蚀变候选区，弥补了原论文定性解译的不足；

（5）*全流程可复现性*：构建了从 Sentinel-2 SAFE 解压到最终地质解释图的完整 Python 预处理与制图流程，确保实验全流程可复现。

= 研究区与数据

== 研究区概况

研究区位于新疆哈密市西南约 120 km 的土屋-延东地区，地理坐标为 94.30°E--94.70°E, 42.02°N--42.32°N。该区地处东天山构造带，海拔约 800--1200 m，属典型的温带大陆性干旱气候，年降水量不足 50 mm，地表植被覆盖度极低（\<5%）。

区内出露的主要地质单元包括：石炭系火山-沉积岩系（安山岩、英安岩、凝灰岩）、华力西期中酸性侵入岩（花岗闪长岩、石英闪长斑岩）、以及新生代松散沉积物。土屋-延东斑岩型铜矿床赋存于石英闪长斑岩体及其围岩接触带中，发育典型的绢英岩化、青磐岩化蚀变分带#super[5]。这些蚀变矿物的光谱特征差异为多光谱遥感岩性聚类提供了物理基础。

== 数据源

本文使用 Sentinel-2A L2A（大气底层反射率）产品，影像获取日期为 2024-08-13，Tile 为 T46TFM。L2A 级别数据已经过辐射定标和大气校正，可直接用于地表反射率分析。

Sentinel-2 MSI 的波段设置如表 1 所示。

#v(0.5em)
#tablecaption[表 1 Sentinel-2 MSI 波段特征]

#table3(
  columns: (auto, auto, auto, auto),
  [波段], [中心波长 (nm)], [空间分辨率 (m)], [主要用途],
  [B02 (Blue)], [490], [10], [大气气溶胶、真彩色合成],
  [B03 (Green)], [560], [10], [植被、真彩色合成],
  [B04 (Red)], [665], [10], [铁氧化物、真彩色合成],
  [B05 (Red Edge 1)], [705], [20], [植被红边、地质],
  [B06 (Red Edge 2)], [740], [20], [植被红边、地质],
  [B07 (Red Edge 3)], [783], [20], [植被红边], 
  [B08 (NIR)], [842], [10], [植被、水体],
  [B8A (NIR Narrow)], [865], [20], [植被监测],
  [B11 (SWIR 1)], [1610], [20], [蚀变矿物（OH⁻吸收）],
  [B12 (SWIR 2)], [2190], [20], [蚀变矿物（CO₃²⁻/OH⁻吸收）],
)

本研究选用可见光-近红外-短波红外的 10 个波段（B02, B03, B04, B05, B06, B07, B08, B8A, B11, B12），以及用于云/阴影/水体掩膜的 SCL（Scene Classification Layer）波段。

#figurex(image("../data/processed/preview_true_color_B04_B03_B02.png", width: 68%), [研究区真彩色合成影像（B04/B03/B02）])

#figurex(image("../data/processed/preview_geology_B12_B8A_B02.png", width: 68%), [研究区地质假彩色合成影像（B12/B8A/B02）。\
短波红外波段赋予红色通道，突出含 OH⁻ 蚀变矿物信息。])

从图 1 可以看出，研究区地表呈灰黄-灰褐色调，植被覆盖极少，基岩裸露度高。图 2 假彩色合成中，褐红色区域指示了 SWIR 波段吸收较强的位置，可能对应绢云母化、绿泥石化等热液蚀变带。

= 方法

本文的方法框架如图 3 所示，总体包含四个阶段：（1）数据预处理，（2）特征构建与标准化，（3）四种降维+聚类方法的对比实验，（4）多指标定量评估。

#figurex(image("assets/image.png", width: 90%), [整体技术流程图])

== 数据预处理

=== 波段提取与重采样

从 Sentinel-2A L2A SAFE 产品中提取 10 个光谱波段（B02--B12）及 SCL 波段，将原始 JPEG2000 格式转换为内部处理格式。由于 Sentinel-2 各波段原生分辨率不同（见表 1），为保证空间一致性，将所有波段统一至 20 m 空间分辨率：20 m 波段（B05, B06, B07, B8A, B11, B12）直接使用原始网格；B08（10 m）通过双线性插值重采样至 20 m 参考网格；B02, B03, B04 的 10 m 版本在本研究中未使用，直接使用其 20 m 重采样版本。

=== AOI 裁剪

根据研究区经纬度范围（94.30°E--94.70°E, 42.02°N--42.32°N），利用 rasterio 的 transform_bounds 将 WGS84 坐标转换至影像自身 CRS（UTM 第 46 带, EPSG:32646），然后创建裁切窗口。裁剪后影像尺寸为 1681 × 1695 像素。

=== SCL 掩膜

Sentinel-2 L2A 产品中附带 SCL（Scene Classification Layer）波段，按像元场景类型分为 11 类。本文剔除以下类别的像元：0（No Data）、1（饱和/缺陷）、2（暗区）、3（云阴影）、6（水体）、8（中概率云）、9（高概率云）、10（卷云）、11（雪/冰）。保留类别 4（植被）、5（裸地）、7（低概率云）作为有效像元。

掩膜后，有效像元数为 2,772,025，占总像元的 97.29%，表明研究区以裸地和稀疏植被为主，满足遥感地质分析的基础条件。同时，还过滤了任意光谱波段反射率 ≤0 的异常值。

== 光谱标准化

将 10 个波段按像元维度展开为 $(N, 10)$ 矩阵，其中 $N=2,772,025$。采用 Z-score 标准化（StandardScaler），使每个波段均值为 0、标准差为 1，消除各波段之间因传感器增益差异造成的数值尺度不同，使各波段在聚类中贡献均等。

== 对比方法设计

为系统评估不同降维策略对聚类效果的影响，本文设计了四组方法进行对比：原始光谱直接聚类（Raw K-means）、主成分分析降维后聚类（PCA + K-means）、浅层自编码器降维后聚类（Canonical AE + K-means）以及堆叠自编码器降维后聚类（SAE + K-means）。四种方法的对比如表 2 所示。

#v(0.5em)
#tablecaption[表 2 四种对比方法的特征]

#table3(
  columns: (auto, auto, auto, auto, auto),
  [方法], [降维类型], [网络/变换结构], [特征维度], [参数数量],
  [Raw K-means], [无降维], [——], [10], [——],
  [PCA + K-means], [线性], [协方差特征分解], [$z=3$, $5$], [——],
  [Canonical AE + K-means], [非线性（浅层）], [$10→16→z→16→10$], [$z=5$], [1,067],
  [SAE + K-means], [非线性（深层）], [$10→32→16→z→16→32→10$], [$z=3$, $4$, $5$], [1,699],
)

这四组方法构成了一个递进的对比链条：Raw K-means 作为无降维基线；PCA 检验线性降维是否足够；Canonical AE 检验引入非线性变换的必要性；SAE 检验增加网络深度是否带来额外增益。这一设计直接对应了 Naagar 等（2024）在原论文中的核心对比框架。

=== Raw K-means（基线）

直接将标准化后的 10 维光谱特征输入 K-means 聚类。使用 Elbow 方法在训练集 200,000 样本上计算 $k=2"–"12$ 的 inertia 曲线，采用"点到直线最大距离法"自动选取拐点。

=== PCA + K-means

主成分分析（PCA）通过对协方差矩阵进行特征分解，将原始 10 维光谱数据投影到方差最大的正交方向上。本文实验 PCA 降维至 $z=3$ 和 $z=5$，降维后在 PCA 特征空间执行 K-means 聚类（$z=3$ 时 $k=5$，$z=5$ 时 $k=6$）。PCA 基线用于检验：是否简单的线性方差保留即可达到与非线性降维相当的聚类效果？

=== Canonical AE + K-means（浅层自编码器）

Canonical AE 采用单隐藏层结构 10 → 16 → z → 16 → 10，与 SAE 的双隐藏层 10 → 32 → 16 → z → 16 → 32 → 10 形成深度对比。两个模型均使用 ReLU 激活函数和相同的训练配置（Adam 优化器, lr=1e-3, batch_size=4096, 训练 30 epochs, 训练样本 300,000）#super[9]。通过比较 Canonical AE 与 SAE 的聚类效果，可以分离"非线性变换"与"深层层级表示"的各自贡献。

=== Stacked AE + K-means（堆叠自编码器）

SAE 的 encoder 结构为 10 → 32 → 16 → z，decoder 为对称结构 z → 16 → 32 → 10。该结构参考堆叠自编码器逐层压缩并学习低维表示的思想#super[8]，训练目标为最小化均方误差（MSE）重建损失：

$
cal(L)_"MSE" = 1/N sum_(i=1)^N |x_i - hat(x)_i|^2
$

其中 $x_i$ 为标准化后的 10 维光谱向量，$hat(x)_i = "Decoder"("Encoder"(x_i))$ 为重建向量。训练完成后，将所有 $N=2,772,025$ 个有效像元通过 encoder 编码为 $z$ 维特征向量，在隐空间执行 K-means 聚类。为研究 bottleneck 维度的影响，本文比较 $z=3, 4, 5$ 三种设置。

== 聚类评价指标

为定量评估聚类质量，本文引入三项常用的无监督聚类评价指标：

*Silhouette 系数（轮廓系数）*衡量每个样本与自身簇的相似度相对于与最近邻簇的相似度，取值范围为 $[-1, 1]$，值越大表示簇内紧凑且簇间分离良好#super[12]。

*Davies-Bouldin 指数（DBI）*衡量各簇之间的平均相似度，值越小表示簇间分离性越好#super[13]。

*Calinski-Harabasz 指数（CHI）*定义为簇间离散度与簇内离散度的比值，值越大表示簇间方差大、簇内方差小，聚类结构更优#super[14]。

由于全量 2,772,025 个像元上计算 Silhouette 系数的计算复杂度为 $O(N^2)$，本文在随机抽样的 100,000 个有效像元上计算三项指标，确保可复现性（随机种子固定为 42）。

== 与原论文框架的实现对齐

本文的方法框架参考了 Naagar 等（2024）的开源实现（https://github.com/sydney-machine-learning/autoencoders_remotesensing）。原论文框架包含 PCA、canonical autoencoders、stacked autoencoders 与 K-means 的组合，用于生成 clustered maps 并解译为 lithological maps。表 3 给出了本文实现与原论文框架的对应关系。

#v(0.5em)
#tablecaption[表 3 本文实现与原论文框架的对应关系]

#table3(
  columns: (auto, auto, auto),
  [环节], [原论文/开源代码], [本文实现],
  [数据源], [Sentinel-2（及 Landsat 8、ASTER）], [Sentinel-2A L2A T46TFM],
  [预处理], [数据集特定预处理（需用户自行实现）], [自定义 SAFE 解压、波段提取、SCL 掩膜、AOI 裁剪],
  [降维方法], [PCA / Canonical AE / Stacked AE], [PCA / Canonical AE / Stacked AE],
  [聚类方法], [K-means], [K-means ($k=5$, $6$)],
  [输出], [Clustered maps], [GeoTIFF + PNG 聚类图],
  [验证], [聚类指标 + 地质知识/样点], [Silhouette / DBI / CHI + 假彩色对照],
)

原论文的 GitHub 仓库提供了 Autoencoder_Landsat8.ipynb、Autoencoder_ASTER.ipynb 和 Autoencoder_Sentinel2.ipynb，但说明具体的 dataloader、预处理和后处理需要用户根据数据集自行实现。本文在此基础上完成了针对 Sentinel-2 L2A 产品的完整预处理管线（SCL 掩膜、AOI 裁剪、波段重采样与堆叠），并在研究区迁移（澳大利亚 Mutawintji → 中国新疆土屋-延东）的背景下进行了全流程复现与方法对比。

= 实验与结果

== 实验环境

本文实验环境配置如下：CPU 为 Intel 平台（无 GPU 加速），Python 3.x，主要依赖库包括 rasterio 1.5.0（栅格数据读写）、PyTorch（自编码器训练）#super[11]、scikit-learn 1.7.2（K-means、PCA 与预处理）#super[10]、NumPy 2.3.3、Matplotlib 3.10.7。

== Baseline: Raw K-means 与 Elbow 分析

=== Elbow 分析

在训练集 200,000 样本上计算 $k=2"–"12$ 的 K-means inertia 曲线，采用"点到直线最大距离法"自动选取 elbow 点。

#v(0.5em)
#tablecaption[表 4 Elbow curve 数据（部分）]

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

自动选取结果为 $k=5$，此处 inertia 下降速率出现明显拐点，继续增大 $k$ 对 inertia 改善有限。

#figurex(image("../results/cluster_baseline/elbow_curve.png", width: 65%), [Baseline K-means Elbow 曲线（$k=2"–"12$）。\
$k=5$ 处到首尾连线的距离最大，被自动选为最优聚类数。])

=== Baseline 聚类结果

Baseline $k=5$ 的类别分布如表 5 所示。

#v(0.5em)
#tablecaption[表 5 Baseline K-means 类别分布 ($k=5$)]

#table3(
  columns: (auto, auto, auto),
  [Cluster ID], [Pixel Count], [Percentage],
  [0], [1,041,958], [37.6%],
  [1], [674,396], [24.3%],
  [2], [635,695], [22.9%],
  [3], [251,487], [9.1%],
  [4], [168,489], [6.1%],
)

最大类占比为 37.6%，最小类占比为 6.1%，类别分布相对均衡。三项聚类指标分别为：Silhouette=0.3709，DBI=0.8039，CHI=123,898。

== PCA + K-means 基线

=== 方差解释分析

对标准化后的 10 维光谱数据进行 PCA 分解，各主成分的方差解释比例如图 5 所示。第一主成分（PC1）解释了 91.95% 的总方差，前 3 个主成分累计解释 99.53%，前 5 个主成分累计解释 99.84%。

#figurex(image("../results/cluster_pca/pca_explained_variance.png", width: 65%), [PCA 方差解释分析。\
(a) 各主成分的单独方差解释比例；(b) 累计方差解释曲线。\
PC1 解释了 91.95% 的方差，表明 Sentinel-2 10 波段之间存在极强的共线性——各波段反射率高度同步变化，主要受整体亮度/反照率主导。])

=== PCA + K-means 聚类结果

对 PCA 降至 $z=3$ 和 $z=5$ 的特征分别进行 K-means 聚类，结果如表 6 所示。

#v(0.5em)
#tablecaption[表 6 PCA + K-means 聚类结果]

#table3(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  [配置], [$k$], [Max%], [Min%], [Silhouette ↑], [DBI ↓], [CHI ↑],
  [PCA $z=3$], [5], [38.0%], [5.9%], [0.3796], [0.7866], [127,301],
  [PCA $z=5$], [6], [30.3%], [3.6%], [0.3485], [0.8385], [122,034],
)

PCA $z=3$, $k=5$ 的类别均衡性与 Baseline（Max 37.6%, Min 6.1%）几乎一致，CHI 仅从 123,898 提升至 127,301（+2.7%），提升幅度有限。PCA $z=5$, $k=6$ 虽然最大类占比降至 30.3%，但出现了极小的类别（3.6%），且三项聚类指标均劣于 $z=3$ 配置。该结果表明：线性 PCA 降维虽然能有效压缩数据维度（前 3 维保留 99.53% 方差），但保留的方差结构对 K-means 聚类边界的优化贡献有限，因为 PCA 的优化目标（最大方差投影）与 K-means 的优化目标（最小簇内平方和）并不一致。

== 自编码器训练结果

=== SAE 训练收敛

SAE 在 30 个 epoch 内训练收敛情况良好。

#v(0.5em)
#tablecaption[表 7 SAE 训练重建误差（Reconstruction MSE）]

#table3(
  columns: (auto, auto, auto, auto),
  [Epoch], [$z=3$ (loss)], [$z=4$ (loss)], [$z=5$ (loss)],
  [1], [0.6605], [0.7220], [0.7654],
  [5], [0.0145], [0.0631], [0.0180],
  [10], [0.0047], [0.0058], [0.0050],
  [15], [0.0044], [0.0050], [0.0044],
  [20], [0.0042], [0.0047], [0.0039],
  [25], [0.0041], [0.0045], [0.0030],
  [30], [0.0040], [0.0045], [*0.0029*],
)

注：$z=3$ 的训练使用 60 epochs 以达到更稳定的收敛。

$z=4$ 在前 10 epoch 收敛较快但后续 plateau 在 0.0045 附近；$z=5$ 虽然初始 loss 更高（0.765），但在 epoch 20 之后持续下降，最终收敛至 0.00285。该趋势表明，稍大的 bottleneck 虽然初期训练难度略高，但最终能够捕获更多的光谱细节用于重建。

#figurex(image("../results/cluster_sae/sae_training_loss_z4.png", width: 65%), [SAE $z=4$ 训练损失曲线（30 epochs）])

#figurex(image("../results/cluster_sae/sae_training_loss_z5.png", width: 55%), [SAE $z=5$ 训练损失曲线（30 epochs）。\
$z=5$ 的最终重建误差 0.00285 为三种配置中最低。])

=== Canonical AE 与 SAE 训练对比

Canonical AE（10→16→5→16→10）与 SAE（10→32→16→5→16→32→10）在相同训练配置下的收敛过程对比如表 8 所示。

#v(0.5em)
#tablecaption[表 8 Canonical AE vs SAE 训练重建误差对比 ($z=5$)]

#table3(
  columns: (auto, auto, auto),
  [Epoch], [Canonical AE (loss)], [SAE (loss)],
  [1], [0.7065], [0.7654],
  [5], [0.0694], [0.0180],
  [10], [0.0319], [0.0050],
  [15], [0.0072], [0.0044],
  [20], [0.0053], [0.0039],
  [25], [0.0049], [0.0030],
  [30], [*0.0047*], [*0.0029*],
)

从重建误差看，SAE 在早期训练阶段即取得更低损失（epoch 5: 0.0180 vs Canonical AE 的 0.0694），并在最终收敛时保持优势（MSE=0.00285 vs 0.00466）。Canonical AE 作为参数量较小的浅层非线性强基线，仍能学习有效的聚类判别表示；SAE 则凭借更深的层级结构和更高的参数量（1,699 vs 1,067）进一步提高了光谱重建保真度。

#figurex(image("../results/cluster_ae/ae_training_loss_z5.png", width: 55%), [Canonical AE $z=5$ 训练损失曲线（30 epochs）。\
最终重建误差 0.00466，高于 SAE 的 0.00285。])

//#pagebreak(weak: true)

== 综合聚类指标对比

表 9 汇总了全部实验配置的三项聚类指标与类别分布。

#v(0.5em)
#tablewide([表 9 全部实验配置的聚类指标对比])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [Method], [Feature Dim.], [$k$], [Silhouette ↑], [DBI ↓], [CHI ↑], [Max%], [Min%], [Recon. MSE],
  [Raw K-means], [10], [5], [0.3709], [0.8039], [123,898], [37.6%], [6.1%], [——],
  [PCA + K-means], [3], [5], [0.3796], [0.7866], [127,301], [38.0%], [5.9%], [——],
  [PCA + K-means], [5], [6], [0.3485], [0.8385], [122,034], [30.3%], [3.6%], [——],
  [SAE + K-means], [3], [5], [0.3735], [0.8046], [93,656], [*48.9%*], [5.0%], [0.00404],
  [SAE + K-means], [4], [6], [*0.4577*], [*0.6706*], [135,377], [42.0%], [4.7%], [0.00447],
  [SAE + K-means], [5], [6], [0.4165], [0.6981], [144,423], [37.2%], [2.6%], [*0.00285*],
  [*Canonical AE + K-means*], [*5*], [*6*], [*0.4166*], [0.7338], [*147,239*], [*36.0%*], [5.0%], [0.00466],
)
]
#set text(size: 10pt)

从表 9 可以得出以下主要发现：

（1）*线性降维增益有限*。PCA $z=3$ 仅将 CHI 从 123,898 提升至 127,301（+2.7%），Silhouette 的改善也不显著（0.3709 → 0.3796）。这表明虽然 PCA 前 3 维保留了 99.53% 的总方差，但这些方差主要由整体亮度主导，与聚类边界的优化目标（最大化簇间分离性）并不一致。

（2）*非线性自编码器一致优于线性和无降维基线*。Canonical AE 和 SAE 的所有配置（除 $z=3$ 类别塌缩外）的 CHI 均 ≥135,377，显著高于 Raw K-means（123,898）和 PCA（127,301），验证了非线性特征学习对聚类质量的改善作用。

（3）*浅层 Canonical AE 与深层 SAE 聚类质量接近*。两者在 Silhouette（0.4166 vs 0.4165）上几乎相同，CHI 方面 Canonical AE 甚至略优（147,239 vs 144,423）。但 SAE 在 DBI（0.6981 vs 0.7338）和重建精度（MSE 0.00285 vs 0.00466）上具有明显优势，表明更深层的结构有助于学习更紧凑的光谱表示。

（4）*SAE $z=3$ 出现严重的类别塌缩*。CHI 骤降至 93,656（所有方法中最低），最大类占比达到 48.9%，证实过窄的 bottleneck 导致不同光谱类型被强制映射至相近的隐空间位置。

== 聚类结果可视化

=== SAE 消融实验对比

#figurex(image("../results/cluster_sae/sae_kmeans_k5_z3.png", width: 88%), [消融实验：SAE $z=3$, $k=5$ 聚类结果。\
绿色类大面积扩张（占比 48.9%），类别塌缩明显。])

$z=3$ 的聚类结果暴露出严重的类别塌缩问题。如图 9 所示，绿色类别（Cluster 2）几乎占据了研究区近半面积（48.9%），而本应具有光谱差异的地质单元被强制合并。空间上，原本在 $z=5$ 中可分辨的块状结构在此处被吞并为大面积均质斑块。这一现象验证了过窄 bottleneck 的破坏性：3 维隐空间不足以编码 4--6 种地表类型的光谱差异，不同类别在隐空间中高度重叠，K-means 无法有效划分决策边界。

#figurex(image("../results/cluster_sae/sae_kmeans_k6_z4.png", width: 88%), [消融实验：SAE $z=4$, $k=6$ 聚类结果。\
最大类占 42.0%，较 $z=3$ 改善但仍偏高，出现两个 ~4.7% 小类。])

$z=4$ 的聚类质量介于 $z=3$ 与 $z=5$ 之间。最大类占比从 48.9% 降至 42.0%，类别均衡性有所改善，但提升幅度有限——CHI 仅恢复至 135,377，仍明显低于 $z=5$ 的 144,423。图 10 中绿色类别的空间范围明显收缩，西北部和东南部出现了新的类别斑块，但整体空间连续性与 $z=3$ 相比改善不显著。同时，$z=4$ 产生了两个仅占 ~4.7% 的极小类，这些过小类别可能对应光谱异常点或混合像元，而非真实的地质单元。该配置表明：4 维隐空间已开始容纳更多类别信息，但仍不足以充分解耦研究区内主要地物的光谱差异。

#figurex(image("../results/cluster_sae/sae_kmeans_k6_z5.png", width: 88%), [消融实验：SAE $z=5$, $k=6$ 聚类结果。\
最大类占 37.2%，类别均衡性最优，空间连续性良好。])

#pagebreak(weak: true)

=== 四种方法综合对比

#figurewide(image("../results/final_figures/method_comparison_2x2.png", width: 88%), [四种方法聚类结果对比。\
(a) Raw K-means $k=5$；(b) PCA + K-means $z=5$, $k=6$；\
(c) Canonical AE + K-means $z=5$, $k=6$；(d) SAE + K-means $z=5$, $k=6$。])

对比图 12(a)--(d) 可以看出：

- *Raw K-means*（图 12a）椒盐噪声最重，空间上破碎、孤立像元多，不利于地质单元的连续划分。
- *PCA + K-means*（图 12b）与 Raw K-means 视觉效果接近，线性降维未能显著改善空间连续性，与定量指标一致。
- *Canonical AE + K-means*（图 12c）空间连续性明显优于 PCA，大尺度块状结构清晰，但细节纹理略逊于 SAE。其类别分布最均衡（Max=36.0%），CHI 最优（147,239）。
- *SAE + K-means*（图 12d）在保持良好空间连续性的同时，保留了更多细粒度光谱差异。虽然 CHI 和 Silhouette 与 Canonical AE 接近，但重建精度（MSE=0.00285）和簇紧凑性（DBI=0.6981）更优。

#figurewide(image("../results/final_figures/final_comparison_2x3.png", width: 88%), [综合对比图（2×3）。\
(a) Sentinel-2 真彩色合成 B04/B03/B02；(b) 地质假彩色合成 B12/B8A/B02；\
(c) Raw K-means $k=5$；(d) PCA + K-means $z=5$, $k=6$；\
(e) Canonical AE + K-means $z=5$, $k=6$；(f) SAE + K-means $z=5$, $k=6$。])

//#pagebreak(weak: true)

== 聚类类别的光谱响应分析

为进一步揭示各聚类类别的地质含义，本文对 SAE $z=5$, $k=6$ 的 6 个聚类类别进行了光谱响应特征分析。对每个类别的像元，计算 10 个波段的均值与标准差，并提取 5 个具有地质指示意义的波段比值（B11/B12、B12/B8A、B11/B8A、B04/B02、B08/B04），结果如图 14 和表 10 所示。

#figurewide(image("../results/cluster_spectra/cluster_spectral_profiles.png", width: 80%), [各聚类类别在 10 个波段上的平均光谱反射率曲线（SAE $z=5$, $k=6$）。\
阴影带表示 ±1 标准差。灰色区域标注了 SWIR 波段（B11: 1610 nm, B12: 2190 nm），该区域对含 OH⁻/CO₃²⁻ 的蚀变矿物具有特征吸收。\
Cluster 1 在 B11--B12 区间呈现最显著的斜率下降，指示 SWIR 吸收特征。])

#v(0.5em)
#tablewide([表 10 各聚类类别的关键波段比值（均值）])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  [Cluster], [占比], [B11/B12], [B12/B8A], [B11/B8A], [B04/B02], [B08/B04], [光谱特征判读],
  [0], [24.2%], [*1.045*], [1.170], [1.222], [1.375], [1.045], [B11/B12 最高，SWIR 吸收最弱；整体反射率中等],
  [1], [18.0%], [*0.992*], [1.282], [1.265], [1.254], [1.021], [B11/B12 最低，B12 相对 B11 明显低值 → OH⁻ 吸收],
  [2], [37.2%], [1.022], [1.231], [1.255], [1.330], [1.041], [各项比值居中，无极端特征，面积最大的背景类],
  [3], [2.6%], [1.061], [*1.080*], [1.144], [*1.447*], [1.039], [B12/B8A 最低，B04/B02 最高；极小类，可能混合像元],
  [4], [6.9%], [1.008], [1.175], [1.178], [1.197], [1.009], [B11/B12 接近 1.0，B04/B02 最低；整体反射率偏低],
  [5], [11.1%], [1.057], [1.131], [1.194], [1.412], [1.046], [B11/B12 次高；中等反射率，可见光波段斜率较大],
)
]
#set text(size: 10pt)

从表 10 和图 14 可以得出以下光谱判读：

*（1）Cluster 1 —— 明显的 SWIR 吸收类（18.0%）*。该类的 B11/B12 比值（0.992）为 6 类中最低，且在光谱曲线图 14 中 B11→B12 区间呈现明显的反射率下降。在 Sentinel-2 的波段设置中，B12（2190 nm）恰好覆盖了绢云母（sericite）、绿泥石（chlorite）等含 Al--OH 和 Mg--OH 键的蚀变矿物的特征吸收谷，而 B11（1610 nm）位于吸收谷外侧作为参照#super[4]。B11/B12 < 1.0 表明 B12 反射率低于 B11，即存在 SWIR 吸收，是指示热液蚀变的最直接光谱证据。该类同时具有最低的 B04/B02（1.254），表明铁氧化物含量相对较低。

*（2）Cluster 0 —— SWIR 吸收最弱类（24.2%）*。B11/B12=1.045，为 6 类中最高，表明 B12 反射率接近甚至略高于 B11，无明显的 OH⁻ 吸收特征。该类整体反射率中等偏高，可能对应未蚀变或弱蚀变的中酸性岩体。

*（3）Cluster 2 —— 光谱背景类（37.2%）*。所有比值均处于 6 类的中间水平，无极端高值或低值。该类面积最大、光谱特征最中庸，可能代表研究区内广泛分布的火山-沉积岩基质。

*（4）Cluster 4 —— 低反射率类（6.9%）*。B04/B02（1.197）和 B08/B04（1.009）均为 6 类中最低，表明可见光波段和 NIR 波段的反射率整体偏低，可能对应基性火山岩（如安山岩）或地形阴影/低洼区域。

*（5）Cluster 3 —— 极小异常类（2.6%）*。B12/B8A=1.080 为 6 类中最低，B04/B02=1.447 为最高。该类占比极小（仅 2.6%），光谱特征与其他类差异显著，可能代表混合像元（如蚀变带边缘与沉积物的过渡区）或局部特殊岩性露头。

*（6）Cluster 5 —— 中等反射率过渡类（11.1%）*。B11/B12=1.057，SWIR 吸收不明显；B04/B02=1.412 较高，可见光红波段相对蓝波段反射率偏高，可能对应含少量铁氧化物染色的第四系沉积物或洪积扇堆积。



#figurex(image("../results/cluster_spectra/cluster_spectral_profiles_per_class.png", width: 78%), [各聚类类别的单独光谱响应曲线（含 ±1σ 误差带）])

综上，光谱响应分析为聚类结果的地质解译提供了定量依据：Cluster 1 的 SWIR 吸收特征最为明确，最可能对应热液蚀变带；Cluster 4 的低反射率特征指示基性岩或阴影区；其余类别反映了不同程度的未蚀变岩体与沉积物背景。


== 遥感地质解释图生成

为避免交互式 GIS 软件人工制图过程带来的不可复现性，本文采用 rasterio 与 matplotlib 构建了全自动 Python 制图流程，生成最终遥感地质解释图（图 16）。具体流程为：首先读取裁剪后的 10 波段 Sentinel-2 栅格数据，提取 B12（2190 nm）、B8A（865 nm）和 B02（490 nm）构建地质假彩色底图；随后读取 SAE $z=5$, $k=6$ 的聚类 GeoTIFF，将 6 个聚类类别以固定配色方案半透明叠加（alpha=0.45）到底图之上；对 C1（蚀变候选类）的 mask 进行二值形态学处理去除孤立噪点后，以红色轮廓高亮标注其空间范围；最后添加聚类图例（含地质解释文字）、比例尺和指北针，以 300 dpi 输出。

#figurewide(image("../results/final_figures/python_final_interpretation_map.png", width: 50%), [基于 Python 自动生成的遥感地质解释图。\
底图为 Sentinel-2 B12/B8A/B02 地质假彩色影像，彩色半透明图层为 SAE $z=5$, $k=6$ 聚类结果（alpha=0.45）。\
C1 类以红色轮廓和箭头标注，具有最低 B11/B12 比值和明显 SWIR 吸收特征，被解释为潜在热液蚀变带候选区。\
图中包含 6 类地质解释图例、比例尺、指北针和可复现脚注，生成流程完全脚本化。])

该自动化制图流程的优势在于：（1）图件生成过程完全可复现，只需重新运行脚本即可；（2）更换研究区或聚类结果后，可一键重新生成；（3）避免了 GIS 软件人工调参带来的图件风格不一致问题。

= 讨论

== PCA 为什么提升有限

实验结果表明，PCA 降维对聚类质量的改善微乎其微（CHI +2.7%）。这一现象的根本原因在于 PCA 与 K-means 的优化目标不一致：PCA 以最大化投影方差为目标，而 K-means 以最小化簇内平方和为目标。Sentinel-2 10 波段数据的 PC1 解释了 91.95% 的方差，主要捕获各波段反射率的整体强度变化（亮度/反照率），但聚类边界的确定往往依赖于波段比值、吸收深度等高阶光谱特征，这些信息散布在低方差的主成分中。PCA 保留前几个高方差主成分时可能丢弃了这些对聚类有用的判别性信息。

相比之下，自编码器的 MSE 重建目标迫使 bottleneck 保留所有有助于区分不同光谱向量的信息——包括那些方差占比小但对聚类判别重要的波段间差异（如 SWIR 吸收特征）。这解释了为什么非线性 AE 的聚类效果显著优于 PCA。

== 深度的影响：深层自编码器是否总是必要的？

本实验中最引人注目的发现是：浅层 Canonical AE 的聚类质量（CHI=147,239）与深层 SAE（CHI=144,423）几乎持平，甚至在类别均衡性上略优（Max 36.0% vs 37.2%）。这一发现对原论文（Naagar et al., 2024）中"stacked autoencoders 比 canonical autoencoders 更好"的结论提出了重要的场景化补充——在原论文的半干旱沉积变质岩区，SAE 的优势是明确的；但在本研究的极干旱斑岩铜矿区，两者的聚类分离性几乎无差异。这提示我们，自编码器深度对聚类质量的增益可能存在"场景依赖性"：数据非线性越强、类别结构越复杂，深度网络的增益越大；反之，当数据以线性相关为主导时，浅层网络已经足够。

可能的解释如下：（1）Sentinel-2 的 10 个光谱波段之间以线性相关性为主（PC1 解释了 91.95% 方差），非线性结构相对有限，因此浅层 AE 已能捕获大部分非线性关系；（2）土屋-延东研究区的地表类型（4--6 类）较为简单，不需要过深的层级表示来分离复杂类别；（3）SAE 的额外参数量（1,699 vs 1,067）在有限训练样本（300,000）上的优势未能充分体现。

尽管如此，SAE 在 DBI 指标（0.6981 vs 0.7338）和重建精度（MSE 0.00285 vs 0.00466）上的优势表明，更深的网络确实学习了更紧凑和更精确的光谱表示。在实际应用中，如果下游任务对重建精度要求较高（如异常检测、光谱解混），SAE 仍是更优选择。

== Bottleneck 维度的选择

Bottleneck 维度 $z$ 是自编码器流程中的关键超参数。本实验中 $z=3$ 导致严重类别塌缩（SAE $z=3$ 的 CHI=93,656，最大类占比 48.9%），$z=4$ 有所改善但类别均衡性仍不理想（Max 42.0%），$z=5$ 达到最佳平衡。研究区存在 4--6 种主要的地表覆盖/岩性类型（石英闪长斑岩、安山岩、花岗闪长岩、第四系沉积物、蚀变带），5 维隐空间恰好提供了足够的自由度来编码这些类别的光谱差异。

值得注意的是，本实验中仅测试了 $z ≤ 5$ 的设置。$z=6$ 或更大的 bottleneck 是否能在不过度引入噪声的前提下进一步提升聚类质量，值得在后续工作中探索。

== 与原论文框架的对比与改进

表 11 从研究区、数据源、方法和验证等维度系统比较了本文与原论文的异同。在此基础上，表 12 进一步归纳了本文针对原论文不足所做出的具体改进。

#v(0.5em)
#tablecaption[表 11 本文与原论文（Naagar et al., 2024）的对比]

#table3(
  columns: (auto, auto, auto),
  [项目], [原论文], [本文],
  [研究区], [Mutawintji, NSW, Australia], [新疆哈密土屋-延东],
  [气候/地表], [半干旱裸露区], [极干旱裸露区（年降水 \<50 mm）],
  [地质背景], [沉积-变质岩区], [斑岩铜矿区（火山-侵入岩）],
  [数据源], [Landsat 8 / ASTER / Sentinel-2], [Sentinel-2A L2A (10 bands)],
  [降维方法], [PCA / Canonical AE / Stacked AE], [PCA / Canonical AE / Stacked AE],
  [聚类方法], [K-means], [K-means ($k=5$, $6$)],
  [聚类指标], [Calinski-Harabasz, Davies-Bouldin 等], [Silhouette / DBI / CHI],
  [验证方式], [聚类指标 + 地质样点/知识], [聚类指标 + 假彩色图对照],
  [目标], [geological units mapping], [斑岩铜矿区岩性/蚀变聚类],
)

#v(0.5em)
#tablewide([表 12 本文针对原论文不足的改进对照])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto),
  [原论文的不足], [本文的改进], [改进效果],
  [仅在一个研究区（澳大利亚 Mutawintji）验证], [迁移至中国西北极干旱斑岩铜矿区（土屋-延东）], [验证了跨气候带和跨大地构造单元的适用性],
  [未分析深度增益的场景依赖性], [系统比较 Canonical AE 与 SAE 在同一数据集上的聚类效果], [发现浅层 AE 与深层 SAE 聚类分离性接近，提出"深度增益具有场景依赖性"],
  [未系统分析 bottleneck 维度影响], [消融实验测试 $z=3, 4, 5$ 三种维度], [揭示 $z=3$ 导致类别塌缩，确立 $z=5$ 为最优维度],
  [仅两项聚类指标（CHI、DBI）], [引入 Silhouette 系数作为第三项指标], [三维度评估增强结论稳健性],
  [地质解译以定性描述为主], [5 个波段比值定量分析 + 全自动制图], [以 B11/B12=0.992 识别出高置信度蚀变候选区],
)
]
#set text(size: 10pt)

== 地质解译

结合 §4.7 的光谱响应分析结果、假彩色合成图（图 2）的空间对应关系以及土屋-延东地区已有的地质研究资料#super[5]，对 SAE $z=5$, $k=6$ 的 6 个聚类类别进行综合地质解译，如表 13 所示。

#v(0.5em)
#tablewide([表 13 聚类类别综合地质解译（基于光谱响应 + 空间分布 + 区域地质知识）])[

#set text(size: 7pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto),
  [Cluster], [占比], [关键光谱证据], [空间分布特征], [地质解译], [置信度],
  [C1], [18.0%], [B11/B12=0.992（最低），B12 吸收显著], [北部带状-块状，与假彩色褐红色区吻合], [绢英岩化/青磐岩化蚀变带], [较高（SWIR 吸收证据明确）],
  [C0], [24.2%], [B11/B12=1.045（最高），SWIR 无吸收], [南部、中东部大面积块状], [未蚀变中酸性侵入岩（花岗闪长岩/石英闪长斑岩）], [中等],
  [C2], [37.2%], [各项比值居中，无极端特征], [全区广泛分布], [火山-沉积岩基质（安山岩/凝灰岩/碎屑岩）], [中等（面积最大、光谱最中庸）],
  [C4], [6.9%], [B04/B02=1.197（最低），全波段反射率低], [分散块状，部分沿水系/低洼区], [基性火山岩（安山岩）或地形阴影区], [较低],
  [C5], [11.1%], [B11/B12=1.057，B04/B02=1.412 较高], [研究区边缘、谷地、冲沟两侧], [第四系松散沉积物/洪积扇（含少量铁氧化物染色）], [较低],
  [C3], [2.6%], [B12/B8A=1.080（最低），B04/B02=1.447（最高）], [零星分布，空间不连续], [混合像元（蚀变带边缘过渡区/局部特殊岩性）], [低],
)
]
#set text(size: 10pt)

*解译依据与讨论：*

（1）*蚀变带（Cluster 1）的识别置信度较高*。多项独立证据支持该判读：① B11/B12=0.992 为 6 类中最低，在 Sentinel-2 波段设置中，绢云母（sericite）在 2200 nm 附近具有 Al--OH 吸收特征，恰好位于 B12（2190 nm）的覆盖范围#super[4]；② 该类的空间分布与地质假彩色图（图 2）中的褐红色调区域高度吻合，而褐红色调正是 B12/B8A/B02 假彩色合成中 SWIR 吸收的视觉表现；③ 土屋-延东斑岩铜矿的围岩蚀变以绢英岩化和青磐岩化为主，在斑岩体与围岩接触带呈带状或面状分布#super[5]，与该类北部带状-块状的空间格局一致。

（2）*未蚀变侵入岩（Cluster 0）*的 B11/B12 最高（1.045），表明 B12 无吸收，排除了显著的热液蚀变。该类空间上呈大面积块状分布，与中酸性岩体的产状一致。但其确切岩性归属（花岗闪长岩还是石英闪长斑岩）需要岩矿鉴定或已发表地质图的进一步约束。

（3）*火山-沉积岩基质（Cluster 2）*为面积最大的类别（37.2%），光谱特征中庸，空间上广泛分布，不排除其内部包含多种子类。这一"背景类"的存在符合区域地质中以石炭系火山-沉积岩系为主的特征。

（4）*低反射率类（Cluster 4）和沉积物类（Cluster 5）*的置信度较低，主要受限于缺乏地形校正（DEM）和沉积物光谱端元的先验知识。Cluster 4 的低反射率可能源于基性岩的矿物组成（暗色矿物含量高），也可能部分受地形阴影影响。Cluster 5 的空间分布与谷地、冲沟等负地形吻合，但波谱比值特征（B04/B02=1.412）暗示可能存在铁氧化物染色，这一特征与干旱区洪积扇沉积物一致。

（5）*混合像元类（Cluster 3）*占比仅 2.6%，空间不连续，判读为混合过渡类型，不单独赋予地质含义。

需要强调的是，上述地质解译是基于无监督聚类结果的光谱推断，最终的地质归属需要结合野外查证或已发表的大比例尺地质图进行标定和验证。

== 局限性与展望

本研究存在以下局限：（1）无监督聚类缺乏地面真值验证，聚类类别的地质含义需要后续标定；（2）自编码器作为全连接网络未利用像元的空间邻域上下文，从图 12 可以看出所有方法仍存在一定的空间噪点，未来可引入卷积自编码器（CAE）联合利用光谱-空间信息；（3）K-means 假设簇为球形分布，对于光谱空间中可能存在的细长或弧形分布的簇适应性较差，GMM 或谱聚类可能是更合适的选择；（4）仅使用了单一时相的夏季影像，不同季节的太阳高度角和地表含水量差异可能影响光谱特征；（5）仅测试了 $z ≤ 5$ 的 bottleneck 设置，更大维度的探索尚不充分。

未来工作可在以下方向展开：（1）引入 DEM 和地形因子（坡度、坡向、阴影校正）以消除地形效应；（2）使用 ASTER 热红外波段补充岩性敏感的发射率信息；（3）将聚类结果与已知地质图进行定量一致性评估（如调整兰德指数 ARI、归一化互信息 NMI）；（4）尝试对比更多降维方法（t-SNE、UMAP、变分自编码器 VAE）对聚类效果的影响；（5）在更大范围的东天山地区验证该框架的泛化能力。

= 结论

本文以新疆土屋-延东斑岩型铜矿区为研究对象，基于 Sentinel-2A L2A 影像的 10 个光谱波段（B02--B12），构建了从预处理到无监督岩性聚类的完整遥感地质分析流程，并系统比较了 Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means 四种方法的聚类效果。主要结论如下：

（1）非线性自编码器方法在聚类质量上一致优于线性和无降维基线（CHI ≥ 135,377 vs PCA 的 ≤127,301）。PCA 降维的增益有限（CHI 仅 +2.7%），因为其方差最大化目标与 K-means 的簇内平方和最小化目标不一致。

（2）浅层 Canonical AE 与深层 SAE 在聚类分离性指标上出人意料地接近——Canonical AE 的 CHI 略优（147,239 vs 144,423）。这一发现对"深层自编码器总是更好"的直觉提出了场景化补充：当数据以线性相关为主导时（PC1 解释 91.95% 方差），浅层非线性变换已能捕获主要的聚类判别结构。SAE 的优势体现在重建精度（MSE=0.00285 vs 0.00466）和簇紧凑性（DBI=0.6981 vs 0.7338）上，表明深度网络在需要高保真光谱重建的下游任务中仍有价值。

（3）Bottleneck 维度的消融实验揭示了其对聚类质量的关键影响：$z=3$ 导致严重类别塌缩（最大类占比 48.9%, CHI 骤降至 93,656），$z=5$ 为最优压缩维度。对于包含 4--6 种主要地表类型的研究区，5 维隐空间提供了足够的自由度。

（4）基于光谱响应曲线的定量分析为聚类结果赋予了物理可解释性。Cluster 1（18.0%）的 B11/B12=0.992 明确了 B12（2190 nm）处的 OH⁻ 吸收特征，结合其与假彩色图中褐红色蚀变信号的空间一致性，将该类高置信度解译为绢英岩化/青磐岩化蚀变带。

（5）本研究成功将 Naagar 等（2024）的 SAE+K-means 框架从澳大利亚 Mutawintji 迁移至中国西北极干旱斑岩铜矿区，验证了该框架的跨区域适用性，并构建了全自动 Python 遥感地质解释制图流程，确保全流程可复现。

综合以上发现，本文凝练出三条核心认识：第一，SAE+K-means 无监督聚类框架在极端干旱斑岩铜矿区依然有效，具备跨气候带和跨大地构造单元的迁移能力；第二，在该数据场景下——Sentinel-2 10 波段以线性共线性为主导、地表类别数有限（4--6 类）——浅层自编码器的聚类性能与深层 SAE 旗鼓相当，提示自编码器深度的增益具有场景依赖性，在选择模型复杂度时应考虑数据本身的非线性程度；第三，B11/B12 波段比值可作为该区域热液蚀变的快速遥感指示标志，为无标签裸露区的矿产勘查提供了光谱层面的定量判据。上述三条认识分别对应了原论文（Naagar et al., 2024）在跨区域验证、深度增益分析和定量光谱解译三个方面的不足，为后续无监督遥感岩性填图研究提供了可复现、可迁移的方法参考。

= 参考文献

#set par(first-line-indent: 0em, hanging-indent: 2em)
#set text(size: 9pt)

[1] van der Meer, F. D., van der Werff, H. M. A., van Ruitenbeek, F. J. A., et al. Multi- and hyperspectral geologic remote sensing: A review. _International Journal of Applied Earth Observation and Geoinformation_, 2012, 14(1): 112--128.

[2] Asmussen, P., Conrad, O., Guenther, A., et al. Semi-automatic mapping of geological structures using UAV-based photogrammetric data and semi-automated classification methods. _Remote Sensing_, 2020, 12(11): 1755.

[3] Drusch, M., Del Bello, U., Carlier, S., et al. Sentinel-2: ESA's optical high-resolution mission for GMES operational services. _Remote Sensing of Environment_, 2012, 120: 25--36.

[4] Ge, W., Cheng, Q., Jing, L., et al. Lithological classification using Sentinel-2 multispectral data and a PCA-based feature extraction approach. _Remote Sensing_, 2020, 12(4): 625.

[5] 韩春明, 肖文交, 赵国春, 等. 新疆东天山土屋-延东斑岩铜矿床成矿时代与构造背景. _岩石学报_, 2006, 22(1): 199--210.

[6] Cracknell, M. J., Reading, A. M. Geological mapping using remote sensing data: A comparison of five machine learning algorithms, their response to variations in the spatial distribution of training data and the use of explicit spatial information. _Computers & Geosciences_, 2014, 63: 22--33.

[7] Naagar, S., Chawla, S., Bhattacharya, A., et al. Remote sensing framework for geological mapping via stacked autoencoders and clustering. _Advances in Space Research_, 2024, 74(10): 4502--4516.

[8] Vincent, P., Larochelle, H., Lajoie, I., et al. Stacked denoising autoencoders: Learning useful representations in a deep network with a local denoising criterion. _Journal of Machine Learning Research_, 2010, 11: 3371--3408.

[9] Kingma, D. P., Ba, J. Adam: A method for stochastic optimization. _arXiv preprint_, arXiv:1412.6980, 2014.

[10] Pedregosa, F., Varoquaux, G., Gramfort, A., et al. Scikit-learn: Machine learning in Python. _Journal of Machine Learning Research_, 2011, 12: 2825--2830.

[11] Paszke, A., Gross, S., Massa, F., et al. PyTorch: An imperative style, high-performance deep learning library. _Advances in Neural Information Processing Systems_, 2019, 32: 8026--8037.

[12] Rousseeuw, P. J. Silhouettes: A graphical aid to the interpretation and validation of cluster analysis. _Journal of Computational and Applied Mathematics_, 1987, 20: 53--65.

[13] Davies, D. L., Bouldin, D. W. A cluster separation measure. _IEEE Transactions on Pattern Analysis and Machine Intelligence_, 1979, 1(2): 224--227.

[14] Caliński, T., Harabasz, J. A dendrite method for cluster analysis. _Communications in Statistics_, 1974, 3(1): 1--27.

#v(1em)
#set text(size: 10pt)
#set par(first-line-indent: 2em)

_附录：代码与复现说明_

本项目完整代码及数据处理流程见https://github.com/LeoZhangXYJ/GeoCluster_S2   
. preprocess_s2.py（数据预处理）、cluster_kmeans_baseline.py（Baseline K-means + Elbow）、pca_kmeans_baseline.py（PCA + K-means）、ae_kmeans_baseline.py（Canonical AE + K-means）、sae_kmeans.py（SAE + K-means）、analyze_cluster_spectra.py（聚类光谱响应分析）、compute_all_metrics.py（统一指标计算）、make_final_figures.py（对比图生成）、make_interpretation_map.py（Python 自动地质解释制图）。所有随机种子固定为 42，确保结果可复现。原论文开源代码见 https://github.com/sydney-machine-learning/autoencoders_remotesensing。
