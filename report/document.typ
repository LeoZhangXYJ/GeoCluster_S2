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
  title: "面向斑岩铜矿区岩性填图的 Sentinel-2 无监督聚类：
  自编码器基线比较与 Geo-DEC 空间增强",
  date: "",
  author: "张项翌杰",
  college: "地球科学学院",
  major: "浙江大学",
  semester: "2025-2026 春夏",
)

#set par(first-line-indent: 2em)

#abstract[
无监督聚类方法可在缺乏地面真值标签的偏远裸露区实现岩性填图，但现有深度学习聚类框架多在半干旱沉积岩区验证，其在极端干旱斑岩铜矿区的适用性及不同深度自编码器的相对增益尚不明晰。针对上述问题，本文以新疆哈密土屋-延东斑岩型铜矿区域为研究对象，基于 Sentinel-2A L2A 影像（2024-08-13，Tile T46TFM）的 10 个光谱波段（B02--B12）构建了 2,772,025 个有效像元的光谱数据集，并采用“两阶段”实验逻辑开展研究。第一阶段迁移 Naagar 等（2024）的 SAE+K-means 岩性填图框架，构建 Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means 的递进基线链条，用于回答非线性降维是否优于线性降维、深层自编码器是否必要以及 bottleneck 维度如何影响聚类质量。结果表明：线性 PCA 对聚类质量的提升有限（CHI 仅从 123,898 提升至 127,301，+2.7%），深层 SAE 与浅层 Canonical AE 的聚类分离性出乎意料地接近——Canonical AE 的 CHI 甚至略优（147,239 vs 144,423），表明 Sentinel-2 10 波段数据的非线性结构有限，浅层非线性变换已能捕获主要的聚类判别信息；SAE 的优势体现在重建精度（MSE=0.00285 vs 0.00466）和簇紧凑性（DBI=0.6981 vs 0.7338）上。消融实验进一步揭示了 bottleneck 维度对聚类质量的关键影响：$z=3$ 导致严重类别塌缩（最大类占比 48.9%），$z=5$ 是本文主实验采用的折中维度。第二阶段针对 AE+K-means 像元独立处理带来的空间破碎问题，提出 Geo-DEC 空间增强扩展。该方法未在 CHI 和 DBI 等传统聚类分离指标上超过 AE/SAE，但取得最高 local agreement（0.9348）和最低 isolated pixel ratio（0.0057），说明其主要优势在于改善空间连续性和降低椒盐噪声。在聚类结果基础上，本文通过光谱响应曲线与波段比值开展定量分析，发现 C1 具有 B11/B12=0.992、B12/B8A=1.282 等光谱异常组合；但 $"B11/B12" < 1$ 表明 B11 低于 B12，不能作为 B12 吸收证据，因此该类仅作为需地质图或野外验证的候选线索。本文构建了全自动 Python 遥感地质解释制图流程，验证了 SAE+K-means 框架在极干旱斑岩铜矿区的跨区域适用性，并将其扩展为面向空间连续性增强的 Geo-DEC 制图流程，为无标签裸露区的无监督遥感岩性填图提供了可复现、可迁移的方法参考。

]

#keywords[Sentinel-2；堆叠自编码器；浅层自编码器；Geo-DEC；PCA；K-means 聚类；岩性识别；无监督学习；空间连续性；土屋-延东]

#abstract(name: strong[Abstract])[
Unsupervised clustering methods enable lithological mapping in remote, sparsely vegetated areas where field labels are scarce. However, existing deep-learning-based clustering frameworks have been validated primarily in semi-arid sedimentary terrains, and their applicability to hyper-arid porphyry copper districts—as well as the relative benefit of deep versus shallow autoencoders—remains unclear. This study uses a two-stage design for the Tuwu-Yandong porphyry copper district in Hami, Xinjiang, China. Using a Sentinel-2A L2A image (2024-08-13, Tile T46TFM) with 10 spectral bands (B02--B12) resampled to 20 m, we construct a dataset of 2,772,025 valid pixels after cloud, shadow, and water masking. First, we migrate the SAE+K-means framework of Naagar et al. (2024) and compare a baseline chain of Raw K-means, PCA + K-means, Canonical AE + K-means, and SAE + K-means to test whether nonlinear dimensionality reduction, network depth, and bottleneck dimension matter. Results show that PCA yields only marginal improvement over Raw K-means (CHI +2.7%), and the shallow Canonical AE matches or slightly exceeds the deep SAE in cluster separability (CHI 147,239 vs. 144,423), suggesting that shallow nonlinear transformations suffice for the main clustering structure of Sentinel-2 10-band data. SAE retains advantages in reconstruction fidelity (MSE 0.00285 vs. 0.00466) and cluster compactness (DBI 0.6981 vs. 0.7338). The ablation experiment reveals that z=3 causes severe class collapse (largest class 48.9%), while z=5 is used as the main compromise configuration. Second, we introduce Geo-DEC as a spatial-context enhancement beyond the pixel-independent AE+K-means pipeline. Geo-DEC achieves the highest local agreement (0.9348) and the lowest isolated pixel ratio (0.0057), although its CHI and DBI do not outperform AE/SAE, indicating that its main benefit is improved spatial continuity rather than stronger global cluster separation. Quantitative spectral analysis finds an anomalous ratio combination in C1 (B11/B12=0.992, B12/B8A=1.282); however, $"B11/B12" < 1$ means B11 is lower than B12 and does not prove B12 absorption, so this class is retained only as a candidate clue requiring geological-map or field validation. A fully scripted Python mapping pipeline replaces traditional GIS workflows for reproducible geological interpretation. This study validates the cross-regional applicability of the SAE+K-means framework in a hyper-arid porphyry copper setting and extends it with Geo-DEC for spatially coherent unsupervised lithological mapping.
]

#keywords(name: "Keywords")[Sentinel-2; lithological mapping; stacked autoencoder; canonical autoencoder; Geo-DEC; PCA; K-means clustering; spatial continuity; porphyry copper deposit; Tuwu-Yandong]

= 引言

遥感技术因其大范围、多时相、低成本的优势，已经成为区域地质调查和矿产勘查中不可或缺的技术手段#super[1]。传统的遥感地质解译多依赖专家目视判读或监督分类方法，但在地面真值标签稀缺的偏远裸露区，无监督聚类方法具有独特优势——无需先验标签即可自动发现光谱特征的群聚结构，为地质填图提供客观的初始分类参考#super[2]。

Sentinel-2 卫星是欧洲空间局（ESA）哥白尼计划的核心任务之一，搭载多光谱成像仪（MSI），覆盖可见光至短波红外（443--2190 nm）共 13 个光谱波段，空间分辨率最高为 10 m#super[3]。其中，SWIR 波段（B11: 1610 nm, B12: 2190 nm）对含羟基（OH#super[−]）和碳酸根（CO₃#super[2−]）的热液蚀变矿物（如绢云母、绿泥石、方解石等）具有特征吸收特征，非常适用于斑岩型铜矿的蚀变分带研究#super[4]。

新疆哈密土屋-延东地区是中国西北重要的斑岩型铜矿成矿带，区内出露大量古生代火山-沉积岩系和中酸性侵入岩体，地表植被稀疏、基岩裸露度高，为多光谱遥感岩性识别提供了理想条件#super[5]。然而，传统的 K-means 聚类直接作用于 10 维光谱特征时，由于高维空间中光谱向量的噪声和冗余，聚类结果往往呈现明显的"椒盐噪声"——空间上破碎、孤立像元多，不利于地质单元的连续划分#super[6]。

