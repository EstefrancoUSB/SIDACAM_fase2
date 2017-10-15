function [Max_Bandas_dB,Frec_Max] = Banco_filtros (S_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step)

%BANCO FILTROS
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Función encargada de extraer los niveles máximos y las frecuencias a las
% que corresponden cada máximo de la señal de entrada.

%ENTRADAS
%S_Blanco         String, contiene el codigo de la embarcacion.
%Frec_Muestreo
%N_Frec
%Dim_fft        double,
%Frec_Corte1
%Step
%SALIDAS
%Max_Bandas_dB
%Frec_Max


Orden_Filtro = 8;
Max_Bandas_dB = zeros(1,35);
Frec_Max = zeros(1,35);


for ContMaximo = 1:N_Frec
    
    % Diseno Filtro Pasa-Banda
    Frec_Corte2 = Frec_Corte1 + Step;       % Donde el ancho de banda = Step
    Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',...
        Orden_Filtro,Frec_Corte1,Frec_Corte2,Frec_Muestreo);
    Filtro = design(Param_Filtro,'butter');
    
    % Filtro de la señal
    S_Blanco_Filtrada = filter(Filtro,S_Blanco);
    
    % Densidad Espectral de Potencia de la señal filtrada
    [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada,hamming(Dim_fft),[], [], Frec_Muestreo);
    pxxdB = pxx; %10*log10(pxx);
    
    % Búsqueda de los valores Máximos y su correspondiente frecuencia
    [Max_Bandas_dB(ContMaximo),pos] = max(pxxdB);
    Frec_Max(ContMaximo) = Frecuencias(pos);
    Frec_Corte1 = Frec_Corte2;
end