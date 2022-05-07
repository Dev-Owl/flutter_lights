#version 320 es

// inspired and derived from
// https://www.shadertoy.com/view/4dfXDn

precision highp float;

layout(location=0)out vec4 fragColor;

layout(location=0)uniform vec2 resolution;
layout(location=1)uniform sampler2D lightSampler;
layout(location=2)uniform vec2 lightSize;

// data texture
layout(location=3)uniform sampler2D dataSampler;
layout(location=4)uniform vec2 dataSize;

vec4 sampleLight(vec2 position,float scale){
    return texture(lightSampler,position.xy/(lightSize.xy*scale));
}

// data retrieval from a texture
vec4 getFloatsAt(vec2 position){
    return texture(dataSampler,position.xy/dataSize);
}
vec4 getBytesAt(vec2 position){
    return getFloatsAt(position)*255.;
}
float getNumberAt(vec2 position){
    vec4 bytes=getBytesAt(position);
    return(bytes.r*256.+bytes.g*256.+bytes.b)/256.;
}
float positionToIndex(vec2 position){
    return position.x+position.y*dataSize.x;
}
vec2 indexToPosition(float index){
    // without mod
    float y=floor(index/dataSize.x);
    float x=index-y*dataSize.x;
    return vec2(x,y);
}
float getNumber(float index){
    vec2 position=indexToPosition(index);
    return getNumberAt(position);
}

// boxes
vec4 getBox(float offset,float index){
    float indexOffset=offset+index*4.;
    float x=getNumber(indexOffset);
    float y=getNumber(indexOffset+1.);
    float width=getNumber(indexOffset+2.);
    float height=getNumber(indexOffset+3.);
    return vec4(x,y,width,height);
}
// lights
vec2 getLight(float offset,float index){
    float indexOffset=offset+index*2.;
    float x=getNumber(indexOffset);
    float y=getNumber(indexOffset+1.);
    return vec2(x,y);
}

void main(){
    fragColor=vec4(0.,0.,0.,0.);
    vec2 position=gl_FragCoord.xy;
    
    // boxes
    float obscurerCount=getNumber(0.);
    for(float i=0.;i<256.;i++){
        if(i<obscurerCount){
            vec4 box=getBox(1.,i);
            if(position.x>=box.x-box.z){
                if(position.x<=box.x+box.z){
                    if(position.y>=box.y-box.w){
                        if(position.y<=box.y+box.w){
                            fragColor=vec4(1.,0.,0.,1.);
                        }
                    }
                }
            }
        }
    }
    
    // lights
}