在降维方法的选择上，主成分分析（PCA）是最经典的光谱降维手段，已在遥感地质中得到广泛应用#super[4]。然而 PCA 仅能捕获线性方差结构，难以建模光谱波段之间的非线性交互关系。自编码器（Autoencoder）作为一种经典的无监督深度学习模型，能够通过 encoder-decoder 结构学习数据的紧凑低维表示。Naagar 等（2024）在 _Advances in Space Research_ 上发表的研究系统比较了 PCA、canonical autoencoder 和 stacked autoencoder 三种降维方法结合 K-means 聚类在岩性填图中的效果，并在 Landsat 8、ASTER 和 Sentinel-2 三种数据源上进行了验证#super[7]。该研究指出，堆叠自编码器（SAE）通过多层非线性变换，可以捕获光谱波段之间的高阶交互关系，将高维光谱映射到低维隐空间，同时滤除噪声、保留主要光谱结构，其效果优于传统线性降维和浅层自编码器。

然而，该研究存在五个可供深化的方面。第一，原论文仅在澳大利亚 Mutawintji 一个研究区进行了验证，框架在不同气候带和大地构造单元下的跨区域可迁移性尚未得到检验。第二，原论文得出"SAE 全面优于 Canonical AE"的结论，但未进一步追问：深度增益是否具有场景依赖性？当数据本身的非线性结构有限时，深层网络是否仍然必要？第三，原论文未系统分析 bottleneck 维度对聚类质量的影响——使用了固定的隐空间维度，缺乏消融实验来揭示过窄 bottleneck 引发的类别塌缩风险。第四，原论文的聚类定量评估主要关注 CHI 和 DBI 等分离性指标，地质解译以定性描述为主，缺乏基于波段比值的定量光谱证据。第五，原论文将像元主要作为独立光谱向量处理，空间信息更多依赖最终图件的目视判断或后处理，缺少将空间上下文纳入表示学习与聚类目标的实验检验。

针对以上不足，本文采用“两阶段”实验逻辑展开研究。第一阶段迁移并评估 Naagar 等（2024）的 PCA / Canonical AE / SAE + K-means 框架，围绕三项主线问题展开：（1）非线性自编码器表示是否优于线性 PCA 降维？（2）深层 SAE 相对于浅层 Canonical AE 的增益有多大？（3）bottleneck 维度如何影响聚类质量与类别塌缩？第二阶段在 AE + K-means 像元独立处理和空间连续性不足的基础上，引入 Geo-DEC 作为空间上下文增强扩展，专门检验地质指数、3×3 邻域统计和 DEC 联合优化是否能改善制图连续性。换言之，Geo-DEC 并非与前四种方法进行同级“最优模型竞赛”，而是在基线链条之后用于回答空间增强是否有效的补充实验。主要贡献与原论文不足的对应关系如下：

（1）*基线迁移与比较*（针对不足一）：将 SAE+K-means 框架从澳大利亚半干旱沉积变质岩区迁移至中国西北极干旱斑岩铜矿区（新疆土屋-延东），并建立 Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means 的递进基线链条；

（2）*深度增益的场景依赖性分析*（针对不足二）：首次在 Sentinel-2 10 波段数据上系统比较了浅层 Canonical AE 与深层 SAE 的聚类效果，发现两者在聚类分离性上出人意料地接近（CHI 147,239 vs 144,423），提出"深度增益具有场景依赖性"——当数据以线性相关为主导（PC1 解释 91.95% 方差）且地表类型有限（4--6 类）时，浅层非线性变换已能捕获主要判别结构；

（3）*Bottleneck 维度消融实验*（针对不足三）：系统测试了 $z=3, 4, 5$ 三种设置，发现 $z=3$ 导致严重类别塌缩（最大类占比 48.9%, CHI 骤降至 93,656），$z=5$ 在类别均衡性、CHI 和重建误差之间取得较好折中，因此作为本文主实验隐空间维度；

（4）*多指标评估与定量光谱解译*（针对不足四）：引入 Silhouette 系数作为第三项聚类指标，并通过 5 个具有地质意义的波段比值（B11/B12、B12/B8A 等）对各聚类类别进行定量光谱分析，同时修正 B11/B12 的物理判读方向，将仅由比值和空间对应关系支持的蚀变解释降级为待验证候选线索；

（5）*Geo-DEC 空间增强*：在原始 AE + K-means 两阶段框架之后，进一步提出 Geo-DEC（Geological-index and spatial-context enhanced deep embedded clustering），将蚀变相关波段比值、3×3 空间上下文和 DEC 聚类损失纳入同一深度表示学习流程，用于检验空间上下文是否能改善地质图斑连续性；

（6）*全流程可复现性*：构建了从 Sentinel-2 SAFE 解压到最终地质解释图的完整 Python 预处理与制图流程，确保实验全流程可复现。

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
短波红外波段赋予红色通道，突出 SWIR 亮度及岩性/蚀变相关对比。])

从图 1 可以看出，研究区地表呈灰黄-灰褐色调，植被覆盖极少，基岩裸露度高。图 2 假彩色合成中，褐红色区域主要表示 B12 通道相对较强或 SWIR 亮度/对比度较高的位置，不能直接等同于 SWIR 吸收；这些区域仅可作为岩性或蚀变相关异常的初步视觉线索。

= 方法

本文的方法框架如图 3 所示，总体包含四个阶段：（1）数据预处理与光谱标准化；（2）基线链条构建，即 Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means 的递进比较；（3）Geo-DEC 空间增强扩展，即在 AE 表示学习思想上加入地质指数、邻域统计和 DEC 联合聚类目标；（4）多指标评价与地质解释，包括传统聚类分离指标、空间连续性指标、光谱响应分析和自动化制图。

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

== 实验路线：基线链条与空间增强扩展

为避免将不同目标的方法混为同一层级，本文将实验路线划分为”基线链条”和”空间增强扩展”两部分。Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means 构成递进基线链条：Raw K-means 提供无降维参照，PCA 检验线性降维是否足够，Canonical AE 检验浅层非线性表示的必要性，SAE 检验增加网络深度是否带来额外收益。Geo-DEC 则位于该基线链条之后，使用地质波段比值、3×3 空间上下文和 DEC 聚类损失，专门检验在光谱表示学习之外引入空间上下文是否能改善地质制图连续性。

关于聚类数 $k$ 的选择：Raw K-means 的 Elbow 分析在标准化 10 维原始光谱特征上自动确定 $k=5$ 为最优聚类数。然而，后续方法在降维后的低维隐空间中进行聚类，其最优 $k$ 可能与原始空间不完全一致；同时，研究区已知至少存在 4--6 种主要地表覆盖/岩性类型（中酸性侵入岩、安山岩、凝灰岩、第四系沉积物、蚀变带等），$k=6$ 具有地质合理性。因此，PCA $z=5$、SAE $z=4$/$z=5$、Canonical AE $z=5$ 和 Geo-DEC 统一采用 $k=6$ 作为主实验配置，SAE $z=3$ 因过窄瓶颈导致的类别塌缩问题仅测试 5 类以验证极端情况。两种 $k$ 的实验结果可分别反映聚类算法的粗分（$k=5$）与细分（$k=6$）能力。表 2 列出了四种基线方法与 Geo-DEC 扩展的角色差异。

#v(0.5em)
#tablecaption[表 2 基线链条与 Geo-DEC 空间增强方法的特征]

#table3(
  columns: (auto, auto, auto, auto, auto),
  [方法], [降维类型], [网络/变换结构], [特征维度], [参数数量],
  [Raw K-means], [无降维], [——], [10], [——],
  [PCA + K-means], [线性], [协方差特征分解], [$z=3$, $5$], [——],
  [Canonical AE + K-means], [非线性（浅层）], [$10→16→z→16→10$], [$z=5$], [527],
  [SAE + K-means], [非线性（深层）], [$10→32→16→z→16→32→10$], [$z=3$, $4$, $5$], [1,935],
  [Geo-DEC], [地质先验 + 空间上下文 + 联合聚类], [$28→64→32→z→32→64→28$ + DEC], [$z=5$], [8,231],
)

