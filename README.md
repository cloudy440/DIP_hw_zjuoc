# DIP_hw_zjuoc

> 浙大海洋学院（ZJUOC）**数字图像处理**课程实验代码

[![MATLAB](https://img.shields.io/badge/MATLAB-R2021b%2B-blue?logo=mathworks)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📖 项目简介

本仓库收录了 ZJUOC 数字图像处理（DIP）课程每周实验的 MATLAB 源代码。内容涵盖灰度变换、空间滤波、几何变换、频域处理（DFT）及图像分割等核心主题，与课程 Demo 风格保持一致。

---

## 📂 文件结构

```
DIP_hw_zjuoc/
├── week1_test.m        # Week 1 ——海表温度（SST）遥感数据读取与可视化
├── week2_test.m        # Week 2 ——亮度对比度实验（ΔI/I 计算与背景-目标显示）
├── week2_draft.m       # Week 2 草稿
├── week3.m             # Week 3 ——灰度内插与几何变换
├── week3_0928_draft.m  # Week 3 草稿
├── week4.m             # Week 4 ——灰度级变换与直方图处理
├── week5.m             # Week 5 ——空间滤波（平滑 / 锐化 / 梯度）
├── week6.m             # Week 6 ——二维离散傅里叶变换（DFT）
├── seg.m               # 图像分割（边缘检测 + 阈值分割）
├── exp6_solution.m     # 实验6参考答案（DFT 卷积与频域处理）
├── cl.m / t1.m / t2.m  # 其他调试 / 草稿脚本
├── tezheng.m / no_use.m
├── homework_test_1.m
├── *.tif / *.bmp / *.jpg / *.png   # 实验用图像素材
└── README.md
```

---

## 🗓️ 实验内容概览

| 文件 | 实验主题 | 主要知识点 |
|------|----------|-----------|
| `week1_test.m` | 遥感 SST 数据处理 | NetCDF 读取、m_map 投影绘图 |
| `week2_test.m` | 亮度感知实验 | ΔI/I 对比度计算、灰度图像合成 |
| `week3.m` | 几何变换 | 灰度内插（最近邻/双线性/双三次）、仿射变换、人脸配准 |
| `week4.m` | 灰度变换 & 直方图 | 幂律变换、分段线性变换、比特平面分层、直方图均衡化（HE/CLAHE）|
| `week5.m` | 空间滤波 | 均值/高斯平滑、中值滤波、拉普拉斯锐化、非锐化掩蔽、Sobel 梯度 |
| `week6.m` | 频域处理 | 2D DFT / IDFT、频谱中心化、幅度谱与相位谱可视化 |
| `seg.m` | 图像分割 | 边缘检测算子对比、Otsu 阈值分割 |
| `exp6_solution.m` | DFT 卷积（参考答案） | fft2 卷积验证、频域滤波 |

---

## 🚀 快速开始

### 环境要求

- MATLAB **R2021b** 或更高版本
- Image Processing Toolbox（`imfilter`、`histeq`、`imresize` 等）
- Mapping Toolbox（`week1_test.m` 中的 `m_map` 绘图，可选）

### 运行方式

1. 克隆仓库到本地：
   ```bash
   git clone https://github.com/cloudy440/DIP_hw_zjuoc.git
   ```
2. 在 MATLAB 中将仓库根目录设为当前工作目录：
   ```matlab
   cd('path/to/DIP_hw_zjuoc')
   ```
3. 打开并运行对应的周实验脚本，例如：
   ```matlab
   run('week5.m')
   ```
4. 部分脚本（`week4.m`、`week5.m`）默认从本地路径读取图像，运行前请将 `indir` 变量修改为本机实际路径，或将图像文件放入当前工作目录。

---

## 📦 依赖说明

| 工具箱 / 库 | 用途 | 必需 |
|------------|------|------|
| Image Processing Toolbox | 图像读写、滤波、变换 | ✅ |
| m_map（第三方）| week1 遥感地图投影 | 仅 week1 |
| Statistics and Machine Learning Toolbox | 部分统计函数 | 可选 |

---

## 📝 注意事项

- `week1_test.m` 依赖 AQUA/MODIS SST NetCDF 数据文件及 `m_map` 工具箱，未安装时可跳过。
- `week3.m` 中的人脸配准步骤（`cpselect`）需要手动交互选点，批量运行时可注释该部分。
- 图像文件（`.tif`、`.bmp`、`.jpg`）已包含在仓库中，可直接作为测试素材使用。

---

## 🤝 贡献

本仓库为个人课程作业存档，欢迎参考与交流。如发现 bug 或有改进建议，欢迎提 Issue 或 Pull Request。

---

## 📄 许可证

本项目仅供学习交流使用，遵循 [MIT License](LICENSE)。
