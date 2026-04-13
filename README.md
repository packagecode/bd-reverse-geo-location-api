---
title: BD Reverse Geocoder
emoji: 🌍
colorFrom: green
colorTo: blue
sdk: docker
pinned: true
---

# BD Reverse Geocoder API 

This repository contains the Production Architecture for the ultra-fast, offline reverse geocoding API for Bangladesh.

It maps coordinates to `[Division > District > Upazila > Union/Ward > Mouza > Village]` with ~0.8ms latency and ~0MB Runtime Memory via $O(1)$ memory-mapped bounding box arrays.