这一设计直接对应了本文的两阶段逻辑：前四种方法用于判断光谱表示学习本身是否有效以及深度是否必要，Geo-DEC 则用于判断在已有 AE + K-means 主线之外加入地质先验和空间上下文后，是否能进一步提高制图连续性和可解释性。

=== Raw K-means（基线）

直接将标准化后的 10 维光谱特征输入 K-means 聚类。使用 Elbow 方法在训练集 200,000 样本上计算 $k=2"–"12$ 的 inertia 曲线，采用"点到直线最大距离法"自动选取拐点。

=== PCA + K-means

主成分分析（PCA）通过对协方差矩阵进行特征分解，将原始 10 维光谱数据投影到方差最大的正交方向上。本文实验 PCA 降维至 $z=3$ 和 $z=5$，降维后在 PCA 特征空间执行 K-means 聚类（$z=3$ 时 $k=5$，$z=5$ 时 $k=6$）。PCA 基线用于检验：是否简单的线性方差保留即可达到与非线性降维相当的聚类效果？

=== Canonical AE + K-means（浅层自编码器）

Canonical AE 采用单隐藏层结构 10 → 16 → z → 16 → 10（527 个参数），与 SAE 的双隐藏层 10 → 32 → 16 → z → 16 → 32 → 10（1,935 个参数）形成深度对比。训练目标与 SAE 一致，为最小化均方误差重建损失：

$
cal(L)_"MSE" = 1/N sum_(i=1)^N |x_i - hat(x)_i|^2
$

其中 $hat(x)_i = "Decoder"("Encoder"(x_i))$ 为重建向量。两个模型均使用 ReLU 激活函数和相同的训练配置（Adam 优化器, lr=1e-3, batch_size=4096, 训练 30 epochs, 训练样本 300,000）#super[9]。通过比较 Canonical AE 与 SAE 的聚类效果，可以分离"非线性变换"与"深层层级表示"的各自贡献。

=== Stacked AE + K-means（堆叠自编码器）

SAE 的 encoder 结构为 10 → 32 → 16 → z，decoder 为对称结构 z → 16 → 32 → 10。该结构参考堆叠自编码器逐层压缩并学习低维表示的思想#super[8]，训练目标为最小化均方误差（MSE）重建损失：

$
cal(L)_"MSE" = 1/N sum_(i=1)^N |x_i - hat(x)_i|^2
$

其中 $x_i$ 为标准化后的 10 维光谱向量，$hat(x)_i = "Decoder"("Encoder"(x_i))$ 为重建向量。训练完成后，将所有 $N=2,772,025$ 个有效像元通过 encoder 编码为 $z$ 维特征向量，在隐空间执行 K-means 聚类。为研究 bottleneck 维度的影响，本文比较 $z=3, 4, 5$ 三种设置。

=== Geo-DEC：在 AE+K-means 主线后的空间上下文增强

Geo-DEC（Geological-index and spatial-context enhanced deep embedded clustering）是在 AE + K-means 主线之后提出的空间上下文增强实验。它并不改变前四种方法用于回答“光谱表示学习是否有效”的基线任务，而是针对基线方法共同存在的像元独立处理问题：每个像元通常只由自身光谱决定类别，邻域连续性只在结果图上被被动观察。为此，Geo-DEC 在输入端引入两类先验增强特征：第一类是与斑岩铜矿蚀变和地表物质差异相关的波段比值，包括 B11/B12、B12/B8A、B11/B8A、B04/B02、B08/B04 和 NDVI；第二类是空间上下文特征，对 B11、B12 以及关键比值图计算 3×3 邻域均值和标准差，并在计算时显式排除无效像元。模型输入因此从原始 10 维光谱扩展为 28 维“光谱--地质指数--空间上下文”特征。

模型结构采用 $28→64→32→z→32→64→28$ 的自编码器，主实验固定 $z=5$、$k=6$，与 SAE 和 Canonical AE 的主实验保持可比。训练分两阶段进行：首先使用重建均方误差预训练 30 epochs，得到稳定的低维表示；随后用 K-means 初始化隐空间聚类中心，并引入 DEC 的软分配目标进行 20 epochs 微调。总损失函数为：

$
cal(L) = cal(L)_"recon" + 0.1 cal(L)_"DEC"
$

其中 $cal(L)_"recon"$ 为输入增强特征的重建均方误差。$cal(L)_"DEC"$ 的具体形式为：设隐空间中样本 $i$ 到聚类中心 $mu_j$ 的软分配（Student-t 分布）为

$
q_(i j) = ((1 + |z_i - mu_j|^2 / alpha)^(-(alpha+1)/2)) / (sum_(j')(1 + |z_i - mu_(j')|^2 / alpha)^(-(alpha+1)/2))
$

其中 $alpha=1$ 为自由度参数。目标分布 $P$ 通过增强高置信度分配样本的权重得到：

$
p_(i j) = (q_(i j)^2 / f_j) / (sum_(j') q_(i j')^2 / f_(j'))
$

其中 $f_j = sum_i q_(i j)$ 为软簇频率。$cal(L)_"DEC"$ 定义为目标分布 $P$ 与软分配 $Q$ 之间的 KL 散度：$cal(L)_"DEC" = sum_i sum_j p_(i j) thin space log(p_(i j) / q_(i j))$。该设计使隐空间不仅服务于光谱重建，也直接服务于簇间分离，从而弥补传统 AE + K-means 中"先重建、后聚类"的目标错位问题。由于 Geo-DEC 的主要动机是改善像元独立处理带来的空间破碎问题，其评价重点包括 local_agreement_ratio 和 isolated_pixel_ratio；Silhouette、DBI 和 CHI 仍作为传统聚类分离性的参照指标，而非唯一判据。

== 聚类评价指标

为定量评估聚类质量，本文引入三项常用的无监督聚类评价指标：

*Silhouette 系数（轮廓系数）*衡量每个样本与自身簇的相似度相对于与最近邻簇的相似度，取值范围为 $[-1, 1]$，值越大表示簇内紧凑且簇间分离良好#super[12]。

*Davies-Bouldin 指数（DBI）*衡量各簇之间的平均相似度，值越小表示簇间分离性越好#super[13]。

*Calinski-Harabasz 指数（CHI）*定义为簇间离散度与簇内离散度的比值，值越大表示簇间方差大、簇内方差小，聚类结构更优#super[14]。

由于全量 2,772,025 个像元上计算 Silhouette 系数的计算复杂度为 $O(N^2)$，本文在随机抽样的 100,000 个有效像元上计算三项指标，确保可复现性（随机种子固定为 42）。

此外，为评价聚类图的空间连续性，本文新增两项空间质量指标。local_agreement_ratio 表示每个有效像元的标签是否与其 3×3 邻域多数标签一致，值越高说明图斑更连续；isolated_pixel_ratio 表示 3×3 邻域内没有同类邻居的孤立像元比例，值越低说明椒盐噪声越少。该指标特别用于检验 Geo-DEC 引入空间上下文后是否改善地质图斑的连续性。

== 与原论文框架的实现对齐和扩展

本文的方法框架参考了 Naagar 等（2024）的开源实现（https://github.com/sydney-machine-learning/autoencoders_remotesensing）。原论文框架包含 PCA、canonical autoencoders、stacked autoencoders 与 K-means 的组合，用于生成 clustered maps 并解译为 lithological maps。本文首先在土屋-延东研究区复现和迁移这一主线框架，随后在其像元独立处理的基础上增加 Geo-DEC 空间增强实验。表 3 给出了本文实现与原论文框架的对应关系，其中 PCA / Canonical AE / SAE 对应原论文主线，Geo-DEC 属于本文扩展。

#v(0.5em)
#tablecaption[表 3 本文实现与原论文框架的对应关系]

#table3(
  columns: (auto, auto, auto),
  [环节], [原论文/开源代码], [本文实现],
  [数据源], [Sentinel-2（及 Landsat 8、ASTER）], [Sentinel-2A L2A T46TFM],
  [预处理], [数据集特定预处理（需用户自行实现）], [自定义 SAFE 解压、波段提取、SCL 掩膜、AOI 裁剪],
  [表示学习方法], [PCA / Canonical AE / Stacked AE], [PCA / Canonical AE / Stacked AE + Geo-DEC 扩展],
  [聚类方法], [K-means], [K-means ($k=5$, $6$) + DEC soft assignment],
  [输出], [Clustered maps], [GeoTIFF + PNG 聚类图],
  [验证], [聚类指标 + 地质知识/样点], [Silhouette / DBI / CHI + 空间质量指标 + 假彩色对照],
)

原论文的 GitHub 仓库提供了 Autoencoder_Landsat8.ipynb、Autoencoder_ASTER.ipynb 和 Autoencoder_Sentinel2.ipynb，但说明具体的 dataloader、预处理和后处理需要用户根据数据集自行实现。本文在此基础上完成了针对 Sentinel-2 L2A 产品的完整预处理管线（SCL 掩膜、AOI 裁剪、波段重采样与堆叠），并在研究区迁移（澳大利亚 Mutawintji → 中国新疆土屋-延东）的背景下进行了全流程复现、基线比较和空间增强扩展。

= 实验与结果

本节按照两阶段逻辑组织实验结果。§4.2--§4.4 首先报告 Raw K-means、PCA + K-means、SAE 和 Canonical AE 的基线结果，用于回答光谱表示学习、网络深度和 bottleneck 维度的问题；§4.5--§4.6 在同一指标表和结果图中引入 Geo-DEC，但其解释重点转向空间连续性和图斑可读性；§4.7--§4.8 则基于主线聚类结果开展光谱响应分析和地质解释制图。

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
  [30], [0.0040], [0.0045], [*0.00285*],
)

