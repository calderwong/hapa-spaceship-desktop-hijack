#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut janus_vertex(uint vertexID [[vertex_id]]) {
    float2 positions[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0)
    };
    float2 texCoords[4] = {
        float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)
    };
    
    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.texCoord = texCoords[vertexID];
    return out;
}

fragment float4 janus_fragment(VertexOut in [[stage_in]],
                               texture2d<float> desktopTexture [[texture(0)]]) {
    sampling_mode s;
    float4 color = desktopTexture.sample(s, in.texCoord);
    
    // The Janus Effect: Simple passthrough for now, 
    // but this is where the "Trinity" (L/R) and 
    // Gaussian Splat composite will live.
    return color;
}
