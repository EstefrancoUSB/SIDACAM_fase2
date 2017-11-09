function [posicion, Max_Bandas_dB, Frec_Max]= Maximo_bandas(code, Dim_fft, Frec_Corte1, ...
    N_Frec, Step, varargin)

%MAXIMO BANDAS
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Funci�n encargada de extraer las frecuencias principales de la se�al de una embarcaci�n
% por medio de su PSD, utilizando el m�todo de Welch. Luego, aplicando un banco de filtros
% se determinan las frecuencias caracter�sticas de la se�al de la embarcaci�n.
%
%ENTRADAS
%code           String. contiene el codigo de la embarcacion.
%Dim_fft        Double. M�nima longitud de ventana para �ptima resoluci�n en FFT.[]
%Frec_Corte1    Double. Frecuencia m�nima de inter�s. [Hz]
%N_Frec         Double. N�mero de frecuencias para determinar la firma ac�stica. []
%Step           Double. Paso del filtro pasabanda. [Hz]
%SALIDAS
%Max_Bandas_dB  Double. vector con los niveles m�ximos por bandas de la se�al filtrada. [dB]
%Frec_Max       Double. vector con las frecuencias de los niveles m�ximo. [Hz]
%posicion       Double. valor que indica la posici�n de la embarcaci�n ingresada.[]

load info_barcos
%% Posicionamiento
%Analiza en la database si el c�digo de la embarcaci�n ya existe, de lo contrario la almacena.

%Encontrando si existe la embarcaci�n ingresada en code.
posicion = find(strcmp(info_barcos{1,1}, code));

if posicion ~= 0
    %Se encuentra la embarcaci�n y se pone en la celda info_barcos{3,1}(posicion)
    fprintf('La embarcaci�n ya existe en la posici�n %d \n', posicion)
    info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion) + 1;
    fprintf('N�mero de grabaciones: %i \n', info_barcos{3,1}(posicion));
else
    %Si no se encuentra se introduce la nueva embarcaci�n.
    fprintf('Se introdujo una nueva embarcaci�n: %s \n', code);
    posicion = find(strcmp(info_barcos{1,1}, '0'),1);
    info_barcos{1,1}{posicion} = code;
    info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion) + 1;
    fprintf('N�mero de grabaciones: %i \n', info_barcos{3,1}(posicion));
end

%Condicionantes para saber si el audio se lee desde la carpeta de
%trabajo, otra carpeta externa o una grabaci�n.
if nargin >=6
    if nargin==6
        audio=[varargin{1} '.wav']; %Lee el nombre del archivo
        [S_Blanco, Frec_Muestreo] = audioread(audio);
        
    elseif nargin==7
        addpath(varargin{2}); %A�ade el path para b�squeda.
        audio=[varargin{1} '.wav'];
        [S_Blanco, Frec_Muestreo] = audioread(audio);
    elseif nargin == 8
        S_Blanco = varargin{3};
        Frec_Muestreo = 48000;
    end
end

%Extrayendo m�ximos de frecuencia espec�ficos por anchos de banda.
[Max_Bandas_dB,Frec_Max] = Banco_filtros (S_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step);

%Depurando grabaciones mal hechas.
Pregunta = input('�Desea grabar �ste recorrido? SI/NO: ', 's');

if strcmp(Pregunta, 'NO')== 1;
    if info_barcos{3,1}(posicion) > 0;
        info_barcos{3,1}(posicion) = info_barcos{3,1}(posicion)- 1;
    end
else
    info_barcos{2,1}{posicion}(1:2,1:35,info_barcos{3,1}(posicion)) =...
        [Max_Bandas_dB;Frec_Max];
end


save('info_barcos','info_barcos')

%Llama a la funci�n firma ac�stica.