注：$z=3$ 因瓶颈维度极窄导致训练后期 plateau 过早出现，故采用 60 epochs 延长训练以确保收敛充分（表中仅列出前 30 epochs 以与 $z=4$, $z=5$ 对齐比较）；其与 $z=4$ 和 $z=5$（均为 30 epochs）的损失值在绝对意义上不完全可比。

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
  [30], [*0.00466*], [*0.00285*],
)

从重建误差看，SAE 在早期训练阶段即取得更低损失（epoch 5: 0.0180 vs Canonical AE 的 0.0694），并在最终收敛时保持优势（MSE=0.00285 vs 0.00466）。Canonical AE 作为参数量较小的浅层非线性强基线，仍能学习有效的聚类判别表示；SAE 则凭借更深的层级结构和更高的参数量（1,935 vs 527）进一步提高了光谱重建保真度。

#figurex(image("../results/cluster_ae/ae_training_loss_z5.png", width: 55%), [Canonical AE $z=5$ 训练损失曲线（30 epochs）。\
最终重建误差 0.00466，高于 SAE 的 0.00285。])

//#pagebreak(weak: true)

== 基线方法与 Geo-DEC 的双维度评价

表 9 汇总了全部实验配置的传统聚类分离指标、类别分布和空间质量指标。解读该表时需要区分两类目标：Raw/PCA/Canonical AE/SAE 主要比较光谱表示学习对聚类分离性的影响；Geo-DEC 则作为空间增强扩展，重点观察 local agreement 和 isolated pixel ratio 是否改善。

#v(0.5em)
#tablewide([表 9 全部实验配置的聚类指标对比])[

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
#set text(size: 10pt)

#v(-0.3em)
#set text(size: 8pt)
*注：*（1）SAE $z=3$ 使用 $k=5$，其余 AE/SAE 及 Geo-DEC 配置均使用 $k=6$，$k$ 不同会影响聚类指标的绝对值，因此 SAE $z=3$ 行与其他行在指标上不完全可比。（2）Silhouette、DBI 和 CHI 均在各自方法所使用的特征空间计算（Raw K-means 在 10 维标准化光谱空间，PCA 在 PCA 降维空间，AE/SAE/Geo-DEC 在隐空间），这符合自编码器聚类文献的标准做法，但意味着各项指标反映的是各表征空间内部的簇分离质量，而非统一绝对基准。（3）空间指标（Agreement、Isolated）在类别塌缩发生时可能虚假偏高——类别数越少、类块越大，邻域一致性越高、孤立像元越少。因此解读空间指标时应结合类别分布（Max%、Min%）综合判断。
#set text(size: 10pt)

从表 9 可以得出两组主要发现。首先，基线链条揭示了光谱表示学习本身的作用：

（1）*线性降维增益有限*。PCA $z=3$ 仅将 CHI 从 123,898 提升至 127,301（+2.7%），Silhouette 的改善也不显著（0.3709 → 0.3796）。这表明虽然 PCA 前 3 维保留了 99.53% 的总方差，但这些方差主要由整体亮度主导，与聚类边界的优化目标（最大化簇间分离性）并不一致。

（2）*非线性自编码器一致优于线性和无降维基线*。Canonical AE 和 SAE 的所有配置（除 $z=3$ 类别塌缩外）的 CHI 均 ≥135,377，显著高于 Raw K-means（123,898）和 PCA（127,301），验证了非线性特征学习对聚类质量的改善作用。

（3）*浅层 Canonical AE 与深层 SAE 聚类质量接近*。两者在 Silhouette（0.4166 vs 0.4165）上几乎相同，CHI 方面 Canonical AE 甚至略优（147,239 vs 144,423）。但 SAE 在 DBI（0.6981 vs 0.7338）和重建精度（MSE 0.00285 vs 0.00466）上具有明显优势，表明更深层的结构有助于学习更紧凑的光谱表示。

（4）*SAE $z=3$ 出现严重的类别塌缩*。CHI 骤降至 93,656（所有方法中最低），最大类占比达到 48.9%，证实过窄的 bottleneck 导致不同光谱类型被强制映射至相近的隐空间位置。

其次，Geo-DEC 扩展实验揭示了空间上下文增强的作用：

（5）*Geo-DEC 主要改善空间连续性而非全局簇分离度*。Geo-DEC 的 Silhouette=0.4157，与 SAE $z=5$ 和 Canonical AE 主配置接近，但 DBI=0.8877、CHI=68,821，未超过 AE/SAE 系列方法，说明地质指数、3×3 空间上下文和 DEC 联合优化并未进一步增强传统意义上的隐空间簇分离。相反，Geo-DEC 取得最高 local agreement（0.9348）和最低 isolated pixel ratio（0.0057），并且最大类占比为 35.0%、最小类占比为 9.5%，类别分布比 SAE $z=5$ 和 Canonical AE 更均衡，未出现小类塌缩。这表明其主要价值在于增强地质图斑连续性、降低椒盐噪声和改善制图可读性。

== 聚类结果可视化

=== SAE 消融实验对比

#figurex(image("../results/cluster_sae/sae_kmeans_k5_z3.png", width: 88%), [消融实验：SAE $z=3$, $k=5$ 聚类结果。\
绿色类大面积扩张（占比 48.9%），类别塌缩明显。])

