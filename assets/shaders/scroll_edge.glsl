/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 11 October 2026
 */

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform sampler2D u_texture_input;
uniform vec2 u_vertical_bounds;
uniform float u_sigma;
uniform vec2 u_direction;
uniform vec4 u_tint;
uniform vec2 u_shade_bounds;
uniform float u_ambient;
uniform float u_visibility;
uniform vec2 u_kernel_pairs[93];
uniform vec3 u_kernel_counts;
uniform float u_component;
uniform float u_stage;

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
  // The vertical input surrounds the horizontal result with one transparent texel.
  if (u_stage > 2.5 && u_stage < 3.5) position.y = clamp(position.y, 1.5, u_size.y - 1.5);
  vec2 uv = position / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(u_texture_input, uv);
}

vec4 sampleHalfResolution(vec2 position) {
  vec2 lower = floor((position - vec2(1.0)) * 0.5) * 2.0 + vec2(1.0);
  vec2 fraction = (position - lower) * 0.5;
  return mix(
      mix(sampleBackdrop(lower), sampleBackdrop(lower + vec2(2.0, 0.0)), fraction.x),
      mix(sampleBackdrop(lower + vec2(0.0, 2.0)), sampleBackdrop(lower + vec2(2.0)), fraction.x),
      fraction.y);
}

#ifndef SCROLL_EDGE_SEPARATED
vec4 sampleGaussian(vec2 position, int start, int count) {
  // SkSL requires constant indices when reading uniform arrays.
#if defined(IMPELLER_GRAPHICS_BACKEND) && !defined(SCROLL_EDGE_UNPAIRED)
  float margin = max(3.0 * u_sigma + 1.0, 2.0);
  if (all(equal(fract(position), vec2(0.5))) && position.x >= 0.5 + margin && position.x <= u_size.x - 0.5 - margin) {
    vec4 interior = vec4(0.0);
    for (int y = 0; y < 31; y++) {
      if (y >= count) break;
      vec2 vertical = u_kernel_pairs[start + y];
      for (int x = 0; x < 31; x++) {
        if (x >= count) break;
        vec2 horizontal = u_kernel_pairs[start + x];
        vec2 uv = (position + vec2(horizontal.x, vertical.x)) / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
        uv.y = 1.0 - uv.y;
#endif
        interior += texture(u_texture_input, uv) * horizontal.y * vertical.y;
      }
    }
    return interior;
  }

#endif
  vec4 result = vec4(0.0);
  // A transformed snapshot can place fragments between input texel centres.
  // Keep the original sampling there; paired taps are exact only at centres.
#if defined(IMPELLER_GRAPHICS_BACKEND) && !defined(SCROLL_EDGE_UNPAIRED)
  if (any(notEqual(fract(position), vec2(0.5)))) {
#endif
    float weightSum = 0.0;
    for (int y = -15; y <= 15; y++) {
      for (int x = -15; x <= 15; x++) {
        vec2 offset = vec2(float(x), float(y)) * 0.2;
        float weight = exp(-0.5 * dot(offset, offset));
        vec2 displacement = start == 62 ? offset * u_sigma : offset * (u_sigma / 5.55) * (start == 0 ? 2.0 : 4.0);
        result += sampleBackdrop(position + displacement) * weight;
        weightSum += weight;
      }
    }
    return result / weightSum;
#if defined(IMPELLER_GRAPHICS_BACKEND) && !defined(SCROLL_EDGE_UNPAIRED)
  }
  for (int y = 0; y < 31; y++) {
    if (y >= count) break;
    vec2 vertical = u_kernel_pairs[start + y];
    for (int x = 0; x < 31; x++) {
      if (x >= count) break;
      vec2 horizontal = u_kernel_pairs[start + x];
      result += sampleBackdrop(position + vec2(horizontal.x, vertical.x)) * horizontal.y * vertical.y;
    }
  }
  return result;
#endif
}

#endif

// Each Gaussian is separated before its original row-dependent coefficient.
vec4 sampleGaussianAxis(vec2 position, vec2 axis) {
#if defined(IMPELLER_GRAPHICS_BACKEND) && !defined(SCROLL_EDGE_UNPAIRED)
  float width = u_component > 1.5 ? u_sigma : (u_sigma / 5.55) * (u_component < 0.5 ? 2.0 : 4.0);
  float coordinate = dot(position, axis);
  float centered = floor(coordinate) + 0.5;
  float margin = max(3.0 * width + 1.0, 2.0);
  if (abs(coordinate - centered) <= 0.001 && coordinate >= 0.5 + margin
      && coordinate <= dot(u_size, axis) - 0.5 - margin) {
    position += axis * (centered - coordinate);
    int component = u_component < 0.5 ? 0 : u_component < 1.5 ? 1 : 2;
    int count = component == 0 ? int(u_kernel_counts.x)
        : component == 1 ? int(u_kernel_counts.y) : int(u_kernel_counts.z);
    vec4 paired = vec4(0.0);
    for (int tap = 0; tap < 31; tap++) {
      if (tap >= count) break;
      vec2 pair = u_kernel_pairs[component * 31 + tap];
      paired += sampleBackdrop(position + axis * pair.x) * pair.y;
    }
    return paired;
  }
#endif
  vec4 result = vec4(0.0);
  float weightSum = 0.0;
  for (int tap = -15; tap <= 15; tap++) {
    float offset = float(tap) * 0.2;
    float weight = exp(-0.5 * offset * offset);
    vec2 displacement = u_component > 1.5
        ? axis * offset * u_sigma
        : axis * offset * (u_sigma / 5.55) * (u_component < 0.5 ? 2.0 : 4.0);
    result += sampleBackdrop(position + displacement) * weight;
    weightSum += weight;
  }
  return result / weightSum;
}

