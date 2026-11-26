/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 October 2026
 */

#version 460 core

#include <flutter/runtime_effect.glsl>


uniform vec2 u_size;
uniform sampler2D u_texture_input;
uniform vec2 u_vertical_bounds;
uniform float u_sigma;
uniform float u_tint_alpha;
uniform vec2 u_shade_bounds;
uniform float u_ambient;
uniform float u_visibility;
uniform float u_component;

out vec4 frag_color;

float glassShadeOpacity(float t) {
  if (t < 0.35) return mix(1.0, 0.988235294, t / 0.35);
  if (t < 0.50) return mix(0.988235294, 0.894117647, (t - 0.35) / 0.15);
  if (t < 0.65) return mix(0.894117647, 0.588235294, (t - 0.50) / 0.15);
  if (t < 0.80) return mix(0.588235294, 0.217647059, (t - 0.65) / 0.15);
  if (t < 0.90) return mix(0.217647059, 0.08, (t - 0.80) / 0.10);
  bool hasTail = u_vertical_bounds.y > u_vertical_bounds.x;
  if (t < 0.95) return mix(0.08, hasTail ? 0.039655 : 0.0382, (t - 0.90) / 0.05);
  if (!hasTail) return mix(0.0382, 0.0, clamp((t - 0.95) / 0.05, 0.0, 1.0));
  if (t < 1.0) return mix(0.039655, 0.016232, (t - 0.95) / 0.05);
  float tailSpan = (u_vertical_bounds.y - u_vertical_bounds.x) / 3.6;
  float tail = (t - 1.0) * max(u_shade_bounds.y - u_shade_bounds.x, 1.0) / tailSpan;
  if (tail < 0.25) return mix(0.016232, 0.010933, tail / 0.25);
  if (tail < 0.50) return mix(0.010933, 0.007116, (tail - 0.25) / 0.25);
  if (tail < 0.75) return mix(0.007116, 0.002349, (tail - 0.50) / 0.25);
  if (tail < 1.0) return mix(0.002349, 0.0, (tail - 0.75) / 0.25);
  return 0.0;
}

float opaqueShadeOpacity(float t) {
  if (t < 0.35) return 1.0;
  if (t < 0.50) return mix(1.0, 0.975, (t - 0.35) / 0.15);
  if (t < 0.55) return mix(0.975, 0.947, (t - 0.50) / 0.05);
  if (t < 0.60) return mix(0.947, 0.891, (t - 0.55) / 0.05);
  if (t < 0.65) return mix(0.891, 0.765, (t - 0.60) / 0.05);
  if (t < 0.70) return mix(0.765, 0.610, (t - 0.65) / 0.05);
  if (t < 0.75) return mix(0.610, 0.450, (t - 0.70) / 0.05);
  if (t < 0.80) return mix(0.450, 0.285, (t - 0.75) / 0.05);
  if (t < 0.85) return mix(0.285, 0.160, (t - 0.80) / 0.05);
  if (t < 0.90) return mix(0.160, 0.076, (t - 0.85) / 0.05);
  if (t < 0.95) return mix(0.076, 0.027, (t - 0.90) / 0.05);
  return mix(0.027, 0.0, (t - 0.95) / 0.05);
}

