�����6J�A_s��!   QiDUN�Y���C�&  ��:�cA�-�ζ�J��   ��rh�J�#�$�N���&  ��S��D��QC\� �active_frontend_kind 0
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
        r 1
        g 1
        b 1
        a 1
        override true
    }
    color
    {
        r 1
        g 0.2509804
        b 0.5019608
        a 1
        override true
    }
    color
    {
        r 0.2509804
        g 0.5019608
        b 1
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
    55f2d182-2cff-4c59-81ad-0ef2784e9d0f "texture tex : WAVEFORMDATA;\r\n\r\nsampler sTex = sampler_state\r\n{\r\n	Texture = (tex);\r\n	MipFilter = LINEAR;\r\n	MinFilter = LINEAR;\r\n	MagFilter = LINEAR;\r\n	\r\n	AddressU = Clamp;\r\n};\r\n\r\nstruct VS_IN\r\n{\r\n	float2 pos : POSITION;\r\n	float2 tc : TEXCOORD0;\r\n};\r\n\r\nstruct PS_IN\r\n{\r\n	float4 pos : SV_POSITION;\r\n	float2 tc : TEXCOORD0;\r\n};\r\n\r\n\r\nfloat4 backgroundColor : BACKGROUNDCOLOR;\r\nfloat4 highlightColor  : HIGHLIGHTCOLOR;\r\nfloat4 selectionColor  : SELECTIONCOLOR;\r\nfloat4 textColor       : TEXTCOLOR;\r\nfloat cursorPos        : CURSORPOSITION;\r\nbool cursorVisible     : CURSORVISIBLE;\r\nfloat seekPos          : SEEKPOSITION;\r\nbool seeking           : SEEKING;\r\nfloat4 replayGain      : REPLAYGAIN; // album gain, track gain, album peak, track peak\r\nfloat2 viewportSize    : VIEWPORTSIZE;\r\nbool horizontal        : ORIENTATION;\r\nbool flipped           : FLIPPED;\r\nbool shade_played      : SHADEPLAYED;\r\nfloat elapsedTime : TRACKTIME;\r\nfloat totalTime : TRACKDURATION;\r\n\r\nPS_IN VS( VS_IN input )\r\n{\r\n	PS_IN output = (PS_IN)0;\r\n\r\n	float2 half_pixel = float2(1,-1) / viewportSize;\r\n	output.pos = float4(input.pos - half_pixel, 0, 1);\r\n\r\n	float aspectRatio = viewportSize.x / viewportSize.y;\r\n\r\n	if (horizontal) {\r\n		output.tc = float2(input.tc.x * aspectRatio, input.tc.y);\r\n	} else {\r\n		output.tc = float2(-input.tc.x, input.tc.y / aspectRatio);\r\n	}\r\n\r\n	if (flipped) {\r\n		output.tc.x = 1.0 - output.tc.x;\r\n	}\r\n\r\n	return output;\r\n}\r\n\r\nfloat4 evaluateMinMaxRMS(float relativeTime) {\r\n	 // alpha 1 indicates biased texture\r\n	float4 minmaxrms = tex1D(sTex, relativeTime);\r\n	minmaxrms.rgb -= 0.5 * minmaxrms.a;\r\n	minmaxrms.rgb *= 1.0 + minmaxrms.a;\r\n	return minmaxrms;\r\n}\r\n\r\nfloat getHeightSmooth(float2 tc, float4 minmaxrms, float thresholdWidth) {\r\n    float distFromRMSCenter = abs(tc.y);\r\n    float distFromRMSEdge = minmaxrms.b - distFromRMSCenter;\r\n    \r\n    float waveCenter = (minmaxrms.g + minmaxrms.r) / 2;\r\n    float waveRadius = (minmaxrms.g - minmaxrms.r) / 2;\r\n    float distFromWaveCenter = abs(tc.y) - waveCenter;\r\n    float distFromWaveEdge = waveRadius - distFromWaveCenter;\r\n    \r\n    float insideRMS = saturate((distFromRMSEdge / thresholdWidth) + 0.5);\r\n    float insideWave = saturate((distFromWaveEdge / thresholdWidth) + 0.5);\r\n    \r\n    float height = 0.0;\r\n    height = lerp(height, 1.0, insideWave);\r\n    height = lerp(height, 0.5, insideRMS);\r\n    return height;\r\n}\r\n\r\nfloat getHeightPlateaus(float2 tc, float4 minmaxrms, float thresholdWidth) {\r\n    float height;\r\n    if (minmaxrms.r < minmaxrms.g) {\r\n        float heightBelow;\r\n        if (minmaxrms.r < -minmaxrms.b) {\r\n                 heightBelow = smoothstep(minmaxrms.r, -minmaxrms.b, tc.y);\r\n        } else {\r\n                heightBelow = saturate((minmaxrms.b + tc.y) / thresholdWidth + 0.5);\r\n        }\r\n        float heightAbove;\r\n        if (minmaxrms.g > minmaxrms.b) {\r\n                heightAbove = smoothstep(minmaxrms.g, minmaxrms.b, tc.y);\r\n        } else {\r\n                heightAbove = saturate((minmaxrms.b - tc.y) / thresholdWidth + 0.5);\r\n        }\r\n        \r\n        height = min(heightBelow, heightAbove);\r\n        height = sin(radians(90*saturate(height)));\r\n    } else {\r\n        height = 0.0;\r\n    }\r\n    return height;\r\n}\r\n\r\nfloat evaluateHeight(float2 tc) {\r\n	float aspectRatio = viewportSize.x / viewportSize.y;\r\n	tc.x = (tc.x / aspectRatio + 1) / 2;\r\n	\r\n	float4 minmaxrms = evaluateMinMaxRMS(tc.x);\r\n\r\n	float below = tc.y - minmaxrms.r;\r\n	float above = tc.y - minmaxrms.g;\r\n	float factor = min(abs(below), abs(above));\r\n        \r\n        float dy = 1.0 / viewportSize.y;\r\n        float thresholdWidth = 3.0 * dy;\r\n\r\n        float height;\r\n        if (shade_played) {\r\n            height = getHeightSmooth(tc, minmaxrms, thresholdWidth);\r\n        } else {\r\n            height = getHeightPlateaus(tc, minmaxrms, thresholdWidth);\r\n        }\r\n        \r\n        return height;\r\n}\r\n\r\nfloat4 drawWaveform(float2 tc, float4 fg, float4 bg) {\r\n	float height = evaluateHeight(tc);\r\n	return	lerp(bg, fg, height);\r\n}\r\n\r\nfloat3 getWaveformNormalCoarse(float2 tc, float heightScale) {\r\n	float height = evaluateHeight(tc) * heightScale;\r\n	return normalize(float3(ddx(height), ddy(height), 1.0));\r\n}\r\n\r\nfloat3 getWaveformNormalFine(float2 tc, float heightScale) {\r\n	float dx = 0.1/viewportSize.x;\r\n	float dy = 1/viewportSize.y;\r\n	float height = evaluateHeight(tc) * heightScale;\r\n	float heightX = evaluateHeight(float2(tc.x + dx, tc.y)) * heightScale;\r\n	float heightY = evaluateHeight(float2(tc.x, tc.y + dy)) * heightScale;\r\n	return normalize(float3((height - heightX) / dx, (height - heightY) / dy, 1.0));\r\n}\r\n\r\nfloat4 drawShadedWaveform(float2 tc, float heightScale, float3 cameraPos, float3 lightPos, float4 diffuseCoeff, float4 specularCoeff, float shininess) {\r\n	\r\n	float3 surfacePos = float3(tc.x, tc.y, 0.0);\r\n\r\n	float3 vNormal = getWaveformNormalFine(tc, heightScale);\r\n	float3 vLight = normalize(lightPos - surfacePos);\r\n	float3 vView = normalize(cameraPos - surfacePos);\r\n	float3 vReflection = 2 * dot(vLight, vNormal) * vNormal - vLight;\r\n	\r\n	float kDiff = max(0, dot(vNormal, vLight));\r\n	float kSpec = pow(max(0, dot(vReflection, vView)), shininess);\r\n	\r\n	float4 diffuseColor = kDiff * diffuseCoeff;\r\n	float4 specularColor = kSpec * specularCoeff;\r\n		\r\n	return diffuseColor + specularColor;\r\n}\r\n\r\nfloat3 getLightPosition(float3 cameraPos, float highlightX, float highlightY, float lightDistance) {\r\n	float aspectRatio = viewportSize.x / viewportSize.y;\r\n	\r\n	float3 hightlightPos = float3((highlightX * 2 - 1) * aspectRatio, highlightY, 0.0);\r\n	float3 vNormal = float3(0.0, 0.0, 1.0);\r\n	float3 vView = normalize(cameraPos - hightlightPos);\r\n	float3 vReflection = 2 * dot(vView, vNormal) * vNormal - vView;\r\n\r\n	float3 lightPos = hightlightPos + vReflection * lightDistance;\r\n\r\n	return lightPos;\r\n}\r\n\r\nfloat4 PS( PS_IN input ) : SV_Target\r\n{\r\n	// fiddle with these to your hearts desire\r\n\r\n	float cameraDistance = 1000.0;\r\n	float waveformHeight = -0.1; // positive for raised waveform, negative for sunken waveform\r\n\r\n	// ambient light\r\n	float4 ambientCoeff = 0.3;\r\n\r\n	// diffuse and specular light for cursor position\r\n	float cursorDistance = 5.0;\r\n	float cursorYOffset = 0.0;\r\n	float4 cursorDiffuseCoeff = 0.7 * selectionColor;\r\n	float4 cursorSpecularCoeff = 1.0 * selectionColor;\r\n	float cursorShininess = 1000.0;\r\n\r\n	// diffuse and specular light for seek position\r\n	float seekDistance = 5.0;\r\n	float seekYOffset = 0.0;\r\n	float4 seekDiffuseCoeff = 0.7 * highlightColor;\r\n	float4 seekSpecularCoeff = 1.0 * highlightColor;\r\n	float4 seekShininess = 1000.0;\r\n	\r\n	// only fiddle with the rest if you know what you're doing.\r\n\r\n	float2 tc = input.tc;\r\n	\r\n	float3 cameraPos = float3(0.0, 0.0, 1.0) * cameraDistance;\r\n\r\n	float4 ambientColor = ambientCoeff * drawWaveform(tc, textColor, backgroundColor);\r\n\r\n	float4 color = ambientColor;\r\n	\r\n	float dx = ddx(tc.x) / 3;\r\n	if (true) {\r\n		float3 lightPos = getLightPosition(cameraPos, cursorPos, cursorYOffset, cursorDistance);\r\n		for (int n = -1; n <= 1; ++n) {\r\n			color += 1.0/3.0*drawShadedWaveform(tc + n * float2(dx, 0.0), waveformHeight, cameraPos, lightPos, cursorDiffuseCoeff, cursorSpecularCoeff, cursorShininess);\r\n		}\r\n	}\r\n	if (seeking) {\r\n		float3 lightPos = getLightPosition(cameraPos, seekPos, seekYOffset, seekDistance);\r\n		for (int n = -1; n <= 1; ++n) {\r\n			color += 1.0/3.0*drawShadedWaveform(tc + n * float2(dx, 0.0), waveformHeight, cameraPos, lightPos, seekDiffuseCoeff, seekSpecularCoeff, seekShininess);\r\n		}\r\n	}\r\n \r\n	return saturate(color);\r\n}\r\n\r\ntechnique Render9\r\n{\r\n	pass\r\n	{\r\n		VertexShader = compile vs_3_0 VS();\r\n		PixelShader = compile ps_3_0 PS();\r\n	}\r\n}"
}
