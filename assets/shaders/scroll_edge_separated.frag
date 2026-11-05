/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 5 November 2026
 */

#version 460 core

// Contribution passes never execute the generic two-dimensional fallback.
// Compile only their shared separable kernels, keeping the same uniforms.
#define SCROLL_EDGE_SEPARATED
#include "scroll_edge.glsl"
