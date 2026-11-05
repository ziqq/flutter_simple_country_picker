/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 5 November 2026
 */

#version 460 core

// Keep separable kernels and their uniform bounds in the Windows compiler.
#define SCROLL_EDGE_SEPARATED
#define SCROLL_EDGE_DYNAMIC_LOOPS
#include "scroll_edge.glsl"
