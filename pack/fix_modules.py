import os
mods = {"adsp_loader_dlkm.ko": "audio_adsp_loader.ko",
"apr_dlkm.ko": "audio_apr.ko",
"bolero_cdc_dlkm.ko": "audio_bolero_cdc.ko",
"hdmi_dlkm.ko": "audio_hdmi.ko",
"machine_dlkm.ko": "audio_machine_lito.ko",
"mbhc_dlkm.ko": "audio_mbhc.ko",
"native_dlkm.ko": "audio_native.ko",
"pinctrl_lpi_dlkm.ko": "audio_pinctrl_lpi.ko",
"platform_dlkm.ko": "audio_platform.ko",
"q6_dlkm.ko": "audio_q6.ko",
"q6_notifier_dlkm.ko": "audio_q6_notifier.ko",
"q6_pdr_dlkm.ko": "audio_q6_pdr.ko",
"rx_macro_dlkm.ko": "audio_rx_macro.ko",
"snd_event_dlkm.ko": "audio_snd_event.ko",
"stub_dlkm.ko": "audio_stub.ko",
"swr_ctrl_dlkm.ko": "audio_swr_ctrl.ko",
"swr_dlkm.ko": "audio_swr.ko",
"tx_macro_dlkm.ko": "audio_tx_macro.ko",
"usf_dlkm.ko": "audio_usf.ko",
"va_macro_dlkm.ko": "audio_va_macro.ko",
"wcd937x_dlkm.ko": "audio_wcd937x.ko",
"wcd937x_slave_dlkm.ko": "audio_wcd937x_slave.ko",
"wcd938x_dlkm.ko": "audio_wcd938x.ko",
"wcd938x_slave_dlkm.ko": "audio_wcd938x_slave.ko",
"wcd9xxx_dlkm.ko": "audio_wcd9xxx.ko",
"wcd_core_dlkm.ko": "audio_wcd_core.ko",
"wsa881x_dlkm.ko": "audio_wsa881x.ko",
"wsa883x_dlkm.ko": "audio_wsa883x.ko",
"wsa_macro_dlkm.ko": "audio_wsa_macro.ko",
"wlan.ko": "qca_cld3_wlan.ko"}

for x, y, z in os.walk("./mods_og"):
    for l in z:
        if l.endswith(".ko"):
            if l in mods:
                os.replace(os.path.join(x, l), os.path.join("./modules", mods[l]))
            else:
                os.replace(os.path.join(x, l), os.path.join("./modules", l))