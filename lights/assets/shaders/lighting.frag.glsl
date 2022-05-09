#version 320 es

// inspired and derived from
// https://www.shadertoy.com/view/4dfXDn

precision highp float;

layout(location=0)out vec4 fragColor;

layout(location=0)uniform vec2 resolution;

// data texture
layout(location=3)uniform sampler2D dataSampler;
layout(location=4)uniform vec2 dataSize;

// data retrieval from a texture
vec4 getFloatsAt(vec2 position){
    return texture(dataSampler,position.xy/dataSize);
}
vec4 getBytesAt(vec2 position){
    return getFloatsAt(position)*255.;
}
float getNumberAt(vec2 position){
    vec4 bytes=getBytesAt(position);
    return(bytes.r*256.+bytes.g*256.+bytes.b)/10.;
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
float boxCount(){
    return getNumber(0.);
}
vec4 getBox(float index){
    float indexOffset=1.+index*4.;
    float x=getNumber(indexOffset);
    float y=getNumber(indexOffset+1.);
    float width=getNumber(indexOffset+2.);
    float height=getNumber(indexOffset+3.);
    return vec4(x,y,width,height);
}
// lights
float lightCount(){
    return getNumber(boxCount()*4.+1.);
}
vec2 getLightPosition(float index){
    float indexOffset=(boxCount()*4.+2.)+index*8.;
    float x=getNumber(indexOffset);
    float y=getNumber(indexOffset+1.);
    return vec2(x,y);
}
vec4 getLightColor(float index){
    float indexOffset=(boxCount()*4.+2.)+index*8.;
    float r=getNumber(indexOffset+2.);
    float g=getNumber(indexOffset+3.);
    float b=getNumber(indexOffset+4.);
    float a=getNumber(indexOffset+5.);
    return vec4(r,g,b,a);
}
vec2 getLightRangeAndRadius(float index){
    float indexOffset=(boxCount()*4.+2.)+index*8.;
    float range=getNumber(indexOffset+6.);
    float radius=getNumber(indexOffset+7.);
    return vec2(range,radius);
}

// actual lighting
//////////////////////////////////////
// Combine distance field functions //
//////////////////////////////////////

float merge(float d1,float d2)
{
    return min(d1,d2);
}

//////////////////////////////
// Rotation and translation //
//////////////////////////////

vec2 translate(vec2 p,vec2 t)
{
    return p-t;
}

//////////////////////////////
// Distance field functions //
//////////////////////////////

float circleDist(vec2 p,float radius)
{
    return length(p)-radius;
}

float boxDist(vec2 p,vec2 size,float radius)
{
    size-=vec2(radius);
    vec2 d=abs(p)-size;
    return min(max(d.x,d.y),0.)+length(max(d,0.))-radius;
}

///////////////////////
// Masks for drawing //
///////////////////////

float fillMask(float dist)
{
    return clamp(-dist,0.,1.);
}

///////////////
// The scene //
///////////////

float sceneDist(vec2 p)
{
    vec4 box0=getBox(0.);
    float m=boxDist(translate(p,box0.xy),box0.zw,0.);
    float boxCount=boxCount();
    for(float i=1.;i<=2.;i++){
        if(i<boxCount){
            vec4 box=getBox(i);
            m=merge(m,boxDist(translate(p,box.xy),box.zw,0.));
        }
    }
    return m;
}

float sceneSmooth(vec2 p,float r)
{
    float accum=sceneDist(p);
    accum+=sceneDist(p+vec2(0.,r));
    accum+=sceneDist(p+vec2(0.,-r));
    accum+=sceneDist(p+vec2(r,0.));
    accum+=sceneDist(p+vec2(-r,0.));
    return accum/5.;
}

//////////////////////
// Shadow and light //
//////////////////////

float shadow(vec2 p,vec2 pos,float radius)
{
    vec2 dir=normalize(pos-p);
    float dl=length(p-pos);
    
    // fraction of light visible, starts at one radius (second half added in the end);
    float lf=radius*dl;
    
    // distance traveled
    float dt=.01;
    
    for(float i=0.;i<64.;++i)
    {
        // distance to scene at current position
        float sd=sceneDist(p+dir*dt);
        
        // early out when this ray is guaranteed to be full shadow
        if(sd<-radius)
        return 0.;
        
        // width of cone-overlap at light
        // 0 in center, so 50% overlap: add one radius outside of loop to get total coverage
        // should be '(sd / dt) * dl', but '*dl' outside of loop
        lf=min(lf,sd/dt);
        
        // move ahead
        dt+=max(1.,abs(sd));
        if(dt>dl)break;
    }
    
    // multiply by dl to get the real projected overlap (moved out of loop)
    // add one radius, before between -radius and + radius
    // normalize to 1 ( / 2*radius)
    lf=clamp((lf*dl+radius)/(2.*radius),0.,1.);
    lf=smoothstep(0.,1.,lf);
    return lf;
}

vec4 drawLight(vec2 p,vec2 pos,vec4 color,float dist,float range,float radius)
{
    // distance to light
    float ld=length(p-pos);
    
    // out of range
    if(ld>range)return vec4(0.);
    
    // shadow and falloff
    float shad=shadow(p,pos,radius);
    float fall=(range-ld)/range;
    fall*=fall;
    float source=fillMask(circleDist(p-pos,radius));
    return(shad*fall+source)*color;
}

float luminance(vec4 col)
{
    return.2126*col.r+.7152*col.g+.0722*col.b;
}

void setLuminance(inout vec4 col,float lum)
{
    lum/=luminance(col);
    col*=lum;
}

float AO(vec2 p,float dist,float radius,float intensity)
{
    float a=clamp(dist/radius,0.,1.)-1.;
    return 1.-(pow(abs(a),5.)+1.)*intensity+(1.-intensity);
    return smoothstep(0.,1.,dist/radius);
}

void main(){
    fragColor=vec4(0.,0.,0.,0.);
    vec2 position=gl_FragCoord.xy;
    
    vec2 p=position.xy+vec2(.5);
    vec2 c=resolution.xy/2.;
    
    float dist=sceneDist(p);
    
    vec2 light1Pos=getLightPosition(0.);
    vec4 light1Col=getLightColor(0.);
    vec2 light1RangeAndRadius=getLightRangeAndRadius(0.);
    setLuminance(light1Col,.1);
    
    // gradient
    vec4 col=vec4(.5,.5,.5,1.)*(1.-length(c-p)/resolution.x);
    
    // ambient occlusion
    col*=AO(p,sceneSmooth(p,10.),40.,.4);
    
    // light
    col+=drawLight(p,light1Pos,light1Col,dist,light1RangeAndRadius.x,light1RangeAndRadius.y);
    
    fragColor=clamp(col,0.,1.);
}