vec4 separatedContribution(vec2 position) {
  if (u_stage > 3.5 && u_stage < 4.5) return sampleBackdrop(position);
  if (u_stage < 2.5 && u_stage > 1.5) {
    if (u_sigma == 0.0) return sampleBackdrop(position);
    float height = max(u_vertical_bounds.y - u_vertical_bounds.x, 1.0);
    // Keep a conservative tail beyond the final nonzero vertical Gaussian weight.
    float lastRequiredRow = u_vertical_bounds.y + (height / 1.8) * 0.25 + 3.0 * u_sigma + 4.0;
    if (position.y > lastRequiredRow) return vec4(0.0);
    return sampleGaussianAxis(position, vec2(1.0, 0.0));
  }
  float fieldY = u_stage > 2.5 && u_stage < 3.5 ? position.y - 1.0 : position.y;
  float height = max(u_vertical_bounds.y - u_vertical_bounds.x, 1.0);
  float extent = height / 1.8;
  float distance = (fieldY - u_vertical_bounds.y + extent * 0.2) / extent;
  vec4 kernel = distance >= 0.223958333 ? vec4(1.0, 0.0, 0.0, 0.0) : kernelWeights(distance);
  vec4 contribution = vec4(0.0);
  if (u_stage > 6.5) {
    // The generic program is loaded only when needed. Retain its loading shade
    // while the source shader is being prepared, as during initial loading.
    contribution = sampleBackdrop(position);
  } else if (u_stage < 1.5) {
    if (u_sigma == 0.0 || kernel.x == 1.0) {
      contribution = sampleBackdrop(position);
    } else if (kernel.x != 0.0 || kernel.y != 0.0) {
      if (kernel.x == 0.0 && u_visibility == 1.0) {
        contribution = sampleHalfResolution(position) * kernel.y;
      } else {
        vec4 centerSample = sampleBackdrop(position);
        contribution = centerSample * kernel.x;
        contribution += mix(centerSample, sampleHalfResolution(position), u_visibility) * kernel.y;
      }
    }
  } else if (u_sigma > 0.0 && kernel.x < 1.0) {
    float weight = u_component < 0.5 ? kernel.z
        : u_component < 1.5 ? kernel.w : max(0.0, 1.0 - dot(kernel, vec4(1.0)));
    if (weight > 0.0) contribution = (u_stage > 5.5 ? sampleBackdrop(position) : sampleGaussianAxis(position, vec2(0.0, 1.0))) * weight;
  }
  float t = max((fieldY - u_shade_bounds.x) / max(u_shade_bounds.y - u_shade_bounds.x, 1.0), 0.0);
  float opacity = u_visibility == 1.0
      ? opaqueShadeOpacity(min(t, 1.0))
      : mix(glassShadeOpacity(t), opaqueShadeOpacity(min(t, 1.0)), u_visibility);
  float alpha = u_tint.a * opacity;
  float ambient = u_ambient * opacity;
  contribution *= (1.0 - alpha) * (1.0 - ambient);
  if (u_stage < 1.5 || u_stage > 6.5) {
    contribution += vec4(u_tint.rgb * alpha, alpha) * (1.0 - ambient);
    contribution += vec4(0.0, 0.0, 0.0, ambient);
  }
  return contribution;
}

void main() {
  vec2 position = FlutterFragCoord().xy;
#ifdef SCROLL_EDGE_SEPARATED
  frag_color = separatedContribution(position);
#else
#if defined(IMPELLER_GRAPHICS_BACKEND)
  if (u_stage > 0.0) {
    frag_color = separatedContribution(position);
    return;
  }
#endif
  float height = max(u_vertical_bounds.y - u_vertical_bounds.x, 1.0);
  float progress = max((position.y - u_vertical_bounds.x) / height, 0.0);
  float extent = height / 1.8;
  float distance = (position.y - u_vertical_bounds.y + extent * 0.2) / extent;
  vec4 kernel = kernelWeights(distance);
  float amount = 1.0 - kernel.x;
  float coarse = max(0.0, 1.0 - dot(kernel, vec4(1.0)));
  float sigma = u_sigma;
  if (sigma == 0.0 || amount == 0.0) {
    frag_color = sampleBackdrop(position);
  } else {
    vec4 centerSample = sampleBackdrop(position);
    frag_color = centerSample * kernel.x;
    vec4 minimum = mix(centerSample, sampleHalfResolution(position), u_visibility);
    frag_color += minimum * kernel.y;
    if (kernel.z > 0.0) frag_color += sampleGaussian(position, 0, int(u_kernel_counts.x)) * kernel.z;
    if (kernel.w > 0.0) frag_color += sampleGaussian(position, 31, int(u_kernel_counts.y)) * kernel.w;
    if (coarse > 0.0) frag_color += sampleGaussian(position, 62, int(u_kernel_counts.z)) * coarse;
  }
  // Only the final pass shades the blurred content, preserving premultiplied alpha.
  if (u_direction.y > 0.0) {
    float t = max((position.y - u_shade_bounds.x) / max(u_shade_bounds.y - u_shade_bounds.x, 1.0), 0.0);
    float opacity = mix(glassShadeOpacity(t), opaqueShadeOpacity(min(t, 1.0)), u_visibility);
    float alpha = u_tint.a * opacity;
    frag_color = vec4(u_tint.rgb * alpha, alpha) + frag_color * (1.0 - alpha);
    float ambient = u_ambient * opacity;
    frag_color = vec4(0.0, 0.0, 0.0, ambient) + frag_color * (1.0 - ambient);
  }
#endif
}
