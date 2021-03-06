�����6J�A_s��!   QiDUN�Y���C�!  I����dh��Wxg�   ��rh�J�#�$�N���!  ��S��D��QC\� �active_frontend_kind 0
has_border false
colors
{
    color
    {
        r 0
        g 0
        b 0
        a 1
        override true
    }
    color
    {
        r 0
        g 0
        b 0.627451
        a 1
        override true
    }
    color
    {
        r 1
        g 1
        b 1
        a 1
        override true
    }
    color
    {
        r 1
        g 1
        b 0
        a 1
        override true
    }
}
shade_played true
display_mode 0
flip_display false
downmix_display 1
channel_order
{
    mapping
    {
        channel 16
        enabled true
    }
    mapping
    {
        channel 1
        enabled true
    }
    mapping
    {
        channel 4
        enabled true
    }
    mapping
    {
        channel 2
        enabled true
    }
    mapping
    {
        channel 32
        enabled true
    }
    mapping
    {
        channel 8
        enabled true
    }
    mapping
    {
        channel 64
        enabled false
    }
    mapping
    {
        channel 128
        enabled false
    }
    mapping
    {
        channel 256
        enabled false
    }
    mapping
    {
        channel 512
        enabled false
    }
    mapping
    {
        channel 1024
        enabled false
    }
    mapping
    {
        channel 2048
        enabled false
    }
    mapping
    {
        channel 4096
        enabled false
    }
    mapping
    {
        channel 8192
        enabled false
    }
    mapping
    {
        channel 16384
        enabled false
    }
    mapping
    {
        channel 32768
        enabled false
    }
    mapping
    {
        channel 65536
        enabled false
    }
    mapping
    {
        channel 131072
        enabled false
    }
}
generic_strings
{
    55f2d182-2cff-4c59-81ad-0ef2784e9d0f "texture tex : WAVEFORMDATA;\r\n\r\nsampler sTex = sampler_state\r\n{\r\n    Texture = (tex);\r\n    MipFilter = LINEAR;\r\n    MinFilter = LINEAR;\r\n    MagFilter = LINEAR;\r\n    \r\n    AddressU = Clamp;\r\n};\r\n\r\nstruct VS_IN\r\n{\r\n    float2 pos : POSITION;\r\n    float2 tc : TEXCOORD0;\r\n};\r\n\r\nstruct PS_IN\r\n{\r\n    float4 pos : SV_POSITION;\r\n    float2 tc : TEXCOORD0;\r\n};\r\n\r\n\r\nfloat4 backgroundColor : BACKGROUNDCOLOR;\r\nfloat4 highlightColor  : HIGHLIGHTCOLOR;\r\nfloat4 selectionColor  : SELECTIONCOLOR;\r\nfloat4 textColor       : TEXTCOLOR;\r\nfloat cursorPos        : CURSORPOSITION;\r\nbool cursorVisible     : CURSORVISIBLE;\r\nfloat seekPos          : SEEKPOSITION;\r\nbool seeking           : SEEKING;\r\nfloat4 replayGain      : REPLAYGAIN; // album gain, track gain, album peak, track peak\r\nfloat2 viewportSize    : VIEWPORTSIZE;\r\nbool horizontal        : ORIENTATION;\r\nbool flipped           : FLIPPED;\r\nbool shade_played      : SHADEPLAYED;\r\n\r\nPS_IN VS( VS_IN input )\r\n{\r\n    PS_IN output = (PS_IN)0;\r\n\r\n    float2 half_pixel = float2(1,-1) / viewportSize;\r\n    output.pos = float4(input.pos - half_pixel, 0, 1);\r\n\r\n    if (horizontal)\r\n    {\r\n        output.tc = float2((input.tc.x + 1.0) / 2.0, input.tc.y);\r\n    }\r\n    else\r\n    {\r\n        output.tc = float2((-input.tc.y + 1.0) / 2.0, input.tc.x);\r\n    }\r\n\r\n    if (flipped)\r\n        output.tc.x = 1.0 - output.tc.x;\r\n\r\n    return output;\r\n}\r\n\r\nfloat4 evaluate( float2 tc )\r\n{\r\n    // alpha 1 indicates biased texture\r\n    float4 minmaxrms = tex1D(sTex, tc.x);\r\n    minmaxrms.rgb -= 0.5 * minmaxrms.a;\r\n    minmaxrms.rgb *= 1.0 + minmaxrms.a;\r\n    float below = tc.y - minmaxrms.r;\r\n    float above = tc.y - minmaxrms.g;\r\n    float factor = min(abs(below), abs(above));\r\n    bool outside = (below < 0 || above > 0);\r\n    bool inside_rms = abs(tc.y) <= minmaxrms.b;\r\n\r\n    float4 bgColor = backgroundColor;\r\n\r\n    float4 wave = outside\r\n        ? bgColor\r\n        : lerp(bgColor, textColor, 7.0 * factor);\r\n\r\n    return saturate(wave);\r\n}\r\n\r\nfloat smoothnot(float a) {\r\n    return 1 - a;\r\n}\r\n\r\nfloat smoothand(float a, float b) {\r\n    return a * b;\r\n}\r\n\r\nfloat smoothor(float a, float b) {\r\n    return 1 - (1 - a) * (1 - b);\r\n}\r\n\r\nfloat4 pills(float pos, float2 tc, float4 fg, float4 bg, float size, float separation, float borderWidth) {\r\n    bool ahead = tc.x > pos;\r\n\r\n    float ar = viewportSize.y / viewportSize.x;\r\n    if (horizontal) {\r\n        tc.x = tc.x / ar;\r\n        tc.y = tc.y / 2;\r\n    } else {\r\n    }\r\n\r\n    float2 center = float2(0.5, 0);\r\n\r\n    float2 offset = tc / separation;\r\n    offset.x = offset.x - floor(offset.x);\r\n    offset = offset * separation;\r\n\r\n    offset = offset - center;\r\n\r\n    float inside = smoothstep(-borderWidth, 0, size/2 - sqrt(dot(offset, offset)));\r\n\r\n    return ahead ? lerp(bg, fg, inside) : bg;\r\n}\r\n\r\nfloat4 pacman(float2 tc, float pos, float size, float borderWidth, float4 fg, float4 bg) {\r\n    float ar = viewportSize.y / viewportSize.x;\r\n    if (horizontal) {\r\n        tc.x = tc.x / ar;\r\n        tc.y = tc.y / 2;\r\n    } else {\r\n    }\r\n\r\n\r\n    float2 center = float2(pos / ar, 0);\r\n    float2 offset = tc - center;\r\n\r\n    float inside = smoothstep(-borderWidth, 0, (size/2 - sqrt(dot(offset, offset))));\r\n\r\n    float phase = abs(frac(pos * 100) * 2 - 1);\r\n\r\n    float2 normal1 = normalize(float2(-phase, -1));\r\n    float above = smoothstep(-borderWidth, 0, dot(normal1, offset));\r\n\r\n    float2 normal2 = normalize(float2(-phase, 1));\r\n    float below = smoothstep(-borderWidth, 0, dot(normal2, offset));\r\n\r\n    return lerp(bg, fg, smoothand(inside, smoothor(above, below)));\r\n}\r\n\r\nfloat4 circle(float2 tc, float2 center, float radius, float borderWidth, float4 fg, float4 bg) {\r\n    float inside = smoothstep(-borderWidth, 0, radius - distance(tc, center));\r\n    return lerp(bg, fg, inside);\r\n}\r\n\r\nfloat4 enemyBody(float2 tc, float2 center, float size, float borderWidth, float4 fg, float4 bg) {\r\n    float2 offset = tc - center;\r\n    float x = offset.x/size*2;\r\n    float y = offset.y/size;\r\n    float below = smoothstep(-borderWidth, 0, -(y + x*x*x*x*x*x) + size*size);\r\n\r\n    float above = smoothstep(-borderWidth, 0, (y - 1/8 - cos(x*10)/16) + size*size);\r\n\r\n    return lerp(bg, fg, smoothand(below, above));\r\n}\r\n\r\nfloat4 enemy(float2 tc, float pos, float size, float borderWidth, float4 fg, float4 bg) {\r\n    float ar = viewportSize.y / viewportSize.x;\r\n    if (horizontal) {\r\n        tc.x = tc.x / ar;\r\n        tc.y = tc.y / 2;\r\n    } else {\r\n    }\r\n\r\n    float4 eyeColor = float4(1.0, 1.0, 1.0, 0.0);\r\n    float4 pupilColor = float4(0.0, 0.0, 0.0, 0.0);\r\n\r\n    float eyeRadius = size/8;\r\n    float pupilRadius = eyeRadius/2;\r\n\r\n    float2 center = float2(pos / ar, 0);\r\n\r\n    float2 leftEyeCenter = center + float2(-1.4*eyeRadius, size/4);\r\n    float2 leftPupilCenter = leftEyeCenter + float2(eyeRadius/3, -eyeRadius/6);\r\n    float2 rightEyeCenter = center + float2(1.4*eyeRadius, size/4);\r\n    float2 rightPupilCenter = rightEyeCenter + float2(eyeRadius/3, -eyeRadius/6);\r\n\r\n    float4 c = bg;\r\n    \r\n    c = enemyBody(tc, center, size, borderWidth, fg, c);\r\n    c = circle(tc, leftEyeCenter, eyeRadius, borderWidth, eyeColor, c);\r\n    c = circle(tc, rightEyeCenter, eyeRadius, borderWidth, eyeColor, c);\r\n    c = circle(tc, leftPupilCenter, pupilRadius, borderWidth, pupilColor, c);\r\n    c = circle(tc, rightPupilCenter, pupilRadius, borderWidth, pupilColor, c);\r\n\r\n    return c;\r\n}\r\n\r\nfloat4 PS( PS_IN input ) : SV_Target\r\n{\r\n    float dx, dy;\r\n    if (horizontal)\r\n    {\r\n        dx = 1/viewportSize.x;\r\n        dy = 1/viewportSize.y;\r\n    }\r\n    else\r\n    {\r\n        dx = 1/viewportSize.y;\r\n        dy = 1/viewportSize.x;\r\n    }\r\n    float seekWidth = 2.5 * dx;\r\n    float positionWidth = 2.5 * dx;\r\n\r\n    float borderWidth = 2*dy;\r\n\r\n    float pacmanSize = 0.7;\r\n    float enemySize = 0.7;\r\n    float pillSize = 0.2;\r\n    float pillSpacing = 0.8;\r\n\r\n    float4 enemyColor = float4(1.0, 0.0, 0.0, 0.0);\r\n    \r\n    float4 c0 = evaluate(input.tc);\r\n    c0 = pills(cursorPos, input.tc, highlightColor, c0, pillSize, pillSpacing, borderWidth);\r\n    c0 = pacman(input.tc, cursorPos, pacmanSize, borderWidth, selectionColor, c0);\r\n    c0 = enemy(input.tc, cursorPos - 1.0/3.0, enemySize, borderWidth, enemyColor, c0);\r\n    return c0;\r\n}\r\n\r\ntechnique Render9\r\n{\r\n    pass\r\n    {\r\n        VertexShader = compile vs_3_0 VS();\r\n        PixelShader = compile ps_3_0 PS();\r\n    }\r\n}"
}
