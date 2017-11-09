function [Embarcacion] = Deteccion(tiempo,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step)

%DETECCIÓN
%------------------------------------------------------------------------------
% David Pérez Zapata / ing.davidpz@gmail.com
% Luis Esteban Gómez  / estebang90@gmail.com
% Luis Alberto Tafur Jiménez / decano.ingenierias@usbmed.edu.co
%
% Esta función se encarga de grabar la señal de la embarcación objetivo para extraer su
% respectiva firma acústica y compararla con las demás firmas almacenadas en la base de datos.
% Da como resultado la embarcación a la que más se asemeja la señal capturada.
%
%ENTRADAS
%tiempo         Double. tiempo durante el cual se grabará señal externa. [s]
%Frec_Muestreo  Double. Frecuencia de muetreo de la señal: 48000. [Hz]
%Dim_fft        Double. Mínima longitud de ventana para óptima resolución en FFT.[]
%Frec_Corte1    Double. Frecuencia mínima de interés. [Hz]
%N_Frec         Double. Número de frecuencias para determinar la firma acústica. []
%Step           Double. Paso del filtro pasabanda. [Hz]
%SALIDAS
%Embarcacion    Double. Almacena el código de la embarcación que más se parece a la señal
%capturada.

%Carga de variable a utilizar
Corr_vector = zeros(1,20);
load info_barcos

%Se llama a la función "Grabacion" para captura de señal.
[Captacion_Blanco, ~] = Grabacion(tiempo,Frec_Muestreo);

%Llamado de la función "Banco_filtros" para extracción de máximos.
[Max_Bandas_dB,Frec_Max] = Banco_filtros (Captacion_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step);

%Parametrización de la firma acústica de la señal capturada (objetivo a comparar).
maximo = max (Max_Bandas_dB);
Firma_Captura = 1./(Max_Bandas_dB/maximo);

%Comparación de la firma acústica del objetivo con toda la base de datos.
for Comp_firmas = 1:length(info_barcos{1,1})
    [Correlacion,~] = xcorr(Firma_Captura,info_barcos{5,1}{Comp_firmas}(4,:),0,'coeff');
    Corr_vector(Comp_firmas) = Correlacion;
end
%Determinación de cuál correlación dio mejor resultado para comparar y determinar la posible
%lancha.
stem(Corr_vector)
[Val,pos] = max(Corr_vector);
if Val > 0.85
    Embarcacion = info_barcos{1,1}{pos};
else
    Embarcacion = '//Ninguna//.';
end









