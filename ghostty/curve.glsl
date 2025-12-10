float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Quadratic bezier curve SDF
float getSdfBezier(in vec2 pos, in vec2 A, in vec2 B, in vec2 C, float thickness)
{
    vec2 a = B - A;
    vec2 b = A - 2.0*B + C;
    vec2 c = a * 2.0;
    vec2 d = A - pos;
    
    float kk = 1.0 / dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);
    
    float res = 0.0;
    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
    float h = q*q + 4.0*p3;
    
    if(h >= 0.0) {
        h = sqrt(h);
        vec2 x = (vec2(h, -h) - q) / 2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        float t = clamp(uv.x + uv.y - kx, 0.0, 1.0);
        vec2 q = d + (c + b*t)*t;
        res = dot(q,q);
    } else {
        float z = sqrt(-p);
        float v = acos(q/(p*z*2.0)) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        vec3 t = clamp(vec3(m + m, -n - m, n - m) * z - kx, 0.0, 1.0);
        vec2 qx = d + (c + b*t.x)*t.x; float dx = dot(qx, qx);
        vec2 qy = d + (c + b*t.y)*t.y; float dy = dot(qy, qy);
        res = min(dx, dy);
    }
    
    return sqrt(res) - thickness;
}

// Enhanced parallelogram with bezier curve option
float getSdfCurvedTrail(in vec2 p, in vec2 start, in vec2 end, in vec2 startSize, in vec2 endSize, float curveFactor)
{
    vec2 movement = end - start;
    float moveLength = length(movement);
    
    // Calculate how "diagonal" the movement is (0 = straight, 1 = pure diagonal)
    vec2 normalizedMove = normalize(movement);
    float diagonalness = min(abs(normalizedMove.x), abs(normalizedMove.y));
    
    // Only apply curve for significantly diagonal movements
    float curveAmount = curveFactor * diagonalness * moveLength * 0.3;
    
    if (curveAmount < 0.01) {
        // Use straight parallelogram for minimal curve
        vec2 perpendicular = normalize(vec2(-movement.y, movement.x));
        vec2 v0 = start + perpendicular * startSize.y * 0.5;
        vec2 v1 = start - perpendicular * startSize.y * 0.5;
        vec2 v2 = end - perpendicular * endSize.y * 0.5;
        vec2 v3 = end + perpendicular * endSize.y * 0.5;
        
        // Simple parallelogram SDF
        vec2 pa = p - v0;
        vec2 ba = v1 - v0;
        vec2 bc = v3 - v0;
        vec2 h = vec2(dot(pa,ba), dot(pa,bc)) / vec2(dot(ba,ba), dot(bc,bc));
        h = clamp(h, 0.0, 1.0);
        vec2 s = pa - ba*h.x - bc*h.y;
        return length(s);
    } else {
        // Use curved bezier trail
        vec2 perpendicular = normalize(vec2(-movement.y, movement.x));
        vec2 midpoint = (start + end) * 0.5;
        vec2 controlPoint = midpoint + perpendicular * curveAmount;
        
        // Create curved trail using bezier
        float avgThickness = (startSize.y + endSize.y) * 0.25;
        return getSdfBezier(p, start, controlPoint, end, avgThickness);
    }
}

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

float ease(float x) {
    return pow(1.0 - x, 3.0);
}

const vec4 TRAIL_COLOR = vec4(1., 1., 1., 1.0);
const float DURATION = 0.4; // IN SECONDS
const float CURVE_STRENGTH = 1.0; // Adjust this to control curve intensity

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    // Calculate movement vector and properties
    vec2 movement = currentCursor.xy - previousCursor.xy;
    float moveLength = length(movement);
    
    // Use curved trail SDF
    float sdfTrail = getSdfCurvedTrail(
        vu, 
        previousCursor.xy, 
        currentCursor.xy, 
        previousCursor.zw, 
        currentCursor.zw, 
        CURVE_STRENGTH
    );

    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float lineLength = distance(centerCC, centerCP);

    vec4 newColor = vec4(fragColor);
    
    // Compute fade factor based on distance along the trail
    float fadeFactor = 1.0 - smoothstep(lineLength, sdfCurrentCursor, easedProgress * lineLength);
    vec4 fadedTrailColor = TRAIL_COLOR * fadeFactor;

    // Blend trail with fade effect
    newColor = mix(newColor, fadedTrailColor, antialising(sdfTrail));
    // Draw current cursor
    newColor = mix(newColor, TRAIL_COLOR, antialising(sdfCurrentCursor));
    newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));
    fragColor = mix(fragColor, newColor, step(sdfCurrentCursor, easedProgress * lineLength));
}
