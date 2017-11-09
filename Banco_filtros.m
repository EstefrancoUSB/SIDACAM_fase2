function [Max_Bandas_dB,Frec_Max] = Banco_filtros (S_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step)

%BANCO FILTROS
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Funci�n encargada de extraer los niveles m�ximos y las frecuencias a las que corresponden 
% cada m�ximo de la se�al de entrada.
%
%ENTRADAS
%S_Blanco       Double. Se�al de la embarcaci�n ingresada.
%code           String. Contiene el codigo de la embarcacion.
%Dim_fft        Double. M�nima longitud de ventana para �ptima resoluci�n en FFT.[]
%Frec_Corte1    Double. Frecuencia m�nima de inter�s. [Hz]
%N_Frec         Double. N�mero de frecuencias para determinar la firma ac�stica. []
%Step           Double. Paso del filtro pasabanda. [Hz]
%Frec_Muestreo  Double. Frecuencia de muetreo de la se�al: 48000. [Hz]
%SALIDAS
%Max_Bandas_dB  Double. vector con los niveles m�ximos por bandas de la se�al filtrada [dB]
%Frec_Max       Double. vector con las frecuencias de los niveles m�ximo [Hz]


Orden_Filtro = 8;
Max_Bandas_dB = zeros(1,35);
Frec_Max = zeros(1,35);


for ContMaximo = 1:N_Frec
    
    % Diseno Filtro Pasa-Banda
    Frec_Corte2 = Frec_Corte1 + Step;       % Donde el ancho de banda = Step
    Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',...
        Orden_Filtro,Frec_Corte1,Frec_Corte2,Frec_Muestreo);
    Filtro = design(Param_Filtro,'butter');
    
    % Filtro de la se�al
    S_Blanco_Filtrada = filter(Filtro,S_Blanco);
    
    % Densidad Espectral de Potencia de la se�al filtrada
    [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada,hamming(Dim_fft),[], [], Frec_Muestreo);
    pxxdB = pxx; %10*log10(pxx);
    
    % B�squeda de los valores M�ximos y su correspondiente frecuencia
    [Max_Bandas_dB(ContMaximo),pos] = max(pxxdB);
    Frec_Max(ContMaximo) = Frecuencias(pos);
    Frec_Corte1 = Frec_Corte2;
end