/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 5 November 2026
 */

#version 460 core

// Keep separable kernels without indexed sample pairing in D3D.
#define SCROLL_EDGE_SEPARATED
#define SCROLL_EDGE_UNPAIRED
// Windows backdrop snapshots already use top-left texture coordinates.
#define SCROLL_EDGE_TOP_LEFT_INPUT
#include "scroll_edge.glsl"
