�����6J�A_s��!   QiDUN�Y���C  {�=��G�C.�   ��rh�J�#�$�N���  ��S��D��QC\� �active_frontend_kind 0
has_border true
colors
{
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
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
    55f2d182-2cff-4c59-81ad-0ef2784e9d0f "texture tex : WAVEFORMDATA;\n\nsampler sTex = sampler_state\n{\n	Texture = (tex);\n	MipFilter = LINEAR;\n	MinFilter = LINEAR;\n	MagFilter = LINEAR;\n	\n    AddressU = Clamp;\n};\n\nstruct VS_IN\n{\n	float2 pos : POSITION;\n	float2 tc : TEXCOORD0;\n};\n\nstruct PS_IN\n{\n	float4 pos : SV_POSITION;\n	float2 tc : TEXCOORD0;\n};\n\n\nfloat4 backgroundColor : BACKGROUNDCOLOR;\nfloat4 highlightColor  : HIGHLIGHTCOLOR;\nfloat4 selectionColor  : SELECTIONCOLOR;\nfloat4 textColor       : TEXTCOLOR;\nfloat cursorPos        : CURSORPOSITION;\nbool cursorVisible     : CURSORVISIBLE;\nfloat seekPos          : SEEKPOSITION;\nbool seeking           : SEEKING;\nfloat4 replayGain      : REPLAYGAIN; // album gain, track gain, album peak, track peak\nfloat2 viewportSize    : VIEWPORTSIZE;\nbool horizontal        : ORIENTATION;\nbool flipped           : FLIPPED;\nbool shade_played      : SHADEPLAYED;\n\nPS_IN VS( VS_IN input )\n{\n	PS_IN output = (PS_IN)0;\n\n	float2 half_pixel = float2(1,-1) / viewportSize;\n	output.pos = float4(input.pos - half_pixel, 0, 1);\n\n	if (horizontal)\n	{\n		output.tc = float2((input.tc.x + 1.0) / 2.0, input.tc.y);\n	}\n	else\n	{\n		output.tc = float2((-input.tc.y + 1.0) / 2.0, input.tc.x);\n	}\n\n	if (flipped)\n		output.tc.x = 1.0 - output.tc.x;\n\n	return output;\n}\n\nfloat4 bar( float pos, float2 tc, float4 fg, float4 bg, float width, bool show )\n{\n	float dist = abs(pos - tc.x);\n	float4 c = (show && dist < width)\n		? lerp(fg, bg, smoothstep(0, width, dist))\n		: bg;\n	return c;\n}\n\nfloat4 faded_bar( float pos, float2 tc, float4 fg, float4 bg, float width, bool show, float vert_from, float vert_to )\n{\n	float dist = abs(pos - tc.x);\n	float fluff = smoothstep(vert_from, vert_to, abs(tc.y));\n	float4 c = show\n		? lerp(fg, bg, max(fluff, smoothstep(0, width, dist)))\n		: bg;\n	return c;\n}\n\n// #define BORDER_ON_HIGHLIGHT\n\nfloat4 played( float pos, float2 tc, float4 fg, float4 bg, float alpha)\n{\n	float4 c = bg;\n	float2 d = 1 / viewportSize;\n	if (pos > tc.x)\n	{\n	#ifdef BORDER_ON_HIGHLIGHT\n		if (tc.x < d.x || tc.y >= (1 - d.y) || tc.y <= (2 * d.y - 1))\n			c = selectionColor;\n		else\n	#endif\n			c = lerp(c, fg, saturate(alpha));\n	}\n	return c;\n}\n\nfloat4 evaluate( float2 tc )\n{\n	// alpha 1 indicates biased texture\n	float4 minmaxrms = tex1D(sTex, tc.x);\n	minmaxrms.rgb -= 0.5 * minmaxrms.a;\n	minmaxrms.rgb *= 1.0 + minmaxrms.a;\n	float below = tc.y - minmaxrms.r;\n	float above = tc.y - minmaxrms.g;\n	float factor = min(abs(below), abs(above));\n	bool outside = (below < 0 || above > 0);\n	bool inside_rms = abs(tc.y) <= minmaxrms.b;\n\n#if 1\n	float4 bgColor = backgroundColor;\n#else\n	float a = viewportSize.x / viewportSize.y;\n	float2 aspect = horizontal ? float2(a, 1) : float2(1/a, 1);\n	float2 tcBg = float2(tc.x, -tc.y / 2 + 0.5) * aspect;\n	float4 bgColor = tex2D(sTexBg, tcBg);\n#endif\n\n	float4 wave = outside\n		? bgColor\n		: lerp(bgColor, textColor, 7.0 * factor);\n\n	return saturate(wave);\n}\n\nfloat4 PS( PS_IN input ) : SV_Target\n{\n	float dx, dy;\n	if (horizontal)\n	{\n		dx = 1/viewportSize.x;\n		dy = 1/viewportSize.y;\n	}\n	else\n	{\n		dx = 1/viewportSize.y;\n		dy = 1/viewportSize.x;\n	}\n	float seekWidth = 2.5 * dx;\n	float positionWidth = 2.5 * dx;\n\n	float4 c0 = evaluate(input.tc);\n	c0 = bar(cursorPos, input.tc, selectionColor, c0, positionWidth, cursorVisible);\n	c0 = bar(seekPos,   input.tc, selectionColor, c0, seekWidth,     seeking      );\n	if (shade_played)\n		c0 = played(cursorPos, input.tc, highlightColor, c0, 0.3);\n	return c0;\n}\n\ntechnique10 Render10\n{\n	pass P0\n	{\n		SetGeometryShader( 0 );\n		SetVertexShader( CompileShader( vs_4_0, VS() ) );\n		SetPixelShader( CompileShader( ps_4_0, PS() ) );\n	}\n}\n\ntechnique Render9\n{\n	pass\n	{\n		VertexShader = compile vs_2_0 VS();\n		PixelShader = compile ps_2_0 PS();\n	}\n}"
}