$z=3$ 的聚类结果暴露出严重的类别塌缩问题。如图 9 所示，绿色类别（Cluster 2）几乎占据了研究区近半面积（48.9%），而本应具有光谱差异的地质单元被强制合并。空间上，原本在 $z=5$ 中可分辨的块状结构在此处被吞并为大面积均质斑块。这一现象验证了过窄 bottleneck 的破坏性：3 维隐空间不足以编码 4--6 种地表类型的光谱差异，不同类别在隐空间中高度重叠，K-means 无法有效划分决策边界。

#figurex(image("../results/cluster_sae/sae_kmeans_k6_z4.png", width: 88%), [消融实验：SAE $z=4$, $k=6$ 聚类结果。\
最大类占 42.0%，较 $z=3$ 改善但仍偏高，出现两个 ~4.7% 小类。])

$z=4$ 的聚类质量介于 $z=3$ 与 $z=5$ 之间。最大类占比从 48.9% 降至 42.0%，类别均衡性有所改善，但提升幅度有限——CHI 仅恢复至 135,377，仍明显低于 $z=5$ 的 144,423。图 10 中绿色类别的空间范围明显收缩，西北部和东南部出现了新的类别斑块，但整体空间连续性与 $z=3$ 相比改善不显著。同时，$z=4$ 产生了两个仅占 ~4.7% 的极小类，这些过小类别可能对应光谱异常点或混合像元，而非真实的地质单元。该配置表明：4 维隐空间已开始容纳更多类别信息，但仍不足以充分解耦研究区内主要地物的光谱差异。

#figurex(image("../results/cluster_sae/sae_kmeans_k6_z5.png", width: 88%), [消融实验：SAE $z=5$, $k=6$ 聚类结果。\
最大类占 37.2%，类别均衡性较好，空间连续性良好。])

#pagebreak(weak: true)

=== 从光谱聚类到空间增强的结果对比

#figurewide(image("../results/final_figures/method_comparison_5methods.png", width: 88%), [基线方法与 Geo-DEC 空间增强结果对比。\
(a) Raw K-means $k=5$；(b) PCA + K-means $z=5$, $k=6$；\
(c) Canonical AE + K-means $z=5$, $k=6$；(d) SAE + K-means $z=5$, $k=6$；(e) Geo-DEC $z=5$, $k=6$。])

对比图 12(a)--(e) 可以看出，前四种方法主要反映光谱特征表示能力的差异，而 Geo-DEC 则反映在已有光谱聚类基础上引入空间上下文后的制图效果变化：

- *Raw K-means*（图 12a）椒盐噪声最重，空间上破碎、孤立像元多，不利于地质单元的连续划分。
- *PCA + K-means*（图 12b）与 Raw K-means 视觉效果接近，线性降维未能显著改善空间连续性，与定量指标一致。
- *Canonical AE + K-means*（图 12c）空间连续性明显优于 PCA，大尺度块状结构清晰，但细节纹理略逊于 SAE。其类别分布最均衡（Max=36.0%），CHI 最优（147,239）。
- *SAE + K-means*（图 12d）在保持良好空间连续性的同时，保留了更多细粒度光谱差异。虽然 CHI 和 Silhouette 与 Canonical AE 接近，但重建精度（MSE=0.00285）和簇紧凑性（DBI=0.6981）更优。
- *Geo-DEC*（图 12e）不是对 AE/SAE 主线的简单替代，而是在其“低维表示学习 + 聚类”思想上加入地质指数、空间上下文和聚类目标联合优化。其传统聚类分离指标并未超过 AE/SAE（Silhouette=0.4157，DBI=0.8877，CHI=68,821），但 local agreement 提升至 0.9348，isolated pixel ratio 降至 0.0057，说明该方法主要改善了地质图斑连续性并降低了椒盐噪声，而非提高全局簇分离度。

#figurewide(image("../results/final_figures/method_comparison_2x3_geo_dec.png", width: 88%), [基线链条、Geo-DEC 与地质假彩色图的综合对比（2×3）。\
(a) Raw K-means $k=5$；(b) PCA + K-means $z=5$, $k=6$；\
(c) Canonical AE + K-means $z=5$, $k=6$；(d) SAE + K-means $z=5$, $k=6$；\
(e) Geo-DEC $z=5$, $k=6$；(f) 地质假彩色合成 B12/B8A/B02。])

//#pagebreak(weak: true)

== 聚类类别的光谱响应分析

为进一步揭示各聚类类别的地质含义，本文对 SAE $z=5$, $k=6$ 的 6 个聚类类别进行了光谱响应特征分析。光谱分析使用 Sentinel-2 L2A 地表反射率原始值（未标准化），以确保波段比值的物理可解释性。对每个类别的像元，计算 10 个波段的均值与标准差，并提取 5 个具有地质指示意义的波段比值（B11/B12、B12/B8A、B11/B8A、B04/B02、B08/B04），结果如图 14 和表 10 所示。

#figurewide(image("../results/cluster_spectra/cluster_spectral_profiles.png", width: 80%), [各聚类类别在 10 个波段上的平均光谱反射率曲线（SAE $z=5$, $k=6$）。\
阴影带表示 ±1 标准差。灰色区域标注了 SWIR 波段（B11: 1610 nm, B12: 2190 nm），该区域对含 OH⁻/CO₃²⁻ 的蚀变矿物具有特征吸收。\
Cluster 1 在 B11--B12 区间并未呈现 B12 相对 B11 的降低；其较低 B11/B12 与较高 B12/B8A 构成光谱异常组合，但不能直接解释为 B12 吸收。])

#v(0.5em)
#tablewide([表 10 各聚类类别的关键波段比值（均值）])[

#set text(size: 8pt)
#table3(
  size: 8pt,
  columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  [Cluster], [占比], [B11/B12], [B12/B8A], [B11/B8A], [B04/B02], [B08/B04], [光谱特征判读],
  [0], [24.2%], [1.045], [1.170], [1.222], [1.375], [1.045], [B11/B12 较高，整体反射率中等；B12 相对降低的意义需谨慎解释],
  [1], [18.0%], [*0.992*], [1.282], [1.265], [1.254], [1.021], [B11/B12 最低，B12/B8A 最高；不能作为 B12 吸收证据],
  [2], [37.2%], [1.022], [1.231], [1.255], [1.330], [1.041], [各项比值居中，无极端特征，面积最大的背景类],
  [3], [2.6%], [*1.061*], [*1.080*], [1.144], [*1.447*], [1.039], [B11/B12 最高、B12/B8A 最低；极小类，低置信光谱异常],
  [4], [6.9%], [1.008], [1.175], [1.178], [1.197], [1.009], [B11/B12 接近 1.0，B04/B02 最低；整体反射率偏低],
  [5], [11.1%], [1.057], [1.131], [1.194], [1.412], [1.046], [B11/B12 次高；中等反射率，可见光波段斜率较大],
)
]
#set text(size: 10pt)

从表 10 和图 14 可以得出以下光谱判读：

*（1）Cluster 1 —— B11/B12 低值光谱异常类（18.0%）*。该类的 B11/B12 比值（0.992）为 6 类中最低，同时 B12/B8A=1.282 为最高。需要特别说明的是，按比值定义，$"B11/B12" < 1.0$ 表明 B11 反射率低于 B12，方向上并不支持 B12（2190 nm）处的直接吸收证据。该类与假彩色图中部分褐红色区域具有空间对应关系，可能仍反映岩性或蚀变相关的光谱差异，但仅能作为待地质图或野外查证的候选线索。

