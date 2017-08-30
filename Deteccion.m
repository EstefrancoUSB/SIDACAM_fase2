function [Embarcacion] = Deteccion(tiempo,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step)


Corr_vector = zeros(1,20);
load info_barcos

[Captacion_Blanco, ~] = Grabacion(tiempo,Frec_Muestreo);
[Max_Bandas_dB,Frec_Max] = Banco_filtros (Captacion_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step);

Promedio_Captura = sum(Max_Bandas_dB)/N_Frec;
Comparacion_Prom = Max_Bandas_dB/Promedio_Captura;
Firma_Captura = 1./(Comparacion_Prom).^100;

for Comp_firmas = 1:length(info_barcos{1,1})
    [Correlacion,Legg] = xcorr(Firma_Captura,info_barcos{5,1}{Comp_firmas}(4,:),'coeff');
    %     plot(Legg,Correlacion)
    %     hold on
    Max_corr = max(Correlacion);
    Corr_vector(Comp_firmas) = Max_corr;
end

Mayor_corr = max(Corr_vector);
Pos = find(Corr_vector == Mayor_corr);
Embarcacion = info_barcos{1,1}{Pos};








