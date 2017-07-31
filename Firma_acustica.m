function [Max_Bandas_dB, Frec_Max,Frecuencias,Comparacion_Prom,Firma,Comparacion_Log]...
    = Firma_acustica(code, Dim_fft, Frec_Corte1, N_Frec, Step)

%FIRMA ACUSTICA
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Función encargada de extraer la firma acustica de la señal de una embarcación por medio de su
% PSD utilizando el método de Welch. Luego,aplicando un banco de filtros se determinan las
% frecuencias características de la señal de la embarcación, lo que permite por medio de una
% parametrización, obtener un vector de 35 posiciones denominado firma acústica.

%ENTRADAS
%code           String, contiene el codigo de la embarcacion
%Dim_fft        double,
%Frec_Corte1
%N_Frec
%Step
%SALIDAS
%Max_Bandas_dB
%Frec_Max
%Frecuencias
%Comparacion_Prom
%Firma,Comparacion_Log

%%Inicializacion de variables
Orden_Filtro = 8;
Max_Bandas_dB = zeros(1,N_Frec);
%Comparacion_Prom = zeros(1,N_Frec);
%Comparacion_Log = zeros(1,N_Frec);
Promedio = sum(Max_Bandas_dB)/N_Frec;
load info_barcos
%% posicionamiento
%Analiza en la database si el codigo de la embarcacion ya
            %existe, de lo contrario la almacena
            posicion = find(strcmp(info_barcos{1,1}, code));
if posicion ~= 0
    fprintf('La embarcacion ya existe en la posicion %s \n', num2str(posicion))
    info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion) + 1;
    fprintf('Numero de grabaciones: %i \n', info_barcos{3,1}(posicion));
else
    posicion = find(strcmp(info_barcos{1,1}, '0'),1);
    info_barcos{1,1}{posicion} = code;
    info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion) + 1;
    fprintf('Numero de grabaciones: %i \n', info_barcos{3,1}(posicion));
end

audio = [code '.wav']; %Concatena el codigo de la embarcacion con la extension .wav
[S_Blanco, Frec_Muestreo] = audioread(audio); %Lee la señal de la embarcacion y extrae su
%frecuencia de muestreo

for ContMaximo=1:N_Frec
    
    % Diseno Filtro Pasa-Banda
    Frec_Corte2 = Frec_Corte1 + Step;       % Donde el ancho de banda = Step
    Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',...
        Orden_Filtro,Frec_Corte1,Frec_Corte2,Frec_Muestreo);
    Filtro = design(Param_Filtro,'butter');
    
    % Filtro de la señal
    S_Blanco_Filtrada = filter(Filtro,S_Blanco);
    
    % Densidad Espectral de Potencia de la señal filtrada
    [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada,...
        hamming(Dim_fft),[], [], Frec_Muestreo);
    pxxdB = 10*log10(pxx);
    
    % Busqueda de los valores Maximos y su correspondiente frecuencia
    [Max_Bandas_dB(ContMaximo),pos] = max(pxxdB);
    Frec_Max(ContMaximo) = Frecuencias(pos);
    Frec_Corte1 = Frec_Corte2;
    
end

 % Parametrizacion de la firma acustica
    Comparacion_Prom = Max_Bandas_dB/Promedio;
    Firma =1./(Comparacion_Prom).^100;
    Comparacion_Log = log10(Comparacion_Prom);
    
    info_barcos{2,1}{posicion}(1:2,1:35,info_barcos{3,1}(posicion)) =...
    [Max_Bandas_dB;Frec_Max];
save('info_barcos','info_barcos')


