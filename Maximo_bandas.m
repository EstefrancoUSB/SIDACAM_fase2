function [Max_Bandas_dB, Frec_Max]= Maximo_bandas(code, Dim_fft, Frec_Corte1, N_Frec, Step)

%MAXIMO BANDAS
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Función encargada de extraer las frecuencias principales de la señal de una embarcación
% por medio de su PSD, utilizando el método de Welch. Luego, aplicando un banco de filtros
% se determinan las frecuencias características de la señal de la embarcación.

%ENTRADAS
%code           String, contiene el codigo de la embarcacion.
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

load info_barcos
flag = 1;
%% posicionamiento
%Analiza en la database si el codigo de la embarcacion ya
%existe, de lo contrario la almacena


while flag == 1
    posicion = find(strcmp(info_barcos{1,1}, code));
    
    if posicion ~= 0
        fprintf('La embarcacion ya existe en la posicion %d \n', posicion)
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
    
    [Max_Bandas_dB,Frec_Max] = Banco_filtros (S_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
        Frec_Corte1, Step);
    
    
    Pregunta = input('¿Desea grabar éste recorrido? SI/NO: ', 's');
    
    if strcmp(Pregunta, 'NO')== 1;
        if info_barcos{3,1}(posicion) > 0;
            info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion)- 1;
        end
    else
        info_barcos{2,1}{posicion}(1:2,1:35,info_barcos{3,1}(posicion)) =...
            [Max_Bandas_dB;Frec_Max];
    end
    
    
    %Pregunta sobre seguir grabando más firmas acústicas.
    Mas_firmas = input('¿Desea grabar más recorridos de esta lancha? SI/NO: ', 's');
    
    if strcmp(Mas_firmas, 'NO')== 1
        flag = 2;
        disp('__________')
    end
end
save('info_barcos','info_barcos')

%Llama a la función firma acústica.
Firma_acustica (posicion,N_Frec)