vec4 kernelWeights(float d) {
  if (d <= -1.6) return vec4(0.0);
  if (d < -0.682291667) return mix(vec4(0.000000000, 0.000000000, 0.000000000, 0.000000000), vec4(0.000000000, 0.089808466, 0.030771812, 0.700789190), (d - -1.600000000) / 0.917708333);
  if (d < -0.432291667) return mix(vec4(0.000000000, 0.089808466, 0.030771812, 0.700789190), vec4(0.000000000, 0.241237398, 0.129738294, 0.452265339), (d - -0.682291667) / 0.250000000);
  if (d < -0.307291667) return mix(vec4(0.000000000, 0.241237398, 0.129738294, 0.452265339), vec4(0.000000000, 0.360061649, 0.128325486, 0.391309674), (d - -0.432291667) / 0.125000000);
  if (d < -0.182291667) return mix(vec4(0.000000000, 0.360061649, 0.128325486, 0.391309674), vec4(0.000000000, 0.504885184, 0.113396462, 0.284886422), (d - -0.307291667) / 0.125000000);
  if (d < -0.119791667) return mix(vec4(0.000000000, 0.504885184, 0.113396462, 0.284886422), vec4(0.000000000, 0.581859115, 0.133043092, 0.184566076), (d - -0.182291667) / 0.062500000);
  if (d < -0.057291667) return mix(vec4(0.000000000, 0.581859115, 0.133043092, 0.184566076), vec4(0.000000000, 0.660564807, 0.121642834, 0.109455608), (d - -0.119791667) / 0.062500000);
  if (d < 0.005208333) return mix(vec4(0.000000000, 0.660564807, 0.121642834, 0.109455608), vec4(0.000000000, 0.764014167, 0.085788981, 0.086501660), (d - -0.057291667) / 0.062500000);
  if (d < 0.036458333) return mix(vec4(0.000000000, 0.764014167, 0.085788981, 0.086501660), vec4(0.000000000, 0.820998217, 0.044122792, 0.119956872), (d - 0.005208333) / 0.031250000);
  if (d < 0.067708333) return mix(vec4(0.000000000, 0.820998217, 0.044122792, 0.119956872), vec4(0.000000000, 0.866120095, 0.032461878, 0.080226875), (d - 0.036458333) / 0.031250000);
  if (d < 0.098958333) return mix(vec4(0.000000000, 0.866120095, 0.032461878, 0.080226875), vec4(0.130590907, 0.785409643, 0.051340329, 0.019941924), (d - 0.067708333) / 0.031250000);
  if (d < 0.130208333) return mix(vec4(0.130590907, 0.785409643, 0.051340329, 0.019941924), vec4(0.665046775, 0.326007853, 0.004809277, 0.004136095), (d - 0.098958333) / 0.031250000);
  if (d < 0.161458333) return mix(vec4(0.665046775, 0.326007853, 0.004809277, 0.004136095), vec4(0.830850450, 0.165925942, 0.000000000, 0.000000000), (d - 0.130208333) / 0.031250000);
  if (d < 0.192708333) return mix(vec4(0.830850450, 0.165925942, 0.000000000, 0.000000000), vec4(0.972918457, 0.027081543, 0.000000000, 0.000000000), (d - 0.161458333) / 0.031250000);
  if (d < 0.223958333) return mix(vec4(0.972918457, 0.027081543, 0.000000000, 0.000000000), vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), (d - 0.192708333) / 0.031250000);
  if (d < 0.255208333) return mix(vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), (d - 0.223958333) / 0.031250000);
  if (d < 0.317708333) return mix(vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), (d - 0.255208333) / 0.062500000);
  if (d < 0.442708333) return mix(vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), vec4(1.000000000, 0.000000000, 0.000000000, 0.000000000), (d - 0.317708333) / 0.125000000);
  return vec4(1.0, 0.0, 0.0, 0.0);
}

vec4 sampleBackdrop(vec2 position) {
  if (position.x < 0.5 || position.x > u_size.x - 0.5) {
    float span = max(u_size.x - 1.0, 0.0);
    if (span > 0.0) {
      float folded = mod(position.x - 0.5, span * 2.0);
      position.x = 0.5 + min(folded, span * 2.0 - folded);
    } else {
      position.x = 0.5;
    }
  }
  vec2 uv = position / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(u_texture_input, uv);
}

vec4 separatedContribution(vec2 position) {
  float fieldY = position.y;
  float height = max(u_vertical_bounds.y - u_vertical_bounds.x, 1.0);
  float extent = height / 1.8;
  float distance = (fieldY - u_vertical_bounds.y + extent * 0.2) / extent;
  vec4 kernel = distance >= 0.223958333 ? vec4(1.0, 0.0, 0.0, 0.0) : kernelWeights(distance);
  vec4 contribution = vec4(0.0);
  if (u_sigma > 0.0 && kernel.x < 1.0) {
    float weight = u_component < 0.5 ? kernel.z
        : u_component < 1.5 ? kernel.w : max(0.0, 1.0 - dot(kernel, vec4(1.0)));
    if (weight > 0.0) contribution = sampleBackdrop(position) * weight;
  }
  float t = max((fieldY - u_shade_bounds.x) / max(u_shade_bounds.y - u_shade_bounds.x, 1.0), 0.0);
  float opacity = u_visibility == 1.0
      ? opaqueShadeOpacity(min(t, 1.0))
      : mix(glassShadeOpacity(t), opaqueShadeOpacity(min(t, 1.0)), u_visibility);
  float alpha = u_tint_alpha * opacity;
  float ambient = u_ambient * opacity;
  contribution *= (1.0 - alpha) * (1.0 - ambient);
  return contribution;
}

void main() {
  vec2 position = FlutterFragCoord().xy;
  frag_color = separatedContribution(position);
}
