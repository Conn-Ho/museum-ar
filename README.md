# iOS Museum AR Guide — 基于iOS的博物馆AR导览系统

> An iOS app that blends a 3D virtual museum with marker-free AR so users can explore cultural artifacts anywhere.

Built as a graduation thesis project (Wuhan University, 2025), this repository contains the **frontend iOS implementation** of a hybrid museum guidance system. The app lets users roam a 3D virtual museum and place AR artifacts in their own physical environment — no GPS or fixed QR markers required.

## What it does

- **3D Virtual Museum** — freely navigate a full SceneKit-rendered museum with gesture controls (swipe, pinch-to-zoom, rotate)
- **Marker-free AR** — place USDZ artifacts on any real-world surface (desk, floor, wall) using ARKit plane detection; rotate and scale them in 360°
- **Interactive exhibits** — tap any artifact for 3D model detail, text description, and audio narration
- **Social messaging** — leave text, voice, or doodle notes tied to specific exhibits
- **Smart recommendations** — collaborative-filtering algorithm suggests exhibits based on browsing history and favourites

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift + SwiftUI |
| AR | ARKit 6.0 + RealityKit |
| 3D Rendering | SceneKit (LOD optimised) |
| Architecture | MVVM, feature-based modules |
| 3D Assets | USDZ (Photogrammetry pipeline) |
| Backend (not included) | Alibaba Cloud ECS, OSS, RDS, Tair |

## Architecture

Client-cloud separated design. The frontend handles all AR/3D rendering via ARKit + SceneKit, communicates with a RESTful JSON API, and uses MVVM to decouple business logic from views. The backend (not in this repo) runs on Alibaba Cloud with nginx, Docker, RDS, and OSS for model storage.

Key AR metrics from the thesis:
- Plane detection accuracy: ±2 cm
- Marker-free AR tracking stability: >95%
- Supports iPhone 8 and above (>85% device coverage)
- Target render budget: ≤16.67 ms per frame (60 FPS)

## Note

> This repository contains the **frontend iOS implementation** only. The full system (including backend/server components) was developed as part of a graduation thesis and is not publicly available.

---

## 毕业设计项目

本项目为武汉大学2025届本科毕业设计，题目为《基于iOS系统的博物馆导览系统的设计与实现》。系统采用 Swift + ARKit + SceneKit 构建，融合3D虚拟展厅漫游与无标记AR展品交互，并集成协同过滤智能推荐算法。本仓库仅包含前端实现部分。
