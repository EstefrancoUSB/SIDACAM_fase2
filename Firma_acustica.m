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
Comparacion_Prom = zeros(1,N_Frec);
Comparacion_Log = zeros(1,N_Frec);
Promedio = sum(Max_Bandas_dB)/N_Frec;

code = [code '.wav']; %Concatena el codigo de la embarcacion con la extension .wav
[S_Blanco, Frec_Muestreo] = audioread(code); %Lee la señal de la embarcacion y extrae su
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
    [Max_Bandas_dB(ContMaximo),posicion] = max(pxxdB);
    Frec_Max(ContMaximo) = Frecuencias(posicion);
    Frec_Corte1 = Frec_Corte2;
    
    % Parametrizacion de la firma acustica
    Comparacion_Prom(ContMaximo) = Max_Bandas_dB(ContMaximo)/Promedio;          
    Firma(ContMaximo) =1./(Comparacion_Prom(ContMaximo))^100;    
    Comparacion_Log(ContMaximo) = log10(Comparacion_Prom(ContMaximo)); 
end

