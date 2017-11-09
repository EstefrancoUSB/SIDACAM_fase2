function [posicion, Max_Bandas_dB, Frec_Max]= Maximo_bandas(code, Dim_fft, Frec_Corte1, ...
    N_Frec, Step, varargin)

%MAXIMO BANDAS
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Función encargada de extraer las frecuencias principales de la señal de una embarcación
% por medio de su PSD, utilizando el método de Welch. Luego, aplicando un banco de filtros
% se determinan las frecuencias características de la señal de la embarcación.
%
%ENTRADAS
%code           String. contiene el codigo de la embarcacion.
%Dim_fft        Double. Mínima longitud de ventana para óptima resolución en FFT.[]
%Frec_Corte1    Double. Frecuencia mínima de interés. [Hz]
%N_Frec         Double. Número de frecuencias para determinar la firma acústica. []
%Step           Double. Paso del filtro pasabanda. [Hz]
%SALIDAS
%Max_Bandas_dB  Double. vector con los niveles máximos por bandas de la señal filtrada. [dB]
%Frec_Max       Double. vector con las frecuencias de los niveles máximo. [Hz]
%posicion       Double. valor que indica la posición de la embarcación ingresada.[]

load info_barcos
%% Posicionamiento
%Analiza en la database si el código de la embarcación ya existe, de lo contrario la almacena.

%Encontrando si existe la embarcación ingresada en code.
posicion = find(strcmp(info_barcos{1,1}, code));

if posicion ~= 0
    %Se encuentra la embarcación y se pone en la celda info_barcos{3,1}(posicion)
    fprintf('La embarcación ya existe en la posición %d \n', posicion)
    info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion) + 1;
    fprintf('Número de grabaciones: %i \n', info_barcos{3,1}(posicion));
else
    %Si no se encuentra se introduce la nueva embarcación.
    fprintf('Se introdujo una nueva embarcación: %s \n', code);
    posicion = find(strcmp(info_barcos{1,1}, '0'),1);
    info_barcos{1,1}{posicion} = code;
    info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion) + 1;
    fprintf('Número de grabaciones: %i \n', info_barcos{3,1}(posicion));
end

%Condicionantes para saber si el audio se lee desde la carpeta de
%trabajo, otra carpeta externa o una grabación.
if nargin >=6
    if nargin==6
        audio=[varargin{1} '.wav']; %Lee el nombre del archivo
        [S_Blanco, Frec_Muestreo] = audioread(audio);
        
    elseif nargin==7
        addpath(varargin{2}); %Añade el path para búsqueda.
        audio=[varargin{1} '.wav'];
        [S_Blanco, Frec_Muestreo] = audioread(audio);
    elseif nargin == 8
        S_Blanco = varargin{3};
        Frec_Muestreo = 48000;
    end
end

%Extrayendo máximos de frecuencia específicos por anchos de banda.
[Max_Bandas_dB,Frec_Max] = Banco_filtros (S_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step);

%Depurando grabaciones mal hechas.
Pregunta = input('¿Desea grabar éste recorrido? SI/NO: ', 's');

if strcmp(Pregunta, 'NO')== 1;
    if info_barcos{3,1}(posicion) > 0;
        info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion)- 1;
    end
else
    info_barcos{2,1}{posicion}(1:2,1:35,info_barcos{3,1}(posicion)) =...
        [Max_Bandas_dB;Frec_Max];
end


save('info_barcos','info_barcos')

%Llama a la función firma acústica.
