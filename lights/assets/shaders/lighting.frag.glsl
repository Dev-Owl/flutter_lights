#version 320 es

precision highp float;

layout(location=0)out vec4 fragColor;

layout(location=0)uniform vec2 resolution;

layout(location=1)uniform sampler2D lightSampler;

void main(){
    fragColor=texture(lightSampler,gl_FragCoord.xy/resolution.xy);
}