*（2）Cluster 0 —— 中等反射率侵入岩候选类（24.2%）*。B11/B12=1.045，属于较高比值，说明 B12 相对 B11 略低，但该值并非 6 类最高，也不足以单独证明或排除热液蚀变。该类整体反射率中等偏高，空间上呈较大块状分布，可能对应未蚀变或弱蚀变的中酸性岩体。

*（3）Cluster 2 —— 光谱背景类（37.2%）*。所有比值均处于 6 类的中间水平，无极端高值或低值。该类面积最大、光谱特征最中庸，可能代表研究区内广泛分布的火山-沉积岩基质。

*（4）Cluster 4 —— 低反射率类（6.9%）*。B04/B02（1.197）和 B08/B04（1.009）均为 6 类中最低，表明可见光波段和 NIR 波段的反射率整体偏低，可能对应基性火山岩（如安山岩）或地形阴影/低洼区域。

*（5）Cluster 3 —— 极小异常类（2.6%）*。B11/B12=1.061 为 6 类中最高，B12/B8A=1.080 为最低，B04/B02=1.447 为最高。如果仅从 B11/B12 的方向看，该类比 C1 更符合 B12 相对降低的条件；但其占比极小、空间分布零散，低置信度更符合混合像元（如蚀变带边缘与沉积物的过渡区）或局部特殊岩性露头的解释。

*（6）Cluster 5 —— 中等反射率过渡类（11.1%）*。B11/B12=1.057，为 6 类中次高，说明 B12 相对 B11 偏低；但该类同时具有较高 B04/B02=1.412，空间上多分布于边缘、谷地和冲沟两侧，更可能对应含少量铁氧化物染色的第四系沉积物或洪积扇堆积。因此，其 B11/B12 高值只能视为低置信光谱线索，不能直接判为热液蚀变。



#figurex(image("../results/cluster_spectra/cluster_spectral_profiles_per_class.png", width: 78%), [各聚类类别的单独光谱响应曲线（含 ±1σ 误差带）])

综上，光谱响应分析为聚类结果的地质解译提供了定量线索，但不能仅凭 B11/B12=0.992 将 Cluster 1 判定为明确的 SWIR 吸收类。C3 和 C5 的 B11/B12 更高，反而更符合 B12 相对 B11 降低的比值方向，但二者分别受面积过小、空间不连续和沉积物/铁氧化物染色特征影响，解释置信度有限。因此，本文将这些类别统一视为需要地质图或野外验证的光谱-空间候选线索；Cluster 4 的低反射率特征仍可指示基性岩或阴影区，其余类别反映不同程度的未蚀变岩体与沉积物背景。


== 遥感地质解释图生成

为避免交互式 GIS 软件人工制图过程带来的不可复现性，本文采用 rasterio 与 matplotlib 构建了全自动 Python 制图流程，生成最终遥感地质解释图（图 16）。具体流程为：首先读取裁剪后的 10 波段 Sentinel-2 栅格数据，提取 B12（2190 nm）、B8A（865 nm）和 B02（490 nm）构建地质假彩色底图；随后读取 SAE $z=5$, $k=6$ 的聚类 GeoTIFF，将 6 个聚类类别以固定配色方案半透明叠加（alpha=0.45）到底图之上；对原脚本标注的 C1 mask 进行二值形态学处理去除孤立噪点后，以红色轮廓高亮其空间范围；最后添加聚类图例、比例尺和指北针，以 300 dpi 输出。

#figurewide(image("../results/final_figures/python_final_interpretation_map.png", width: 50%), [基于 Python 自动生成的遥感地质解释图。\
底图为 Sentinel-2 B12/B8A/B02 地质假彩色影像，彩色半透明图层为 SAE $z=5$, $k=6$ 聚类结果（alpha=0.45）。\
C1 类以红色轮廓和箭头标注。需要注意，图中嵌入的 “C1 alteration candidate / SWIR absorption” 属于原脚本的旧版判读；本文修正后不再将最低 B11/B12 作为明确 B12 吸收证据，C1 仅作为待验证的光谱-空间候选线索。\
图中包含 6 类解释图例、比例尺、指北针和可复现脚注，生成流程完全脚本化。])

该自动化制图流程的优势在于：（1）图件生成过程完全可复现，只需重新运行脚本即可；（2）更换研究区或聚类结果后，可一键重新生成；（3）避免了 GIS 软件人工调参带来的图件风格不一致问题。

= 讨论

== PCA 为什么提升有限

实验结果表明，PCA 降维对聚类质量的改善微乎其微（CHI +2.7%）。这一现象的根本原因在于 PCA 与 K-means 的优化目标不一致：PCA 以最大化投影方差为目标，而 K-means 以最小化簇内平方和为目标。Sentinel-2 10 波段数据的 PC1 解释了 91.95% 的方差，主要捕获各波段反射率的整体强度变化（亮度/反照率），但聚类边界的确定往往依赖于波段比值、吸收深度等高阶光谱特征，这些信息散布在低方差的主成分中。PCA 保留前几个高方差主成分时可能丢弃了这些对聚类有用的判别性信息。

相比之下，自编码器的 MSE 重建目标迫使 bottleneck 保留所有有助于区分不同光谱向量的信息——包括那些方差占比小但对聚类判别重要的 SWIR 波段间差异和波段比值线索。这解释了为什么非线性 AE 的聚类效果显著优于 PCA。

== 深度的影响：深层自编码器是否总是必要的？

本实验中最引人注目的发现是：浅层 Canonical AE 的聚类质量（CHI=147,239）与深层 SAE（CHI=144,423）几乎持平，甚至在类别均衡性上略优（Max 36.0% vs 37.2%）。这一发现对原论文（Naagar et al., 2024）中"stacked autoencoders 比 canonical autoencoders 更好"的结论提出了重要的场景化补充——在原论文的半干旱沉积变质岩区，SAE 的优势是明确的；但在本研究的极干旱斑岩铜矿区，两者的聚类分离性几乎无差异。这提示我们，自编码器深度对聚类质量的增益可能存在"场景依赖性"：数据非线性越强、类别结构越复杂，深度网络的增益越大；反之，当数据以线性相关为主导时，浅层网络已经足够。

可能的解释如下：（1）Sentinel-2 的 10 个光谱波段之间以线性相关性为主（PC1 解释了 91.95% 方差），非线性结构相对有限，因此浅层 AE 已能捕获大部分非线性关系；（2）土屋-延东研究区的地表类型（4--6 类）较为简单，不需要过深的层级表示来分离复杂类别；（3）SAE 的额外参数量（1,935 vs 527）在有限训练样本（300,000）上的优势未能充分体现。

尽管如此，SAE 在 DBI 指标（0.6981 vs 0.7338）和重建精度（MSE 0.00285 vs 0.00466）上的优势表明，更深的网络确实学习了更紧凑和更精确的光谱表示。在实际应用中，如果下游任务对重建精度要求较高（如异常检测、光谱解混），SAE 仍是更优选择。

== Bottleneck 维度的选择

Bottleneck 维度 $z$ 是自编码器流程中的关键超参数。本实验中 $z=3$ 导致严重类别塌缩（SAE $z=3$ 的 CHI=93,656，最大类占比 48.9%），$z=4$ 有所改善但类别均衡性仍不理想（Max 42.0%），且在 Silhouette 和 DBI 上表现较好；$z=5$ 则在类别均衡性、CHI 和重建误差之间取得更稳妥的折中。因此，本文采用 $z=5$ 作为主实验隐空间维度，而不将其表述为所有指标上的绝对最优。研究区存在 4--6 种主要的地表覆盖/岩性类型（石英闪长斑岩、安山岩、花岗闪长岩、第四系沉积物、蚀变带），5 维隐空间为编码这些类别的光谱差异提供了较充足的自由度。

