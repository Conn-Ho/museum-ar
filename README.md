# iOS Museum AR Guide

> An iOS app that blends a 3D virtual museum with marker-free AR so users can explore cultural artifacts anywhere.

This repository contains the **frontend iOS implementation** of a hybrid museum guidance system. The app lets users roam a 3D virtual museum and place AR artifacts in their own physical environment — no GPS or fixed QR markers required.

## What it does

- **3D Virtual Museum** — freely navigate a full SceneKit-rendered museum with gesture controls (swipe, pinch-to-zoom, rotate)
- **Marker-free AR** — place USDZ artifacts on any real-world surface using ARKit plane detection; rotate and scale them in 360°
- **Interactive exhibits** — tap any artifact for 3D model detail, text description, and audio narration
- **Social messaging** — leave text, voice, or doodle notes tied to specific exhibits
- **Smart recommendations** — collaborative-filtering algorithm suggests exhibits based on browsing history

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift + SwiftUI |
| AR | ARKit 6.0 + RealityKit |
| 3D Rendering | SceneKit (LOD optimised) |
| Architecture | MVVM |
| 3D Assets | USDZ (Photogrammetry pipeline) |
| Backend (not included) | Alibaba Cloud ECS · OSS · RDS |

## Performance

- Plane detection accuracy: ±2 cm
- AR tracking stability: >95%
- Target render budget: ≤16.67 ms/frame (60 FPS)
- Supports iPhone 8 and above

## Note

This repository contains the **frontend iOS implementation** only. Backend services are not publicly available.
