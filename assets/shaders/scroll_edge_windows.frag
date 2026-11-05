/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 5 November 2026
 */

#version 460 core

// Preserve the generic filter while keeping texture loops dynamic in D3D.
#define SCROLL_EDGE_DYNAMIC_LOOPS
#include "scroll_edge.glsl"