值得注意的是，本实验中仅测试了 $z ≤ 5$ 的设置。$z=6$ 或更大的 bottleneck 是否能在不过度引入噪声的前提下进一步提升聚类质量，值得在后续工作中探索。

== Geo-DEC 与 AE+K-means 的关系：替代还是补充？

Geo-DEC 与前述 AE + K-means 方法并不是完全割裂的两条路线。它继承了自编码器低维表示学习的基本思想，但将输入从 10 维原始光谱扩展为 28 维“光谱--地质指数--空间上下文”特征，使隐空间同时包含光谱反射率、蚀变相关波段比值和局部邻域统计信息。因此，Geo-DEC 可以看作是在 AE 表示学习框架上的地质先验与空间上下文增强。

同时，Geo-DEC 将 K-means 的后处理式聚类推进为 DEC 式联合优化：先用 K-means 初始化隐空间聚类中心，再通过软分配和目标分布的 KL 散度微调编码器与聚类中心。这一设计试图缓解传统 AE + K-means 中“先重建、后聚类”的目标错位问题。然而，本文实验结果显示，Geo-DEC 并未在 CHI 和 DBI 等传统分离指标上超过 Canonical AE 或 SAE——其 CHI 为 68,821，低于 Raw K-means 基线的 123,898。由于表 9 的 CHI、DBI 和 Silhouette 均在各自方法的特征空间内计算，该差异不宜解释为统一绝对基准下的性能降幅，只能说明当前 Geo-DEC 隐空间内部的簇分离度不占优。可能的原因包括：① 28 维输入特征中，3×3 邻域均值和标准差等空间上下文特征本质上是一种局部平滑，虽然改善了空间连续性，但可能稀释了原始光谱中具有判别力的细微差异（如 SWIR 波段间差异和比值线索），导致隐空间中不同类别的光谱判别信息被平滑抹平；② DEC 损失权重（0.1）和 3×3 邻域窗口等超参数尚未经过系统消融，当前配置可能未达到最优平衡。这本质上揭示了一个空间连续性与光谱分离性之间的 trade-off：引入空间上下文能够降低椒盐噪声，但过度平滑会牺牲光谱判别力。

此外，Geo-DEC 采用了更深的网络结构（28→64→32→z→32→64→28，8,231 个参数）和更大的输入维度，但其传统分离指标未提升，这与 Stage 1 的核心发现——Sentinel-2 数据场景下增加网络深度对聚类分离性增益不明显——方向一致。换言之，无论是在 10 维原始光谱上叠加 SAE 的深度增益（Stage 1），还是在 28 维增强特征上叠加 Geo-DEC 的深层联合优化（Stage 2），额外的网络深度均未带来聚类分离性方面的实质性提升。这一跨阶段的一致性进一步支持了本文的论点：该数据场景下的聚类判别结构主要被浅层非线性变换所捕获，更深层的网络在重建保真度和空间连续性等“外围”指标上仍有改善空间，但不应被指望成为提升聚类分离性的主要手段。

因此，Geo-DEC 在本文中的定位应是 AE + K-means 主线的制图增强补充，而不是替代 AE/SAE 的传统聚类指标最优模型。它的价值主要体现在 local agreement 提升和 isolated pixel ratio 降低，即更连续的地质图斑和更少的孤立像元。这一结果也提示：无监督遥感地质制图不能只依赖单一聚类分离指标评价，空间连续性和地质可解释性同样需要被显式纳入评价体系。

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
  [主线表示方法], [PCA / Canonical AE / Stacked AE], [PCA / Canonical AE / Stacked AE],
  [扩展方法], [未显式建模空间上下文], [Geo-DEC：地质指数 + 3×3 空间上下文 + DEC],
  [聚类方法], [K-means], [K-means ($k=5$, $6$) + DEC soft assignment],
  [聚类指标], [Calinski-Harabasz, Davies-Bouldin 等], [Silhouette / DBI / CHI + spatial metrics],
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
  [未系统分析 bottleneck 维度影响], [消融实验测试 $z=3, 4, 5$ 三种维度], [揭示 $z=3$ 导致类别塌缩，采用 $z=5$ 作为主实验折中维度],
  [仅两项聚类指标（CHI、DBI）], [引入 Silhouette 系数作为第三项指标], [三维度评估增强结论稳健性],
  [像元独立处理，空间信息主要依赖后处理], [提出 Geo-DEC，引入地质波段比值、3×3 空间上下文和 DEC 联合聚类损失], [local agreement 提升至 0.9348，isolated pixel ratio 降至 0.0057，但传统分离指标未超过 AE/SAE，说明其定位是空间制图增强],
  [地质解译以定性描述为主], [5 个波段比值定量分析 + 全自动制图], [修正 B11/B12 判读方向，将 C1 降级为待验证候选线索],
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
  [C1], [18.0%], [B11/B12=0.992（最低），B12/B8A=1.282（最高）；不能证明 B12 吸收], [北部带状-块状，与部分假彩色褐红色区对应], [蚀变或岩性边界候选线索], [中低（需地质图/野外验证）],
  [C0], [24.2%], [B11/B12=1.045（较高），整体反射率中等偏高], [南部、中东部大面积块状], [未蚀变或弱蚀变中酸性侵入岩候选], [中等],
  [C2], [37.2%], [各项比值居中，无极端特征], [全区广泛分布], [火山-沉积岩基质（安山岩/凝灰岩/碎屑岩）], [中等（面积最大、光谱最中庸）],
  [C4], [6.9%], [B04/B02=1.197（最低），全波段反射率低], [分散块状，部分沿水系/低洼区], [基性火山岩（安山岩）或地形阴影区], [较低],
  [C5], [11.1%], [B11/B12=1.057（次高），B04/B02=1.412 较高], [研究区边缘、谷地、冲沟两侧], [第四系松散沉积物/洪积扇（含少量铁氧化物染色）], [较低],
  [C3], [2.6%], [B11/B12=1.061（最高），B12/B8A=1.080（最低），B04/B02=1.447（最高）], [零星分布，空间不连续], [混合像元（蚀变边缘过渡区/局部特殊岩性）], [低],
)
]
#set text(size: 10pt)

*解译依据与讨论：*

（1）*Cluster 1 的蚀变解释应降级为待验证候选线索*。该类 B11/B12=0.992 为 6 类中最低，但这表示 B11 低于 B12，不能证明 B12（2190 nm）处存在吸收。其支持蚀变解释的证据主要来自两点：① 该类与地质假彩色图（图 2）中部分褐红色区域存在空间对应关系，但褐红色调主要反映 B12 通道亮度/对比度，并不等同于 SWIR 吸收；② 土屋-延东斑岩铜矿的围岩蚀变以绢英岩化和青磐岩化为主，在斑岩体与围岩接触带呈带状或面状分布#super[5]，与该类北部带状-块状的空间格局有一定相似性。综合来看，C1 可作为蚀变或岩性边界候选线索，但置信度不宜表述为高，必须依赖已发表地质图或野外查证进一步标定。

（2）*未蚀变或弱蚀变侵入岩候选（Cluster 0）*的 B11/B12=1.045，属于较高比值但并非最高。该值说明 B12 相对 B11 略低，但不足以单独判定吸收或蚀变强度。该类空间上呈大面积块状分布，与中酸性岩体的产状一致；其确切岩性归属（花岗闪长岩还是石英闪长斑岩）仍需要岩矿鉴定或已发表地质图的进一步约束。

（3）*火山-沉积岩基质（Cluster 2）*为面积最大的类别（37.2%），光谱特征中庸，空间上广泛分布，不排除其内部包含多种子类。这一"背景类"的存在符合区域地质中以石炭系火山-沉积岩系为主的特征。

