/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 5 November 2026
 */

#version 460 core

// Use the original Gaussian sum without indexed sample pairing in D3D.
#define SCROLL_EDGE_UNPAIRED
#include "scroll_edge.glsl"