（4）*低反射率类（Cluster 4）和沉积物类（Cluster 5）*的置信度较低，主要受限于缺乏地形校正（DEM）和沉积物光谱端元的先验知识。Cluster 4 的低反射率可能源于基性岩的矿物组成（暗色矿物含量高），也可能部分受地形阴影影响。Cluster 5 的空间分布与谷地、冲沟等负地形吻合，但波谱比值特征（B04/B02=1.412）暗示可能存在铁氧化物染色，这一特征与干旱区洪积扇沉积物一致。

（5）*混合像元类（Cluster 3）*占比仅 2.6%，虽然 B11/B12 为 6 类最高、从比值方向上更接近 B12 相对降低，但其空间不连续且面积过小，更适合判读为混合过渡类型或局部特殊岩性，不单独赋予确定地质含义。

需要强调的是，上述地质解译是基于无监督聚类结果的光谱推断，最终的地质归属需要结合野外查证或已发表的大比例尺地质图进行标定和验证。

== 局限性与展望

本研究存在以下局限：（1）无监督聚类缺乏地面真值验证，聚类类别的地质含义需要后续标定；（2）Geo-DEC 已引入 3×3 统计型空间上下文，但仍不是端到端的卷积空间建模，未来可进一步引入卷积自编码器（CAE）或图神经网络联合利用更大尺度的光谱-空间信息；（3）Geo-DEC 当前版本的 DEC 损失权重、3×3 空间窗口和增强特征组合尚未进行系统消融，因此本文只能说明“当前配置下空间连续性改善而传统分离指标下降”，尚不能精确分解地质指数、空间统计和 DEC 损失各自的贡献；（4）K-means 与 DEC 均偏向紧凑簇结构，对于光谱空间中可能存在的细长或弧形分布的簇适应性仍有限，GMM 或谱聚类可能是更合适的选择；（5）仅使用了单一时相的夏季影像，不同季节的太阳高度角和地表含水量差异可能影响光谱特征；（6）仅测试了 $z ≤ 5$ 的 bottleneck 设置，更大维度的探索尚不充分。

未来工作可在以下方向展开：（1）引入 DEM 和地形因子（坡度、坡向、阴影校正）以消除地形效应；（2）使用 ASTER 热红外波段补充岩性敏感的发射率信息；（3）将聚类结果与已知地质图进行定量一致性评估（如调整兰德指数 ARI、归一化互信息 NMI）；（4）围绕 Geo-DEC 开展组件消融，分别测试“仅地质指数”“仅空间上下文”“AE + K-means on 28D features”“不同 DEC 权重”和“不同邻域窗口”的影响；（5）尝试对比更多降维方法（t-SNE、UMAP、变分自编码器 VAE）对聚类效果的影响；（6）在更大范围的东天山地区验证该框架的泛化能力。

= 结论

本文以新疆土屋-延东斑岩型铜矿区为研究对象，基于 Sentinel-2A L2A 影像的 10 个光谱波段（B02--B12），构建了从预处理到无监督岩性聚类的完整遥感地质分析流程。全文采用“两阶段”逻辑：首先迁移并比较 Raw K-means、PCA + K-means、Canonical AE + K-means 和 SAE + K-means 构成的光谱聚类基线链条；随后引入 Geo-DEC 作为空间上下文增强扩展，检验其对地质图斑连续性的改善作用。主要结论如下：

（1）PCA 降维的增益有限。PCA $z=3$ 仅将 CHI 从 123,898 提升至 127,301（+2.7%），说明 Sentinel-2 10 波段中由整体亮度主导的高方差方向并不等同于最有利于 K-means 聚类分离的判别方向。

（2）非线性自编码器表示有效。Canonical AE 和 SAE 的主要配置均显著优于 Raw K-means 和 PCA，表明自编码器的重建目标能够保留对聚类判别有用的低方差信息，如 SWIR 波段间差异和波段比值线索。

（3）深度增益具有场景依赖性。浅层 Canonical AE 与深层 SAE 在聚类分离性指标上出人意料地接近——Canonical AE 的 CHI 略优（147,239 vs 144,423）。但 SAE 在重建精度（MSE=0.00285 vs 0.00466）和簇紧凑性（DBI=0.6981 vs 0.7338）上具有优势，说明深层结构在需要高保真光谱表示的任务中仍有价值。

（4）Bottleneck 维度显著影响聚类质量。$z=3$ 导致严重类别塌缩（最大类占比 48.9%，CHI 骤降至 93,656）；$z=4$ 在 Silhouette 和 DBI 上表现较好但类别均衡性不足；$z=5$ 在类别均衡性、CHI 和重建误差之间取得更稳妥折中，适合作为本研究区的主实验隐空间维度。

（5）光谱比值分析为地质解译提供了定量线索，但必须按比值方向谨慎解释。Cluster 1（18.0%）的 B11/B12=0.992 表明 B11 低于 B12，不能证明 B12（2190 nm）处存在 OH⁻ 吸收；其与部分假彩色褐红色区域的空间对应关系只能支持“蚀变或岩性边界候选线索”的低置信判断。C3 和 C5 的 B11/B12 更高，但分别受空间不连续、面积过小和沉积物/铁氧化物染色影响，也不能直接判为热液蚀变。

（6）Geo-DEC 是对 AE + K-means 主线的空间增强扩展。它将地质波段比值、3×3 空间上下文和 DEC 联合聚类损失纳入同一流程，将 local agreement 提升至 0.9348，并将 isolated pixel ratio 降至 0.0057，证明空间上下文对提升地质图斑连续性有效；但其 CHI 和 DBI 未超过 AE/SAE 系列方法，因此不应被视为替代 AE/SAE 的传统聚类指标最优模型，而应定位为面向制图连续性和可解释性的补充方法。

综合以上发现，本文凝练出四条核心认识：第一，SAE+K-means 无监督聚类框架在极端干旱斑岩铜矿区依然有效，具备跨气候带和跨大地构造单元的迁移能力；第二，在该数据场景下——Sentinel-2 10 波段以线性共线性为主导、地表类别数有限（4--6 类）——浅层自编码器的聚类性能与深层 SAE 旗鼓相当，提示自编码器深度的增益具有场景依赖性；第三，B11/B12 等波段比值可为蚀变或岩性异常提供候选线索，但不能脱离比值方向、空间分布和地质图/野外验证而单独作为高置信指示标志；第四，Geo-DEC 表明在原有两阶段框架之外，引入地质先验、空间上下文和聚类目标联合优化是提升无监督地质制图空间连续性和可解释性的有效扩展方向，但并不替代 AE/SAE 作为传统聚类分离指标上的强基线。上述认识分别对应了原论文（Naagar et al., 2024）在跨区域验证、深度增益分析、定量光谱解译和空间上下文利用方面的不足。

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

本项目完整代码及数据处理流程见 https://github.com/LeoZhangXYJ/GeoCluster_S2。preprocess_s2.py（数据预处理）、cluster_kmeans_baseline.py（Baseline K-means + Elbow）、pca_kmeans_baseline.py（PCA + K-means）、ae_kmeans_baseline.py（Canonical AE + K-means）、sae_kmeans.py（SAE + K-means）、geo_dec_clustering.py（Geo-DEC：地质指数与空间上下文增强的深度嵌入聚类）、analyze_cluster_spectra.py（聚类光谱响应分析）、compute_all_metrics.py（统一指标计算）、make_final_figures.py（对比图生成）、make_interpretation_map.py（Python 自动地质解释制图）。所有随机种子固定为 42，确保结果可复现。原论文开源代码见 https://github.com/sydney-machine-learning/autoencoders_remotesensing。
